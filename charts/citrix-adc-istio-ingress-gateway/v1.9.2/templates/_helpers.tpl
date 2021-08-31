{{- define "exporter_nsip" -}}
{{- $match := .Values.istioAdaptor.netscalerUrl | toString | regexFind "//.*[:]*" -}}
{{- $match | trimAll ":" | trimAll "/" -}}
{{- end -}}
