# Helm Chart — `petclinic-service`

Generic Helm chart shared by all 8 Spring Petclinic microservices.
One chart, per-service values files, per-environment overrides.

## Structure

```
helm/petclinic-service/        # The chart (one chart for all 8 services)
  Chart.yaml
  values.yaml                  # Defaults — do not edit per-service here
  templates/
    _helpers.tpl               # Common labels, name helpers
    deployment.yaml
    service.yaml
    configmap.yaml
    serviceaccount.yaml
    hpa.yaml                   # Only renders when autoscaling.enabled=true
    pdb.yaml                   # Only renders when podDisruptionBudget.enabled=true

helm-values/                   # Per-service and per-env overrides
  config-server.yaml
  discovery-server.yaml
  api-gateway.yaml
  customers-service.yaml
  visits-service.yaml
  vets-service.yaml
  genai-service.yaml
  admin-server.yaml
  dev.yaml                     # Dev env overrides (replicas=1, no HPA, no PDB)
  prod.yaml                    # Prod env overrides (replicas=2, HPA, PDB)
```

## Values Hierarchy

Helm merges values in order — last file wins:

```
values.yaml (chart defaults)
  ↓ overridden by
helm-values/{service}.yaml (port, init containers, env vars, secret refs)
  ↓ overridden by
helm-values/{env}.yaml (replica count, HPA, PDB)
  ↓ overridden by
--set image.tag=${SHA} (CI injects the commit SHA at deploy time)
```

## Deploy Command

```bash
# Deploy a single service to dev
helm upgrade --install customers-service helm/petclinic-service/ \
  -n petclinic-dev \
  -f helm-values/customers-service.yaml \
  -f helm-values/dev.yaml \
  --set image.tag=${SHA}

# Deploy to prod
helm upgrade --install customers-service helm/petclinic-service/ \
  -n petclinic-prod \
  -f helm-values/customers-service.yaml \
  -f helm-values/prod.yaml \
  --set image.tag=${SHA}
```

## Deploy All Services (dev)

```bash
SERVICES="config-server discovery-server api-gateway customers-service visits-service vets-service genai-service admin-server"
SHA=$(git rev-parse --short HEAD)

for svc in $SERVICES; do
  helm upgrade --install $svc helm/petclinic-service/ \
    -n petclinic-dev \
    -f helm-values/${svc}.yaml \
    -f helm-values/dev.yaml \
    --set image.tag=${SHA}
done
```

## Validate Templates Locally

```bash
# Render and inspect (dry-run)
helm template customers-service helm/petclinic-service/ \
  -f helm-values/customers-service.yaml \
  -f helm-values/dev.yaml \
  --set image.tag=abc1234

# Lint
helm lint helm/petclinic-service/ \
  -f helm-values/customers-service.yaml \
  -f helm-values/dev.yaml
```

## Conventions

### Image Tags
CI updates `image.tag` in each per-service values file via `yq`:
```bash
yq -i ".image.tag = \"${SHA}\"" helm-values/customers-service.yaml
```
ArgoCD detects the Git change and syncs automatically (dev) or queues for approval (prod).

### HPA and PDB
- **HPA** renders only when `autoscaling.enabled: true` in the merged values.
- **PDB** renders only when `podDisruptionBudget.enabled: true`.
- In dev: both are disabled (`dev.yaml` sets `enabled: false`).
- In prod: enabled by `prod.yaml`, with per-service `minReplicas`/`maxReplicas` set in each service file.

### Init Containers
Init containers are defined in each per-service values file as a list under `initContainers:`.
The deployment template injects them verbatim. All use `busybox:1.36` wget loops.

Startup order:
- `config-server` — no init containers (starts first)
- `discovery-server` — waits for config-server
- All others — wait for config-server, then discovery-server

### Secret References
Secrets are synced from AWS Secrets Manager to Kubernetes Secrets by the
External Secrets Operator (ESO). The secret names and keys in per-service
values files must match exactly:

| Service | Secret Name | Key(s) |
|---------|-------------|--------|
| customers/visits/vets | `rds-credentials` | `username`, `password` |
| genai-service | `openai-api-key` | `OPENAI_API_KEY` |

### Security Context
All containers run with:
- `runAsNonRoot: true`, `runAsUser: 1000`, `fsGroup: 1000`
- `seccompProfile: RuntimeDefault`
- `allowPrivilegeEscalation: false`, `capabilities.drop: ALL`
- `readOnlyRootFilesystem: false` — Spring Boot needs `/tmp`

Init containers use `readOnlyRootFilesystem: true` (they only run `wget`).

## ArgoCD Integration

ArgoCD `Application` CRDs reference this chart and merge values automatically.
See `k8s/argocd/applications/{dev,prod}/` for the Application manifests.

Each Application uses:
```yaml
source:
  path: helm/petclinic-service
  helm:
    valueFiles:
      - ../../helm-values/{service}.yaml
      - ../../helm-values/{env}.yaml
```
