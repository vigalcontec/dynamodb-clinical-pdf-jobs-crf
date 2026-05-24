# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-05-23

### Added

- Initial DynamoDB template release
- Terraform configuration for DynamoDB table with:
  - Configurable partition key and sort key
  - On-demand (PAY_PER_REQUEST) or provisioned billing modes
  - Global Secondary Index (GSI) support
  - Point-in-time recovery
  - TTL configuration
  - DynamoDB Streams support
  - Server-side encryption
- SSM Parameter Store exports for table name, ARN, and stream ARN
- GitHub Actions CI/CD workflow with:
  - Multi-environment support (dev, qa, prod)
  - OIDC authentication
  - Terraform plan on PRs
  - Deploy and destroy actions
- Comprehensive README with setup instructions
