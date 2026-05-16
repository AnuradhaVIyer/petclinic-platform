{{/*
helm/petclinic-service/templates/_helpers.tpl
*/}}

{{/* Chart name */}}
{{- define "petclinic-service.name" -}}
{{- .Release.Name }}
{{- end }}

{{/* Common labels applied to every resource */}}
{{- define "petclinic-service.labels" -}}
app.kubernetes.io/name: {{ include "petclinic-service.name" . }}
app.kubernetes.io/part-of: petclinic
app.kubernetes.io/managed-by: Helm
app.kubernetes.io/component: {{ .Values.component }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end }}

{{/* Selector labels — used in Deployment.spec.selector and Service.spec.selector */}}
{{- define "petclinic-service.selectorLabels" -}}
app.kubernetes.io/name: {{ include "petclinic-service.name" . }}
{{- end }}
