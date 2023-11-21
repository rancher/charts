# Rancher

{{- define "system_default_registry" -}}
{{- if .Values.global.cattle.systemDefaultRegistry -}}
{{- printf "%s/" .Values.global.cattle.systemDefaultRegistry -}}
{{- end -}}
{{- end -}}

# Windows Support

{{/*
Windows cluster will add default taint for linux nodes,
add below linux tolerations to workloads could be scheduled to those linux nodes
*/}}

{{- define "linux-node-tolerations" -}}
- key: "cattle.io/os"
  value: "linux"
  effect: "NoSchedule"
  operator: "Equal"
{{- end -}}

{{- define "linux-node-selector" -}}
{{- if semverCompare "<1.14-0" .Capabilities.KubeVersion.GitVersion -}}
beta.kubernetes.io/os: linux
{{- else -}}
kubernetes.io/os: linux
{{- end -}}
{{- end -}}

# General

{{- define "applyKubeVersionOverrides" -}}
{{- $overrides := dict -}}
{{- range $override := .Values.kubeVersionOverrides -}}
{{- if semverCompare $override.constraint $.Capabilities.KubeVersion.Version -}}
{{- $_ := mergeOverwrite $overrides $override.values -}}
{{- end -}}
{{- end -}}
{{- $_ := mergeOverwrite .Values $overrides -}}
{{- end -}}

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
{{ printf "http://%s.%s.svc:%d" (include "pushProxy.proxy.name" .) (include "pushprox.namespace" .) (int .Values.proxy.port) }}
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
{{ template "pushProxy.commonLabels" . }}
{{- end -}}

{{- define "pushProxy.serviceMonitor.endpoints" -}}
{{- $proxyURL := (include "pushProxy.proxyUrl" .) -}}
{{- $useHTTPS := .Values.clients.https.enabled -}}
{{- $endpoints := .Values.serviceMonitor.endpoints }}
{{- range $endpoints }}
{{- if $.Values.proxy.enabled }}
{{- $_ := set . "proxyUrl" $proxyURL }}
{{- end }}
{{- $clusterIdRelabel := dict }}
{{- if $.Values.global.cattle.clusterId }}
{{- $_ := set $clusterIdRelabel "action" "replace" }}
{{- $_ := set $clusterIdRelabel "sourceLabels" (list "__address__") }}
{{- $_ := set $clusterIdRelabel "targetLabel" "cluster_id" }}
{{- $_ := set $clusterIdRelabel "replacement" $.Values.global.cattle.clusterId }}
{{- end }}
{{- $clusterNameRelabel := dict }}
{{- if $.Values.global.cattle.clusterName }}
{{- $_ := set $clusterNameRelabel "action" "replace" }}
{{- $_ := set $clusterNameRelabel "sourceLabels" (list "__address__") }}
{{- $_ := set $clusterNameRelabel "targetLabel" "cluster_name" }}
{{- $_ := set $clusterNameRelabel "replacement" $.Values.global.cattle.clusterName }}
{{- end }}
{{- $metricRelabelings := append (list ($clusterNameRelabel)) ($clusterIdRelabel) }}
{{- $_ := set . "metricRelabelings" ($metricRelabelings)}}
{{- if $useHTTPS -}}
{{- if (hasKey . "params") }}
{{- $_ := set (get . "params") "_scheme" (list "https") }}
{{- else }}
{{- $_ := set . "params" (dict "_scheme" (list "https")) }}
{{- end }}
{{- end }}
{{- end }}
{{- toYaml $endpoints }}
{{- end -}}