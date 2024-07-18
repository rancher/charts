{{/*
Expand the name of the chart.
*/}}
{{- define "epinio-ui.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "epinio-ui.fullname" -}}
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
{{- define "epinio-ui.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "epinio-ui.labels" -}}
helm.sh/chart: {{ include "epinio-ui.chart" . }}
{{ include "epinio-ui.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "epinio-ui.selectorLabels" -}}
app.kubernetes.io/name: {{ include "epinio-ui.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "epinio-ui.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "epinio-ui.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
URL registry prefix for container images (Rancher compatibility support)
*/}}
{{- define "epinio-ui.registry" -}}
{{- if .Values.global.cattle -}}
{{- if .Values.global.cattle.systemDefaultRegistry -}}
{{ trimSuffix "/" .Values.global.cattle.systemDefaultRegistry }}/
{{- else -}}
{{ if .Values.epinioUI.image.registry }}
{{ .Values.epinioUI.image.registry }}/
{{- end -}}
{{- end -}}
{{- else -}}
{{ if .Values.epinioUI.image.registry }}
{{ .Values.epinioUI.image.registry }}/
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Windows cluster will add default taint for linux nodes, add below linux tolerations to
workloads could be scheduled to those linux nodes
*/}}
{{- define "linux-node-tolerations" -}}
- key: "cattle.io/os"
  value: "linux"
  effect: "NoSchedule"
  operator: "Equal"
{{- end -}}

{{- define "linux-node-selector" -}}
{{- if semverCompare "<1.14-0" .Capabilities.KubeVersion.GitVersion -}}
beta.kubernetes.io/os: linux
{{- else -}}
kubernetes.io/os: linux
{{- end -}}
{{- end -}}
