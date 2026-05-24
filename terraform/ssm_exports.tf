# =============================================================================
# SSM Parameter Exports - DynamoDB Configuration
# =============================================================================
# Export DynamoDB table details to SSM for use by other services (Lambdas, etc.)

resource "aws_ssm_parameter" "table_name" {
  name        = "/${var.environment}/${local.project_name}/dynamodb/${local.table_name}/table_name"
  description = "Name of the ${local.table_name} DynamoDB table"
  type        = "String"
  value       = aws_dynamodb_table.main.name

  tags = merge(local.common_tags, {
    Name = "${local.full_name}-table-name"
  })
}

resource "aws_ssm_parameter" "table_arn" {
  name        = "/${var.environment}/${local.project_name}/dynamodb/${local.table_name}/table_arn"
  description = "ARN of the ${local.table_name} DynamoDB table"
  type        = "String"
  value       = aws_dynamodb_table.main.arn

  tags = merge(local.common_tags, {
    Name = "${local.full_name}-table-arn"
  })
}

resource "aws_ssm_parameter" "stream_arn" {
  count = local.stream_view_type != "DISABLED" ? 1 : 0

  name        = "/${var.environment}/${local.project_name}/dynamodb/${local.table_name}/stream_arn"
  description = "Stream ARN of the ${local.table_name} DynamoDB table"
  type        = "String"
  value       = aws_dynamodb_table.main.stream_arn

  tags = merge(local.common_tags, {
    Name = "${local.full_name}-stream-arn"
  })
}
