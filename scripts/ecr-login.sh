#!/usr/bin/env bash
set -euo pipefail

AWS_REGION="eu-central-1"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --region)
      AWS_REGION="${2:?--region requires a value}"
      shift 2
      ;;
    *)
      echo "Usage: $0 [--region eu-central-1]" >&2
      exit 1
      ;;
  esac
done

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
REGISTRY="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

aws ecr get-login-password --region "${AWS_REGION}" \
  | docker login --username AWS --password-stdin "${REGISTRY}"

echo "Logged in to ${REGISTRY}"
