#!/usr/bin/env bash
set -euo pipefail

AWS_REGION="${1:-eu-central-1}"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
BUCKET_NAME="petclinic-terraform-state-${ACCOUNT_ID}"
TABLE_NAME="petclinic-terraform-locks"

echo "Account:  ${ACCOUNT_ID}"
echo "Region:   ${AWS_REGION}"
echo "Bucket:   ${BUCKET_NAME}"
echo "Table:    ${TABLE_NAME}"
echo ""

# --- S3 Bucket ---
if aws s3api head-bucket --bucket "${BUCKET_NAME}" 2>/dev/null; then
  echo "S3 bucket '${BUCKET_NAME}' already exists — skipping creation."
else
  echo "Creating S3 bucket '${BUCKET_NAME}'..."
  aws s3api create-bucket \
    --bucket "${BUCKET_NAME}" \
    --region "${AWS_REGION}" \
    --create-bucket-configuration LocationConstraint="${AWS_REGION}"
fi

echo "Enabling bucket versioning..."
aws s3api put-bucket-versioning \
  --bucket "${BUCKET_NAME}" \
  --versioning-configuration Status=Enabled

echo "Enabling default encryption (AES256)..."
aws s3api put-bucket-encryption \
  --bucket "${BUCKET_NAME}" \
  --server-side-encryption-configuration '{
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        }
      }
    ]
  }'

echo "Blocking all public access..."
aws s3api put-public-access-block \
  --bucket "${BUCKET_NAME}" \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

# --- DynamoDB Table ---
if aws dynamodb describe-table --table-name "${TABLE_NAME}" --region "${AWS_REGION}" >/dev/null 2>&1; then
  echo "DynamoDB table '${TABLE_NAME}' already exists — skipping creation."
else
  echo "Creating DynamoDB table '${TABLE_NAME}'..."
  aws dynamodb create-table \
    --table-name "${TABLE_NAME}" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "${AWS_REGION}" \
    --tags Key=Project,Value=petclinic Key=ManagedBy,Value=terraform

  echo "Waiting for table to become active..."
  aws dynamodb wait table-exists --table-name "${TABLE_NAME}" --region "${AWS_REGION}"
fi

echo ""
echo "Terraform backend resources ready."
echo "Bucket: ${BUCKET_NAME}"
echo "Table:  ${TABLE_NAME}"
