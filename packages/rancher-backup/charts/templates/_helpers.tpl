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


{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "backupRestore.fullname" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "backupRestore.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "backupRestore.labels" -}}
helm.sh/chart: {{ include "backupRestore.chart" . }}
{{ include "backupRestore.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "backupRestore.selectorLabels" -}}
app.kubernetes.io/name: {{ include "backupRestore.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
resources.cattle.io/operator: backup-restore
{{- end }}


{{/*
Create the name of the service account to use
*/}}
{{- define "backupRestore.serviceAccountName" -}}
{{ include "backupRestore.fullname" . }}
{{- end }}


{{- define "backupRestore.s3SecretName" -}}
{{- printf "%s-%s" .Chart.Name "s3" | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "backupRestore.pvcName" -}}
{{ include "backupRestore.fullname" . }}
{{- end }}

{{- define "backupRestore.nfsPVName" -}}
{{ include "backupRestore.fullname" . }}
{{- end }}
