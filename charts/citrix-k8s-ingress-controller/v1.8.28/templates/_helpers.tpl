{{/* vim: set filetype=mustache: */}}
{{/*
Analytics Server IP or DNS
*/}}
{{- define "analytics.server" -}}
{{- if .Values.coeConfig.endpoint.server -}}
{{- printf .Values.coeConfig.endpoint.server -}}
{{- else -}}
{{- $addresses := first (first (lookup "v1" "Node" "" "").items).status.addresses -}}
{{- printf "%s" ($addresses).address -}}
{{- end -}}
{{- end -}}
