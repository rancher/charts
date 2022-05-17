{{/* Ensure namespace is set the same everywhere */}}
{{- define "istio.namespace" -}}
  {{- .Release.Namespace | default "istio-system" -}}
{{- end -}}

{{- define "system_default_registry" -}}
{{- if .Values.global.cattle.systemDefaultRegistry -}}
{{- printf "%s/" .Values.global.cattle.systemDefaultRegistry -}}
{{- else -}}
{{- "" -}}
{{- end -}}
{{- end -}}
