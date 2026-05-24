# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-05-24

### Added

- Clinical PDF Jobs DynamoDB table for tracking PDF table extraction
- Table schema with single-table design:
  - **PK/SK**: `JOB#{job_id}` / `METADATA` or `TABLE#{num}#PAGE#{page}`
  - **GSI1**: Query by product (`PRODUCT#{name}`) or status (`STATUS#FAILED`)
- Features:
  - On-demand billing (PAY_PER_REQUEST)
  - Point-in-time recovery enabled
  - TTL for automatic cleanup of old records (90 days)
  - Server-side encryption
- SSM Parameter Store exports for Lambda integration
- GitHub Actions CI/CD with:
  - Terraform validate & lint
  - Checkov security scanning
  - Multi-environment support (dev, qa, prod)
  - Deploy and destroy actions via workflow_dispatch
