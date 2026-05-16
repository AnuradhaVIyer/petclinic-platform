#!/usr/bin/env bash
# scripts/test-gitops-loop.sh
#
# Smoke-tests the ArgoCD GitOps loop for the dev environment.
# Verifies: ArgoCD is running, all dev Applications exist and are Synced/Healthy.
#
# Usage:
#   ./scripts/test-gitops-loop.sh
#
# Prerequisites:
#   - kubectl configured against the EKS cluster
#   - argocd CLI installed (https://argo-cd.readthedocs.io/en/stable/cli_installation/)
#   - ArgoCD port-forward running:
#       kubectl port-forward svc/argocd-server -n argocd 8443:443
#   - ARGOCD_PASSWORD env var set (or script will fetch it from the secret)
# PETPLAT-116

set -euo pipefail

ARGOCD_SERVER="localhost:8443"
ARGOCD_USER="admin"
NAMESPACE_DEV="petclinic-dev"

SERVICES=(
  config-server
  discovery-server
  api-gateway
  customers-service
  visits-service
  vets-service
  genai-service
  admin-server
)

PASS=0
FAIL=0

log()  { echo "[INFO]  $*"; }
ok()   { echo "[OK]    $*"; ((PASS++)); }
fail() { echo "[FAIL]  $*"; ((FAIL++)); }

# ---------------------------------------------------------------------------
# 1. ArgoCD namespace and server pod
# ---------------------------------------------------------------------------
log "Checking ArgoCD server pod..."
if kubectl -n argocd get pods -l app.kubernetes.io/name=argocd-server \
    --field-selector=status.phase=Running --no-headers 2>/dev/null | grep -q Running; then
  ok "argocd-server is Running"
else
  fail "argocd-server not Running"
fi

# ---------------------------------------------------------------------------
# 2. Login to ArgoCD CLI
# ---------------------------------------------------------------------------
log "Logging in to ArgoCD..."
if [[ -z "${ARGOCD_PASSWORD:-}" ]]; then
  ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret \
    -o jsonpath="{.data.password}" | base64 -d)
fi

argocd login "${ARGOCD_SERVER}" \
  --username "${ARGOCD_USER}" \
  --password "${ARGOCD_PASSWORD}" \
  --insecure --grpc-web 2>/dev/null && ok "ArgoCD CLI login succeeded" \
  || { fail "ArgoCD CLI login failed"; exit 1; }

# ---------------------------------------------------------------------------
# 3. Check each dev Application: exists, Synced, Healthy
# ---------------------------------------------------------------------------
log "Checking dev Application CRDs..."
for SVC in "${SERVICES[@]}"; do
  APP="${SVC}-dev"
  STATUS=$(argocd app get "${APP}" --output json 2>/dev/null \
    | python3 -c "
import sys, json
d = json.load(sys.stdin)
sync   = d['status']['sync']['status']
health = d['status']['health']['status']
print(f'{sync}/{health}')
" 2>/dev/null || echo "NOT_FOUND/NOT_FOUND")

  SYNC="${STATUS%%/*}"
  HEALTH="${STATUS##*/}"

  if [[ "${SYNC}" == "Synced" && "${HEALTH}" == "Healthy" ]]; then
    ok "${APP}: Synced / Healthy"
  elif [[ "${STATUS}" == "NOT_FOUND/NOT_FOUND" ]]; then
    fail "${APP}: Application not found in ArgoCD"
  else
    fail "${APP}: ${SYNC} / ${HEALTH}"
  fi
done

# ---------------------------------------------------------------------------
# 4. Check all pods in petclinic-dev are Running
# ---------------------------------------------------------------------------
log "Checking pods in ${NAMESPACE_DEV}..."
NOT_RUNNING=$(kubectl -n "${NAMESPACE_DEV}" get pods --no-headers 2>/dev/null \
  | grep -v "Running\|Completed" | wc -l | tr -d ' ')

if [[ "${NOT_RUNNING}" -eq 0 ]]; then
  ok "All pods in ${NAMESPACE_DEV} are Running"
else
  fail "${NOT_RUNNING} pod(s) in ${NAMESPACE_DEV} are not Running:"
  kubectl -n "${NAMESPACE_DEV}" get pods --no-headers | grep -v "Running\|Completed" || true
fi

# ---------------------------------------------------------------------------
# 5. Trigger a manual sync on one app and verify it completes (loop test)
# ---------------------------------------------------------------------------
log "Testing GitOps sync loop: triggering sync on config-server-dev..."
if argocd app sync config-server-dev --timeout 120 2>/dev/null; then
  ok "config-server-dev sync completed successfully"
else
  fail "config-server-dev sync failed or timed out"
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "============================================"
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo "============================================"
[[ "${FAIL}" -eq 0 ]]
