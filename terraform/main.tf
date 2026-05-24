# =============================================================================
# AWS DynamoDB Table
# =============================================================================

terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = local.aws_region

  default_tags {
    tags = local.common_tags
  }
}

# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# -----------------------------------------------------------------------------
# DynamoDB Table
# -----------------------------------------------------------------------------
resource "aws_dynamodb_table" "main" {
  name         = local.full_name
  billing_mode = local.billing_mode

  # Primary key
  hash_key  = local.partition_key.name
  range_key = local.sort_key.name

  # Key attributes
  attribute {
    name = local.partition_key.name
    type = local.partition_key.type
  }

  attribute {
    name = local.sort_key.name
    type = local.sort_key.type
  }

  # GSI1 attributes (for querying by product/status)
  attribute {
    name = "GSI1PK"
    type = "S"
  }

  attribute {
    name = "GSI1SK"
    type = "S"
  }

  # TTL configuration
  dynamic "ttl" {
    for_each = local.ttl_attribute != "" ? [1] : []
    content {
      attribute_name = local.ttl_attribute
      enabled        = true
    }
  }

  # Point-in-time recovery
  point_in_time_recovery {
    enabled = local.point_in_time_recovery
  }

  # DynamoDB Streams
  stream_enabled   = local.stream_view_type != "DISABLED"
  stream_view_type = local.stream_view_type != "DISABLED" ? local.stream_view_type : null

  # Server-side encryption (uses AWS managed key by default)
  server_side_encryption {
    enabled = true
  }

  # Global Secondary Indexes
  dynamic "global_secondary_index" {
    for_each = local.global_secondary_indexes
    content {
      name            = global_secondary_index.value.name
      hash_key        = global_secondary_index.value.partition_key
      range_key       = lookup(global_secondary_index.value, "sort_key", null)
      projection_type = lookup(global_secondary_index.value, "projection_type", "ALL")

      # Non-key attributes to project (only for INCLUDE projection)
      non_key_attributes = lookup(global_secondary_index.value, "non_key_attributes", null)

      # Provisioned capacity (only for PROVISIONED billing mode)
      read_capacity  = local.billing_mode == "PROVISIONED" ? lookup(global_secondary_index.value, "read_capacity", local.read_capacity) : null
      write_capacity = local.billing_mode == "PROVISIONED" ? lookup(global_secondary_index.value, "write_capacity", local.write_capacity) : null
    }
  }

  tags = {
    Name = local.full_name
  }

  lifecycle {
    prevent_destroy = false # Set to true in production
  }
}

# -----------------------------------------------------------------------------
# Note: GSI Attribute Definitions
# -----------------------------------------------------------------------------
# When adding GSIs, you must also add attribute definitions for GSI keys
# in the main table resource above. Example:
#
# attribute {
#   name = "GSI1PK"
#   type = "S"
# }
#
# attribute {
#   name = "GSI1SK"
#   type = "S"
# }

# -----------------------------------------------------------------------------
# Auto Scaling (only for PROVISIONED billing mode)
# -----------------------------------------------------------------------------
# Uncomment and configure if using PROVISIONED billing mode

# resource "aws_appautoscaling_target" "read" {
#   count              = local.billing_mode == "PROVISIONED" ? 1 : 0
#   max_capacity       = 100
#   min_capacity       = 5
#   resource_id        = "table/${aws_dynamodb_table.main.name}"
#   scalable_dimension = "dynamodb:table:ReadCapacityUnits"
#   service_namespace  = "dynamodb"
# }

# resource "aws_appautoscaling_policy" "read" {
#   count              = local.billing_mode == "PROVISIONED" ? 1 : 0
#   name               = "${local.full_name}-read-autoscaling"
#   policy_type        = "TargetTrackingScaling"
#   resource_id        = aws_appautoscaling_target.read[0].resource_id
#   scalable_dimension = aws_appautoscaling_target.read[0].scalable_dimension
#   service_namespace  = aws_appautoscaling_target.read[0].service_namespace
#
#   target_tracking_scaling_policy_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "DynamoDBReadCapacityUtilization"
#     }
#     target_value = 70.0
#   }
# }

# resource "aws_appautoscaling_target" "write" {
#   count              = local.billing_mode == "PROVISIONED" ? 1 : 0
#   max_capacity       = 100
#   min_capacity       = 5
#   resource_id        = "table/${aws_dynamodb_table.main.name}"
#   scalable_dimension = "dynamodb:table:WriteCapacityUnits"
#   service_namespace  = "dynamodb"
# }

# resource "aws_appautoscaling_policy" "write" {
#   count              = local.billing_mode == "PROVISIONED" ? 1 : 0
#   name               = "${local.full_name}-write-autoscaling"
#   policy_type        = "TargetTrackingScaling"
#   resource_id        = aws_appautoscaling_target.write[0].resource_id
#   scalable_dimension = aws_appautoscaling_target.write[0].scalable_dimension
#   service_namespace  = aws_appautoscaling_target.write[0].service_namespace
#
#   target_tracking_scaling_policy_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "DynamoDBWriteCapacityUtilization"
#     }
#     target_value = 70.0
#   }
# }
