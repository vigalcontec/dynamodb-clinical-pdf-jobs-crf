# =============================================================================
# Configuration - Update these values for your project
# =============================================================================

locals {
  # ─────────────────────────────────────────────────────────────────────────────
  # Project Configuration (UPDATE THESE)
  # ─────────────────────────────────────────────────────────────────────────────
  table_name   = "my-dynamodb-table" # DynamoDB table name (without env suffix)
  project_name = "bootstrap"         # Project name for tagging
  company_name = "vigalcontec"       # Company name for resource naming

  # ─────────────────────────────────────────────────────────────────────────────
  # AWS Configuration
  # ─────────────────────────────────────────────────────────────────────────────
  aws_region = "eu-west-1"

  # ─────────────────────────────────────────────────────────────────────────────
  # DynamoDB Configuration
  # ─────────────────────────────────────────────────────────────────────────────

  # Billing mode: "PAY_PER_REQUEST" (on-demand) or "PROVISIONED"
  billing_mode = "PAY_PER_REQUEST"

  # Only used if billing_mode = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5

  # Point-in-time recovery (recommended for production)
  point_in_time_recovery = true

  # TTL configuration (set to "" to disable)
  ttl_attribute = "ttl"

  # Stream configuration: "DISABLED", "KEYS_ONLY", "NEW_IMAGE", "OLD_IMAGE", "NEW_AND_OLD_IMAGES"
  stream_view_type = "DISABLED"

  # ─────────────────────────────────────────────────────────────────────────────
  # Table Schema Configuration
  # ─────────────────────────────────────────────────────────────────────────────

  # Primary key
  partition_key = {
    name = "PK"
    type = "S" # S = String, N = Number, B = Binary
  }

  sort_key = {
    name = "SK"
    type = "S"
  }

  # Global Secondary Indexes (GSIs)
  # Add GSIs as needed for your access patterns
  global_secondary_indexes = [
    # Example GSI for querying by product
    # {
    #   name            = "GSI1"
    #   partition_key   = "GSI1PK"
    #   sort_key        = "GSI1SK"
    #   projection_type = "ALL"  # ALL, KEYS_ONLY, or INCLUDE
    #   # Only for PROVISIONED billing mode:
    #   # read_capacity  = 5
    #   # write_capacity = 5
    # }
  ]

  # ─────────────────────────────────────────────────────────────────────────────
  # Computed Values (DO NOT MODIFY)
  # ─────────────────────────────────────────────────────────────────────────────
  account_id   = data.aws_caller_identity.current.account_id
  full_name    = "${local.table_name}-${var.environment}"
  state_bucket = "tfstate-${local.company_name}-${var.environment}-${local.account_id}"

  # Common tags
  common_tags = {
    Project     = local.project_name
    Table       = local.table_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
