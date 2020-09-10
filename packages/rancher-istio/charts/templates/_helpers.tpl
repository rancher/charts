{{/* Ensure namespace is set the same everywhere */}}
{{- define "istio.namespace" -}}
  {{- .Release.Namespace | default "istio-system" -}}
{{- end -}}

{{- define "system_default_registry" -}}
{{- if .Values.global.systemDefaultRegistry -}}
{{- printf "%s/" .Values.global.systemDefaultRegistry -}}
{{- else -}}
{{- "" -}}
{{- end -}}
{{- end -}}
