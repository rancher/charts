{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "stackstate-k8s-agent.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "stackstate-k8s-agent.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Release name of the chart. Can be used in subcharts because it does not use anything from .Values
*/}}
{{- define "stackstate-k8s-agent.releasename" -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "stackstate-k8s-agent.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "stackstate-k8s-agent.labels" -}}
app.kubernetes.io/name: {{ include "stackstate-k8s-agent.name" . }}
helm.sh/chart: {{ include "stackstate-k8s-agent.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Cluster agent checksum annotations
*/}}
{{- define "stackstate-k8s-agent.checksum-configs" }}
checksum/secret: {{ include (print $.Template.BasePath "/secret.yaml") . | sha256sum }}
{{- end }}

{{/*
StackState URL function
*/}}
{{- define "stackstate-k8s-agent.stackstate.url" -}}
{{- if not (hasPrefix "http" (tpl .Values.stackstate.url .)) -}}
{{- fail "SUSE Observability Ingest URL should start with the http or https protocol." -}}
{{- end -}}
{{ tpl .Values.stackstate.url . | quote }}
{{- end }}

{{- define "stackstate-k8s-agent.configmap.override.checksum" -}}
{{- if .Values.clusterAgent.config.override }}
checksum/override-configmap: {{ include (print $.Template.BasePath "/cluster-agent-configmap.yaml") . | sha256sum }}
{{- end }}
{{- end }}

{{- define "stackstate-k8s-agent.nodeAgent.configmap.override.checksum" -}}
{{- if .Values.nodeAgent.config.override }}
checksum/override-configmap: {{ include (print $.Template.BasePath "/node-agent-configmap.yaml") . | sha256sum }}
{{- end }}
{{- end }}

{{- define "stackstate-k8s-agent.logsAgent.configmap.override.checksum" -}}
checksum/override-configmap: {{ include (print $.Template.BasePath "/logs-agent-configmap.yaml") . | sha256sum }}
{{- end }}

{{- define "stackstate-k8s-agent.checksAgent.configmap.override.checksum" -}}
{{- if .Values.checksAgent.config.override }}
checksum/override-configmap: {{ include (print $.Template.BasePath "/checks-agent-configmap.yaml") . | sha256sum }}
{{- end }}
{{- end }}


{{/*
Return the image registry
*/}}
{{- define "stackstate-k8s-agent.imageRegistry" -}}
  {{- if .Values.global }}
    {{- .Values.global.imageRegistry | default .Values.all.image.registry -}}
  {{- else -}}
    {{- .Values.all.image.registry -}}
  {{- end -}}
{{- end -}}

{{/*
Renders a value that contains a template.
Usage:
{{ include "stackstate-k8s-agent.tplvalue.render" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "stackstate-k8s-agent.tplvalue.render" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}

{{- define "stackstate-k8s-agent.pull-secret.name" -}}
{{ include "stackstate-k8s-agent.fullname" . }}-pull-secret
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names evaluating values as templates
{{ include "stackstate-k8s-agent.image.pullSecrets" ( dict "images" (list .Values.path.to.the.image1, .Values.path.to.the.image2) "context" $) }}
*/}}
{{- define "stackstate-k8s-agent.image.pullSecrets" -}}
  {{- $pullSecrets := list }}
  {{- $context := .context }}
  {{- if $context.Values.global }}
    {{- range $context.Values.global.imagePullSecrets -}}
      {{/* Is plain array of strings, compatible with all bitnami charts */}}
      {{- $pullSecrets = append $pullSecrets (include "stackstate-k8s-agent.tplvalue.render" (dict "value" . "context" $context)) -}}
    {{- end -}}
  {{- end -}}
  {{- range $context.Values.imagePullSecrets -}}
    {{- $pullSecrets = append $pullSecrets (include "stackstate-k8s-agent.tplvalue.render" (dict "value" .name "context" $context)) -}}
  {{- end -}}
  {{- range .images -}}
    {{- if .pullSecretName -}}
      {{- $pullSecrets = append $pullSecrets (include "stackstate-k8s-agent.tplvalue.render" (dict "value" .pullSecretName "context" $context)) -}}
    {{- end -}}
  {{- end -}}
  {{- $pullSecrets = append $pullSecrets (include "stackstate-k8s-agent.pull-secret.name" $context)  -}}
  {{- if (not (empty $pullSecrets)) -}}
imagePullSecrets:
    {{- range $pullSecrets | uniq }}
  - name: {{ . }}
    {{- end }}
  {{- end }}
{{- end -}}

{{/*
Check whether the kubernetes-state-metrics configuration is overridden. If so, return 'true' else return nothing (which is false).
{{ include "stackstate-k8s-agent.kube-state-metrics.overridden" $ }}
*/}}
{{- define "stackstate-k8s-agent.kube-state-metrics.overridden" -}}
{{- if .Values.clusterAgent.config.override }}
  {{- range $i, $val := .Values.clusterAgent.config.override }}
    {{- if and (eq $val.name "conf.yaml") (eq $val.path "/etc/stackstate-agent/conf.d/kubernetes_state.d") }}
true
    {{- end }}
  {{- end }}
{{- end }}
{{- end -}}

{{- define "stackstate-k8s-agent.nodeAgent.kube-state-metrics.overridden" -}}
{{- if .Values.nodeAgent.config.override }}
  {{- range $i, $val := .Values.nodeAgent.config.override }}
    {{- if and (eq $val.name "auto_conf.yaml") (eq $val.path "/etc/stackstate-agent/conf.d/kubernetes_state.d") }}
true
    {{- end }}
  {{- end }}
{{- end }}
{{- end -}}

{{/*
Return the appropriate os label
*/}}
{{- define "label.os" -}}
{{- if semverCompare "^1.14-0" .Capabilities.KubeVersion.GitVersion -}}
kubernetes.io/os
{{- else -}}
beta.kubernetes.io/os
{{- end -}}
{{- end -}}

{{/*
Returns a YAML with extra annotations
*/}}
{{- define "stackstate-k8s-agent.global.extraAnnotations" -}}
{{- with .Values.global.extraAnnotations }}
{{- toYaml . }}
{{- end }}
{{- end -}}

{{/*
Returns a YAML with extra labels
*/}}
{{- define "stackstate-k8s-agent.global.extraLabels" -}}
{{- with .Values.global.extraLabels }}
{{- toYaml . }}
{{- end }}
{{- end -}}

{{- define "stackstate-k8s-agent.apiKeyEnv" -}}
- name: STS_API_KEY
  valueFrom:
    secretKeyRef:
{{- if .Values.stackstate.manageOwnSecrets }}
      name: {{ .Values.stackstate.customSecretName | quote }}
      key: {{ .Values.stackstate.customApiKeySecretKey | quote }}
{{- else }}
      name: {{ tpl .Values.global.apiKey.fromSecret . | quote }}
      key: STS_API_KEY
{{- end }}
{{- end -}}

{{- define "stackstate-k8s-agent.clusterAgentAuthTokenEnv" -}}
- name: STS_CLUSTER_AGENT_AUTH_TOKEN
  valueFrom:
    secretKeyRef:
{{- if .Values.stackstate.manageOwnSecrets }}
      name: {{ .Values.stackstate.customSecretName | quote }}
      key: {{ .Values.stackstate.customClusterAuthTokenSecretKey | quote }}
{{- else }}
      name: {{ tpl .Values.global.clusterAgentAuthToken.fromSecret . | quote }}
      key: STS_CLUSTER_AGENT_AUTH_TOKEN
{{- end }}
{{- end -}}

{{- define "stackstate-k8s-agent.externalOrInternal" -}}
{{- if .external }}
{{- tpl .external . }}
{{- else }}
{{- template "stackstate-k8s-agent.releasename" . }}-{{ .internalName }}
{{- end }}
{{- end }}

{{- define "stackstate-k8s-agent.secret.internal.name" -}}
{{ include "stackstate-k8s-agent.releasename" . }}-secrets
{{- end -}}

{{- define "stackstate-k8s-agent.url.configmap.internal.name" -}}
{{ include "stackstate-k8s-agent.releasename" . }}-url
{{- end -}}

{{- define "stackstate-k8s-agent.clusterName.configmap.internal.name" -}}
{{ include "stackstate-k8s-agent.releasename" . }}-cluster-name
{{- end -}}

{{- define "stackstate-k8s-agent.api-key.secret.name" -}}
{{ include "stackstate-k8s-agent.externalOrInternal" (merge (dict "external" .Values.global.receiverApiKeySecret "internalName" "api-key") .) | quote }}
{{- end }}

{{/*
Custom certificates ConfigMap name
*/}}
{{- define "stackstate-k8s-agent.customCertificates.configmap.name" -}}
{{ include "stackstate-k8s-agent.releasename" . }}-custom-certificates
{{- end -}}

{{/*
Custom certificates volume definition
*/}}
{{- define "stackstate-k8s-agent.customCertificates.volume" -}}
{{- if .Values.global.customCertificates.enabled }}
- name: custom-certificates
  configMap:
    name: {{ if .Values.global.customCertificates.configMapName }}{{ .Values.global.customCertificates.configMapName }}{{ else }}{{ include "stackstate-k8s-agent.customCertificates.configmap.name" . }}{{ end }}
{{- end }}
{{- end -}}

{{/*
Custom certificates volume mount definition
*/}}
{{- define "stackstate-k8s-agent.customCertificates.volumeMount" -}}
{{- if .Values.global.customCertificates.enabled }}
- name: custom-certificates
  mountPath: /etc/pki/tls/certs
  readOnly: true
{{- end }}
{{- end -}}

{{/*
Custom certificates ConfigMap checksum annotation
*/}}
{{- define "stackstate-k8s-agent.customCertificates.checksum" -}}
{{- if and .Values.global.customCertificates.enabled .Values.global.customCertificates.pemData (not .Values.global.customCertificates.configMapName) }}
checksum/custom-certificates: {{ include (print $.Template.BasePath "/custom-certificates-configmap.yaml") . | sha256sum }}
{{- end }}
{{- end -}}

{{/*
Custom certificates validation - fail if both configMapName and pemData are provided
*/}}
{{- define "stackstate-k8s-agent.customCertificates.validate" -}}
{{- if and .Values.global.customCertificates.enabled .Values.global.customCertificates.configMapName .Values.global.customCertificates.pemData }}
{{- fail "Error: Both global.customCertificates.configMapName and global.customCertificates.pemData are provided. Please use only one approach - either specify an external ConfigMap name OR provide PEM data directly, not both." }}
{{- end }}
{{- end -}}

{{/*
Helpers for remote kube cache service (used by process-agent pod-correlation)
*/}}
{{- define "stackstate-k8s-agent.remoteKubeCache.serviceName" -}}
{{- printf "%s-remote-kube-cache" .Release.Name -}}
{{- end -}}

{{- define "stackstate-k8s-agent.remoteKubeCache.grpcPort" -}}
50055
{{- end -}}

{{- define "stackstate-k8s-agent.remoteKubeCache.address" -}}
{{- printf "%s:%s" (include "stackstate-k8s-agent.remoteKubeCache.serviceName" .) (include "stackstate-k8s-agent.remoteKubeCache.grpcPort" .) -}}
{{- end -}}

{{- define "stackstate-k8s-agent.processAgent.podCorrelation.remoteCache.enabled" -}}
{{- if and .Values.nodeAgent.containers.processAgent.enabled .Values.processAgent.podCorrelation.enabled .Values.processAgent.podCorrelation.remoteCache }}
true
{{- end }}
{{- end -}}
