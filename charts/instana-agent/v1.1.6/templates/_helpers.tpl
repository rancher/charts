{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "instana-agent.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "instana-agent.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "instana-agent.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
The name of the ServiceAccount used.
*/}}
{{- define "instana-agent.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "instana-agent.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
The name of the PodSecurityPolicy used.
*/}}
{{- define "instana-agent.podSecurityPolicyName" -}}
{{- if .Values.podSecurityPolicy.enable -}}
{{ default (include "instana-agent.fullname" .) .Values.podSecurityPolicy.name }}
{{- end -}}
{{- end -}}

{{/*
Prints out the name of the secret to use to retrieve the agent key
*/}}
{{- define "instana-agent.keysSecretName" -}}
{{- if .Values.agent.keysSecret -}}
{{ .Values.agent.keysSecret }}
{{- else -}}
{{ template "instana-agent.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Add Helm metadata to resource labels.
*/}}
{{- define "instana-agent.commonLabels" -}}
app.kubernetes.io/name: {{ include "instana-agent.name" . }}
app.kubernetes.io/version: {{ .Chart.Version }}
{{ if not .Values.templating -}}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ include "instana-agent.chart" . }}
{{- end -}}
{{- end -}}

{{/*
Add Helm metadata to selector labels specifically for deployments/daemonsets/statefulsets.
*/}}
{{- define "instana-agent.selectorLabels" -}}
app.kubernetes.io/name: {{ include "instana-agent.name" . }}
{{- if not .Values.templating }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
{{- end -}}

{{/*
Generates the dockerconfig for the credentials to pull from containers.instana.io
*/}}
{{- define "imagePullSecretContainersInstanaIo" }}
{{- $registry := "containers.instana.io" }}
{{- $username := "_" }}
{{- $password := default .Values.agent.key .Values.agent.downloadKey }}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" $registry (printf "%s:%s" $username $password | b64enc) | b64enc }}
{{- end }}

{{/*
Ensure a unit of memory measurement is added to the value
*/}}
{{- define "ensureMemoryMeasurement" }}
{{- $value := .memory }}
{{- if kindIs "int" $value }}
{{- printf "%d%s" $value "Mi" }}
{{- else if (kindIs "float64" $value) }}
{{- printf "%f%s" $value "Mi" }}
{{- else }}
{{- printf "%s" $value }}
{{- end }}
{{- end }}