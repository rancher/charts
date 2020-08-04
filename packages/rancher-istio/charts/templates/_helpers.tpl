{{/* Ensure namespace is set the same everywhere */}}
{{- define "istio.namespace" -}}
  {{- .Release.Namespace | default "istio-system" -}}
{{- end -}}
