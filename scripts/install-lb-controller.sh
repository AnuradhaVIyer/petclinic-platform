#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${ENVIRONMENT:-dev}"
AWS_REGION="${AWS_REGION:-eu-central-1}"
CLUSTER_NAME="${CLUSTER_NAME:-petclinic-${ENVIRONMENT}}"
SERVICE_ACCOUNT_NAME="${SERVICE_ACCOUNT_NAME:-aws-load-balancer-controller}"
SERVICE_ACCOUNT_NAMESPACE="${SERVICE_ACCOUNT_NAMESPACE:-kube-system}"
CONTROLLER_APP_VERSION="${CONTROLLER_APP_VERSION:-v2.8.1}"
HELM_CHART_VERSION="${HELM_CHART_VERSION:-1.8.1}"
ROLE_ARN="${ROLE_ARN:-}"

if [[ -z "${ROLE_ARN}" ]]; then
  cat >&2 <<EOF
ROLE_ARN is required.

Example:
  ROLE_ARN=\$(terraform -chdir=terraform/environments/dev output -raw lb_controller_role_arn) \\
    scripts/install-lb-controller.sh
EOF
  exit 1
fi

command -v aws >/dev/null || { echo "aws CLI is required" >&2; exit 1; }
command -v kubectl >/dev/null || { echo "kubectl is required" >&2; exit 1; }
command -v helm >/dev/null || { echo "helm is required" >&2; exit 1; }

echo "[1/4] Updating kubeconfig for ${CLUSTER_NAME}"
aws eks update-kubeconfig --name "${CLUSTER_NAME}" --region "${AWS_REGION}"

echo "[2/4] Applying AWS Load Balancer Controller CRDs from app tag ${CONTROLLER_APP_VERSION}"
kubectl apply -k "github.com/kubernetes-sigs/aws-load-balancer-controller/config/crd?ref=${CONTROLLER_APP_VERSION}"

echo "[3/4] Adding EKS Helm repository"
helm repo add eks https://aws.github.io/eks-charts
helm repo update eks

echo "[4/4] Installing AWS Load Balancer Controller chart ${HELM_CHART_VERSION}"
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  --namespace "${SERVICE_ACCOUNT_NAMESPACE}" \
  --version "${HELM_CHART_VERSION}" \
  --set "clusterName=${CLUSTER_NAME}" \
  --set "region=${AWS_REGION}" \
  --set "serviceAccount.create=true" \
  --set "serviceAccount.name=${SERVICE_ACCOUNT_NAME}" \
  --set "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn=${ROLE_ARN}" \
  --wait

kubectl rollout status deployment/aws-load-balancer-controller \
  --namespace "${SERVICE_ACCOUNT_NAMESPACE}" \
  --timeout=180s

echo "AWS Load Balancer Controller is installed."
