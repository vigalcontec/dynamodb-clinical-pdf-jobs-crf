# =============================================================================
# Outputs - DynamoDB Table Information
# =============================================================================

output "table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.main.name
}

output "table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.main.arn
}

output "table_id" {
  description = "ID of the DynamoDB table"
  value       = aws_dynamodb_table.main.id
}

output "stream_arn" {
  description = "ARN of the DynamoDB stream (if enabled)"
  value       = aws_dynamodb_table.main.stream_arn
}

output "stream_label" {
  description = "Timestamp of the DynamoDB stream (if enabled)"
  value       = aws_dynamodb_table.main.stream_label
}

# -----------------------------------------------------------------------------
# SSM Parameter Paths (for reference)
# -----------------------------------------------------------------------------
output "ssm_table_name_path" {
  description = "SSM parameter path for table name"
  value       = aws_ssm_parameter.table_name.name
}

output "ssm_table_arn_path" {
  description = "SSM parameter path for table ARN"
  value       = aws_ssm_parameter.table_arn.name
}
