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

{{- define "pushProxy.client.serviceAccountTokenName" -}}
{{- printf "pushprox-%s-client-service-account-token" (required ".Values.component is required" .Values.component) -}}
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
{{- $setHTTPSScheme := .Values.clients.https.forceHTTPSScheme -}}
{{- $insecureSkipVerify := .Values.clients.https.insecureSkipVerify -}}
{{- $useServiceAccountCredentials := .Values.clients.https.useServiceAccountCredentials -}}
{{- $serviceAccountTokenName := (include "pushProxy.client.serviceAccountTokenName" . ) -}}
{{- $metricRelabelings := list }}
{{- $endpoints := .Values.serviceMonitor.endpoints }}
{{- if .Values.proxy.enabled }}
{{- $_ := set . "proxyUrl" $proxyURL }}
{{- end }}
{{- range $endpoints }}
{{- if $.Values.proxy.enabled }}
{{- $_ := set . "proxyUrl" $proxyURL }}
{{- end }}
{{- $clusterIdRelabel := dict }}
{{- $metricRelabelings := list }}
{{- if $.Values.global.cattle.clusterId }}
{{- $_ := set $clusterIdRelabel "action" "replace" }}
{{- $_ := set $clusterIdRelabel "sourceLabels" (list "__address__") }}
{{- $_ := set $clusterIdRelabel "targetLabel" "cluster_id" }}
{{- $_ := set $clusterIdRelabel "replacement" $.Values.global.cattle.clusterId }}
{{- $metricRelabelings = append $metricRelabelings $clusterIdRelabel }}
{{- end }}
{{- $clusterNameRelabel := dict }}
{{- if $.Values.global.cattle.clusterName }}
{{- $_ := set $clusterNameRelabel "action" "replace" }}
{{- $_ := set $clusterNameRelabel "sourceLabels" (list "__address__") }}
{{- $_ := set $clusterNameRelabel "targetLabel" "cluster_name" }}
{{- $_ := set $clusterNameRelabel "replacement" $.Values.global.cattle.clusterName }}
{{- $metricRelabelings = append $metricRelabelings $clusterNameRelabel }}
{{- end }}
{{- if not (empty $metricRelabelings) }}
{{- $_ := set . "metricRelabelings" ($metricRelabelings)}}
{{- end }}
{{- if $setHTTPSScheme -}}
{{- $_ := set . "scheme" "https" }}
{{- end -}}
{{- if $useHTTPS -}}
{{- if (hasKey . "params") }}
{{- $_ := set (get . "params") "_scheme" (list "https") }}
{{- else }}
{{- $_ := set . "params" (dict "_scheme" (list "https")) }}
{{- end }}
{{- end }}
{{- if (hasKey . "tlsConfig") }}
{{- $_ := set (get . "tlsConfig") "insecureSkipVerify" $insecureSkipVerify }}
{{- else }}
{{- $_ := set . "tlsConfig" (dict "insecureSkipVerify" $insecureSkipVerify) }}
{{- end }}
{{- if $.Values.clients.https.authenticationMethod.bearerTokenFile.enabled }}
{{- $_ := set . "bearerTokenFile" $.Values.clients.https.authenticationMethod.bearerTokenFile.bearerTokenFilePath }}
{{- end }}
{{- if $.Values.clients.https.authenticationMethod.bearerTokenSecret.enabled }}
{{- $_ := set . "bearerTokenSecret" $serviceAccountTokenName }}
{{- end }}
{{- if $.Values.clients.https.authenticationMethod.authorization.enabled }}
{{- if (hasKey . "authorization") }}
{{- $_ := set (get . "authorization") "type" $.Values.clients.https.authenticationMethod.authorization.type }}
{{- $_ := set (get . "authorization") "credentials" (dict "name" $serviceAccountTokenName "key" $.Values.clients.https.authenticationMethod.authorization.credentials.key "optional" $.Values.clients.https.authenticationMethod.authorization.credentials.optional) }}
{{- else }}
{{- $_ := set . "authorization" (dict "type" $.Values.clients.https.authenticationMethod.authorization.type) }}
{{- $_ := set . "authorization" (dict "credentials" (dict "name" $serviceAccountTokenName "key" $.Values.clients.https.authenticationMethod.authorization.credentials.key "optional" $.Values.clients.https.authenticationMethod.authorization.credentials.optional)) }}
{{- end }}
{{- end }}
{{- end }}
{{- toYaml $endpoints }}
{{- end -}}
