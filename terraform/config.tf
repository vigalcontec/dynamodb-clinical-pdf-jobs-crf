# =============================================================================
# Configuration - Update these values for your project
# =============================================================================

locals {
  # ─────────────────────────────────────────────────────────────────────────────
  # Project Configuration
  # ─────────────────────────────────────────────────────────────────────────────
  table_name   = "clinical-pdf-jobs-crf" # DynamoDB table name (without env suffix)
  project_name = "clinical-rag-foundry"  # Project name for tagging
  company_name = "vigalcontec"           # Company name for resource naming

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

  # TTL configuration - auto-delete old job records after 90 days
  ttl_attribute = "ttl"

  # Stream configuration: "DISABLED", "KEYS_ONLY", "NEW_IMAGE", "OLD_IMAGE", "NEW_AND_OLD_IMAGES"
  # Enable streams if you need to trigger Lambda on job status changes
  stream_view_type = "DISABLED"

  # ─────────────────────────────────────────────────────────────────────────────
  # Table Schema Configuration
  # ─────────────────────────────────────────────────────────────────────────────
  #
  # Schema Design:
  # ┌─────────────────────────────────────────────────────────────────────────┐
  # │ Entity          │ PK                  │ SK                             │
  # ├─────────────────┼─────────────────────┼────────────────────────────────┤
  # │ Job Metadata    │ JOB#{job_id}        │ METADATA                       │
  # │ Table Record    │ JOB#{job_id}        │ TABLE#{num}#PAGE#{page}        │
  # └─────────────────────────────────────────────────────────────────────────┘
  #
  # GSI1 Access Patterns:
  # ┌─────────────────────────────────────────────────────────────────────────┐
  # │ Query                │ GSI1PK              │ GSI1SK                     │
  # ├──────────────────────┼─────────────────────┼────────────────────────────┤
  # │ Jobs by product      │ PRODUCT#{name}      │ {created_at}               │
  # │ Failed tables        │ STATUS#FAILED       │ {failed_at}                │
  # │ Successful tables    │ STATUS#SUCCESS      │ {processed_at}             │
  # └─────────────────────────────────────────────────────────────────────────┘

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
  global_secondary_indexes = [
    {
      name            = "GSI1"
      partition_key   = "GSI1PK"
      sort_key        = "GSI1SK"
      projection_type = "ALL"
    }
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
