# Rancher

{{- define "system_default_registry" -}}
{{- if .Values.global.cattle.systemDefaultRegistry -}}
{{- printf "%s/" .Values.global.cattle.systemDefaultRegistry -}}
{{- end -}}
{{- end -}}

# General

{{- define "pushprox.namespace" -}}
  {{- if .Values.namespaceOverride -}}
    {{- .Values.namespaceOverride -}}
  {{- else -}}
    {{- .Release.Namespace -}}
  {{- end -}}
{{- end -}}

{{- define "pushProxy.commonLabels" -}}
release: {{ .Release.Name }}
component: {{ .Values.component | quote }}
provider: kubernetes
{{- end -}}

{{- define "pushProxy.proxyUrl" -}}
{{- $_ := (required "Template requires either .Values.proxy.port or .Values.client.proxyUrl to set proxyUrl for client" (or .Values.clients.proxyUrl .Values.proxy.port)) -}}
{{- if .Values.clients.proxyUrl -}}
{{ printf "%s" .Values.clients.proxyUrl }}
{{- else -}}
{{ printf "http://%s.%s.svc.cluster.local:%d" (include "pushProxy.proxy.name" .) .Release.Namespace (int .Values.proxy.port) }}
{{- end -}}{{- end -}}

# Client

{{- define "pushProxy.client.name" -}}
{{- printf "pushprox-%s-client" (required ".Values.component is required" .Values.component) -}}
{{- end -}}

{{- define "pushProxy.client.labels" -}}
k8s-app: {{ template "pushProxy.client.name" . }}
{{ template "pushProxy.commonLabels" . }}
{{- end -}}

# Proxy

{{- define "pushProxy.proxy.name" -}}
{{- printf "pushprox-%s-proxy" (required ".Values.component is required" .Values.component) -}}
{{- end -}}

{{- define "pushProxy.proxy.labels" -}}
k8s-app: {{ template "pushProxy.proxy.name" . }}
{{ template "pushProxy.commonLabels" . }}
{{- end -}}

# ServiceMonitor

{{- define "pushprox.serviceMonitor.name" -}}
{{- printf "%s-%s" .Release.Name (required ".Values.component is required" .Values.component) -}}
{{- end -}}

{{- define "pushProxy.serviceMonitor.labels" -}}
app: {{ template "pushprox.serviceMonitor.name" . }}
release: {{ .Release.Name | quote }}
{{ template "pushProxy.commonLabels" . }}
{{- end -}}