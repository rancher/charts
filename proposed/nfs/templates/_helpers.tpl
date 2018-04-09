{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "nfs.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "nfs.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "nfs.apiversion" -}}
{{- if .Capabilities.APIVersions.Has "apps/v1" -}}
{{- "apps/v1" -}}
{{- else if .Capabilities.APIVersions.Has "extensions/v1beta2" -}}
{{- "extensions/v1beta2" -}}
{{- else if .Capabilities.APIVersions.Has "extensions/v1beta1" -}}
{{- "extensions/v1beta1" -}}
{{- end -}}
{{- end -}}
