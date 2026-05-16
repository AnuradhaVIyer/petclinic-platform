@echo off
setlocal enabledelayedexpansion

set AWS_REGION=%1
if "%AWS_REGION%"=="" set AWS_REGION=eu-central-1

for /f "tokens=*" %%i in ('aws sts get-caller-identity --query Account --output text') do set ACCOUNT_ID=%%i
set BUCKET_NAME=petclinic-terraform-state-%ACCOUNT_ID%
set TABLE_NAME=petclinic-terraform-locks

echo Account:  %ACCOUNT_ID%
echo Region:   %AWS_REGION%
echo Bucket:   %BUCKET_NAME%
echo Table:    %TABLE_NAME%
echo.

REM --- S3 Bucket ---
aws s3api head-bucket --bucket %BUCKET_NAME% 2>nul
if %errorlevel% equ 0 (
    echo S3 bucket '%BUCKET_NAME%' already exists -- skipping creation.
) else (
    echo Creating S3 bucket '%BUCKET_NAME%'...
    aws s3api create-bucket ^
      --bucket %BUCKET_NAME% ^
      --region %AWS_REGION% ^
      --create-bucket-configuration LocationConstraint=%AWS_REGION%
)

echo Enabling bucket versioning...
aws s3api put-bucket-versioning ^
  --bucket %BUCKET_NAME% ^
  --versioning-configuration Status=Enabled

echo Enabling default encryption (AES256)...
aws s3api put-bucket-encryption ^
  --bucket %BUCKET_NAME% ^
  --server-side-encryption-configuration "{\"Rules\":[{\"ApplyServerSideEncryptionByDefault\":{\"SSEAlgorithm\":\"AES256\"}}]}"

echo Blocking all public access...
aws s3api put-public-access-block ^
  --bucket %BUCKET_NAME% ^
  --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

REM --- DynamoDB Table ---
aws dynamodb describe-table --table-name %TABLE_NAME% --region %AWS_REGION% >nul 2>&1
if %errorlevel% equ 0 (
    echo DynamoDB table '%TABLE_NAME%' already exists -- skipping creation.
) else (
    echo Creating DynamoDB table '%TABLE_NAME%'...
    aws dynamodb create-table ^
      --table-name %TABLE_NAME% ^
      --attribute-definitions AttributeName=LockID,AttributeType=S ^
      --key-schema AttributeName=LockID,KeyType=HASH ^
      --billing-mode PAY_PER_REQUEST ^
      --region %AWS_REGION% ^
      --tags Key=Project,Value=petclinic Key=ManagedBy,Value=terraform

    echo Waiting for table to become active...
    aws dynamodb wait table-exists --table-name %TABLE_NAME% --region %AWS_REGION%
)

echo.
echo Terraform backend resources ready.
echo Bucket: %BUCKET_NAME%
echo Table:  %TABLE_NAME%

endlocal
pause
