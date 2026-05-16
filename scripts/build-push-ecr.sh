#!/usr/bin/env bash
set -euo pipefail

AWS_REGION="eu-central-1"
ENVIRONMENT="dev"
TAG="v1.0.0"
APP_REPO="../spring-petclinic-microservices"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --region)
      AWS_REGION="${2:?--region requires a value}"
      shift 2
      ;;
    --env)
      ENVIRONMENT="${2:?--env requires a value}"
      shift 2
      ;;
    --tag)
      TAG="${2:?--tag requires a value}"
      shift 2
      ;;
    --app-repo)
      APP_REPO="${2:?--app-repo requires a value}"
      shift 2
      ;;
    *)
      echo "Usage: $0 [--region eu-central-1] [--env dev] [--tag v1.0.0] [--app-repo ../spring-petclinic-microservices]" >&2
      exit 1
      ;;
  esac
done

case "${ENVIRONMENT}" in
  dev|prod) ;;
  *)
    echo "--env must be dev or prod" >&2
    exit 1
    ;;
esac

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
REGISTRY="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLATFORM_REPO="$(cd "${SCRIPT_DIR}/.." && pwd)"
APP_REPO="$(cd "${PLATFORM_REPO}/${APP_REPO}" && pwd)"
DOCKERFILE="${APP_REPO}/docker/Dockerfile"

SERVICES=(
  "config-server:spring-petclinic-config-server:8888"
  "discovery-server:spring-petclinic-discovery-server:8761"
  "api-gateway:spring-petclinic-api-gateway:8080"
  "customers-service:spring-petclinic-customers-service:8081"
  "visits-service:spring-petclinic-visits-service:8082"
  "vets-service:spring-petclinic-vets-service:8083"
  "genai-service:spring-petclinic-genai-service:8084"
  "admin-server:spring-petclinic-admin-server:9090"
)

echo "Building Maven artifacts in ${APP_REPO}"
(
  cd "${APP_REPO}"
  ./mvnw clean package -DskipTests
)

echo "Logging in to ${REGISTRY}"
aws ecr get-login-password --region "${AWS_REGION}" \
  | docker login --username AWS --password-stdin "${REGISTRY}"

for item in "${SERVICES[@]}"; do
  IFS=":" read -r service module port <<< "${item}"
  jar="$(find "${APP_REPO}/${module}/target" -maxdepth 1 -type f -name "${module}-*.jar" ! -name "*-sources.jar" ! -name "*-javadoc.jar" | head -n 1)"
  image="${REGISTRY}/petclinic-${ENVIRONMENT}/${service}:${TAG}"

  if [[ -z "${jar}" ]]; then
    echo "No JAR found for ${module}" >&2
    exit 1
  fi

  echo "Building and pushing ${image}"
  docker buildx build \
    --platform linux/arm64 \
    --file "${DOCKERFILE}" \
    --build-arg "ARTIFACT_NAME=$(basename "${jar}" .jar)" \
    --build-arg "EXPOSED_PORT=${port}" \
    --tag "${image}" \
    --push \
    "$(dirname "${jar}")"
done

echo "Pushed all images with tag ${TAG} to ${REGISTRY}/petclinic-${ENVIRONMENT}/"
