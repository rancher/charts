{{/* vim: set filetype=mustache: */}}
{{/*
Analytics Server IP or DNS
*/}}
{{- define "analytics.server" -}}
{{- if .Values.coeConfig.endpoint.server -}}
{{- printf .Values.coeConfig.endpoint.server -}}
{{- else -}}
{{- printf "coe.%s.svc.cluster.local" .Release.Namespace -}}
{{- end -}}
{{- end -}}
