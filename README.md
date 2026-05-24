# Clinical PDF Jobs DynamoDB Table

[![Terraform](https://img.shields.io/badge/Terraform-1.10%2B-7B42BC?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-DynamoDB-FF9900?logo=amazondynamodb)](https://aws.amazon.com/dynamodb/)

DynamoDB table for tracking clinical PDF table extraction jobs. Part of the **Clinical RAG Foundry** project.

---

## 📋 Table of Contents

- [Features](#features)
- [Repository Structure](#repository-structure)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Deployment](#deployment)
- [SSM Parameters](#ssm-parameters)
- [Access Patterns](#access-patterns)

---

## Features

- ✅ **DynamoDB Table** - Single table design with PK/SK
- ✅ **On-Demand Billing** - Pay per request (configurable to provisioned)
- ✅ **GSI Support** - Global Secondary Indexes for flexible queries
- ✅ **Point-in-Time Recovery** - Continuous backups
- ✅ **TTL Support** - Automatic item expiration
- ✅ **DynamoDB Streams** - Optional change data capture
- ✅ **Terraform** - Infrastructure as Code
- ✅ **GitHub Actions** - CI/CD pipeline with OIDC authentication
- ✅ **Multi-environment** - dev, qa, prod support
- ✅ **SSM Integration** - Export table details to Parameter Store

---

## Repository Structure

```
aws-dynamodb-template/
├── .github/
│   └── workflows/
│       └── deploy.yml              # CI/CD pipeline
├── terraform/
│   ├── config.tf                   # ⭐ PROJECT CONFIG (edit this!)
│   ├── main.tf                     # DynamoDB table resource
│   ├── variables.tf                # Runtime variables (env)
│   ├── outputs.tf                  # Output values
│   ├── backend.tf                  # S3 backend (uses -backend-config)
│   └── ssm_exports.tf              # SSM parameter exports
├── CHANGELOG.md
└── README.md
```

---

## Prerequisites

- **Terraform 1.10+**
- **AWS CLI v2**
- **GitHub repository** with OIDC configured

### Bootstrap Requirements

This template requires the `aws-bootstrap-tfstate-oidc` infrastructure:
- S3 bucket for Terraform state
- IAM role for GitHub Actions with OIDC trust

---

## Quick Start

### 1. Create New Repository from Template

```bash
# Clone template
git clone https://github.com/vigalcontec/aws-dynamodb-template.git my-dynamodb-table
cd my-dynamodb-table

# Remove template git history
rm -rf .git
git init
```

### 2. Configure Your Project

Edit `terraform/config.tf`:

```hcl
locals {
  table_name   = "my-jobs-table"      # Your table name
  project_name = "my-project"         # Your project name
  company_name = "vigalcontec"        # Your company name
  
  # Primary key
  partition_key = {
    name = "PK"
    type = "S"
  }
  
  sort_key = {
    name = "SK"
    type = "S"
  }
  
  # Optional: Add GSIs
  global_secondary_indexes = [
    {
      name            = "GSI1"
      partition_key   = "GSI1PK"
      sort_key        = "GSI1SK"
      projection_type = "ALL"
    },
  ]
}
```

### 3. Configure GitHub Secrets

Add the following secrets to your GitHub repository (`Settings > Secrets and variables > Actions`):

| Secret | Description |
|--------|-------------|
| `AWS_ROLE_ARN_DEV` | ARN of the GitHub Actions IAM role for dev |
| `AWS_ROLE_ARN_QA` | ARN of the GitHub Actions IAM role for qa |
| `AWS_ROLE_ARN_PROD` | ARN of the GitHub Actions IAM role for prod |

### 4. Enable CI/CD Workflows

Edit `.github/workflows/deploy.yml` and uncomment the triggers:

```yaml
on:
  workflow_dispatch:
    # ... (keep this for manual runs)
  
  # UNCOMMENT THESE LINES:
  push:
    branches: [main, develop, "feature/*", "release/*"]
    paths:
      - 'terraform/**'
      - '.github/workflows/deploy.yml'
  pull_request:
    branches: [main, develop]
    paths:
      - 'terraform/**'
```

---

## Configuration

### Table Schema

Configure your table schema in `terraform/config.tf`:

```hcl
# Primary key
partition_key = {
  name = "PK"
  type = "S"  # S = String, N = Number, B = Binary
}

sort_key = {
  name = "SK"
  type = "S"
}
```

### Global Secondary Indexes

Add GSIs for additional access patterns:

```hcl
global_secondary_indexes = [
  {
    name            = "GSI1"
    partition_key   = "GSI1PK"
    sort_key        = "GSI1SK"
    projection_type = "ALL"  # ALL, KEYS_ONLY, or INCLUDE
  },
  {
    name               = "GSI2"
    partition_key      = "GSI2PK"
    projection_type    = "INCLUDE"
    non_key_attributes = ["status", "created_at"]
  },
]
```

**Important:** When adding GSIs, also add attribute definitions in `main.tf`:

```hcl
attribute {
  name = "GSI1PK"
  type = "S"
}

attribute {
  name = "GSI1SK"
  type = "S"
}
```

### Billing Mode

```hcl
# On-demand (recommended for variable workloads)
billing_mode = "PAY_PER_REQUEST"

# Or provisioned (for predictable workloads)
billing_mode   = "PROVISIONED"
read_capacity  = 5
write_capacity = 5
```

### TTL

```hcl
# Enable TTL on "ttl" attribute
ttl_attribute = "ttl"

# Disable TTL
ttl_attribute = ""
```

### DynamoDB Streams

```hcl
# Options: "DISABLED", "KEYS_ONLY", "NEW_IMAGE", "OLD_IMAGE", "NEW_AND_OLD_IMAGES"
stream_view_type = "NEW_AND_OLD_IMAGES"
```

---

## Deployment

### GitHub Actions (Recommended)

| Branch | Environment |
|--------|-------------|
| `main` | prod |
| `release/*` | qa |
| `develop`, `feature/*` | dev |

### Manual Deploy/Destroy

1. Go to **Actions** → **Deploy DynamoDB**
2. Click **Run workflow**
3. Select:
   - **Environment:** dev, qa, or prod
   - **Action:** `deploy` or `destroy`

### Local Deployment

```bash
cd terraform

# Create backend_override.tf with your backend config
terraform init \
  -backend-config="bucket=tfstate-vigalcontec-dev-123456789012" \
  -backend-config="key=dynamodb/my-jobs-table/terraform.tfstate" \
  -backend-config="region=eu-west-1" \
  -backend-config="encrypt=true"

terraform apply -var="environment=dev"
```

---

## SSM Parameters

The template exports table details to SSM Parameter Store:

| Parameter | Description |
|-----------|-------------|
| `/{env}/{project}/dynamodb/{table}/table_name` | Table name |
| `/{env}/{project}/dynamodb/{table}/table_arn` | Table ARN |
| `/{env}/{project}/dynamodb/{table}/stream_arn` | Stream ARN (if enabled) |

### Using in Lambda

```python
import boto3
import os

# Read from environment variable (injected by Terraform)
TABLE_NAME = os.environ["JOBS_TABLE_NAME"]

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(TABLE_NAME)

# Query example
response = table.query(
    KeyConditionExpression="PK = :pk AND begins_with(SK, :sk)",
    ExpressionAttributeValues={
        ":pk": "JOB#123",
        ":sk": "TABLE#"
    }
)
```

---

## Access Patterns

### Single Table Design Example

| Access Pattern | PK | SK | GSI |
|---------------|----|----|-----|
| Get job by ID | `JOB#{job_id}` | `METADATA` | - |
| Get all tables for job | `JOB#{job_id}` | `TABLE#{num}#PAGE#{page}` | - |
| Get jobs by product | - | - | GSI1: `PRODUCT#{name}` |
| Get recent failures | - | - | GSI1: `STATUS#FAILED` |

### Item Examples

```json
// Job metadata
{
  "PK": "JOB#abc123",
  "SK": "METADATA",
  "status": "RUNNING",
  "total_tables": 47,
  "created_at": "2026-05-23T16:00:00Z",
  "GSI1PK": "PRODUCT#Keytruda",
  "GSI1SK": "2026-05-23T16:00:00Z"
}

// Table record
{
  "PK": "JOB#abc123",
  "SK": "TABLE#1#PAGE#7",
  "status": "SUCCESS",
  "table_name": "Table 1: Demographics",
  "output_s3_key": "s3://bucket/path/table_1_page_7.parquet"
}
```

---

## License

MIT