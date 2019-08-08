{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "vault-operator.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "vault-operator.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "vault-operator.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Define vault operator service account name
*/}}
{{- define "vault-operator.sa" -}}
{{- printf "%s-sa" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Define vault operator role name
*/}}
{{- define "vault-operator.role" -}}
{{- printf "%s-role" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Define vault operator rolebinding name
*/}}
{{- define "vault-operator.rolebinding" -}}
{{- printf "%s-rolebinding" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Define vault ui fullname
*/}}
{{- define "vault.ui.fullname" -}}
{{- printf "%s-ui" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Define vault service url for the ui
*/}}
{{- define "vault.service.url" -}}
{{- printf "https://%s:8200" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

