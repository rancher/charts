{{/*
Expand the name of the chart.
*/}}
{{- define "rancher-supportability-review.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "rancher-supportability-review.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "rancher-supportability-review.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "rancher-supportability-review.labels" -}}
helm.sh/chart: {{ include "rancher-supportability-review.chart" . }}
{{ include "rancher-supportability-review.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "rancher-supportability-review.selectorLabels" -}}
app.kubernetes.io/name: {{ include "rancher-supportability-review.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "rancher-supportability-review.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "rancher-supportability-review.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/* Ensure namespace is set the same everywhere */}}
{{- define "sr.namespace" -}}
  {{- .Release.Namespace | default "sr-operator-system" -}}
{{- end -}}

{{- define "system_default_registry" -}}
{{- if .Values.global.cattle.systemDefaultRegistry -}}
{{- printf "%s/" .Values.global.cattle.systemDefaultRegistry -}}
{{- else -}}
{{- "" -}}
{{- end -}}
{{- end -}}

{{/*
Windows cluster will add default taint for linux nodes,
add below linux tolerations to workloads could be scheduled to those linux nodes
*/}}
{{- define "linux-node-tolerations" -}}
- key: "cattle.io/os"
  value: "linux"
  effect: "NoSchedule"
  operator: "Equal"
{{- end -}}

{{- define "linux-node-selector" -}}
kubernetes.io/os: linux
{{- end -}}
