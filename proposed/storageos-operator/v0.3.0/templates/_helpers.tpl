{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "storageos.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "storageos.fullname" -}}
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
{{- define "storageos.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "storageos.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "storageos.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Validate the admin username to be of minimum length
*/}}
{{- define "validate-username" -}}
{{ $length := len .Values.cluster.admin.username }}
{{- if ge $length 3 -}}
{{ .Values.cluster.admin.username }}
{{- else -}}
{{- fail "Invalid username. Must be at least 3 characters." -}}
{{- end -}}
{{- end -}}

{{/*
Validate the admin password to be of minimum length
*/}}
{{- define "validate-password" -}}
{{ $length := len .Values.cluster.admin.password }}
{{- if ge $length 8 -}}
{{ .Values.cluster.admin.password }}
{{- else -}}
{{- fail "Invalid password. Must be at least 8 characters." -}}
{{- end -}}
{{- end -}}
