{{/* vim: set filetype=mustache: */}}

{{/*
Create a default fully qualified instance name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
To simulate the way the operator works, use deployment.instance_name rather than the old fullnameOverride.
For backwards compatibility, if fullnameOverride is not kiali but deployment.instance_name is kiali,
use fullnameOverride, otherwise use deployment.instance_name.
*/}}
{{- define "kiali-server.fullname" -}}
{{- if (and (eq .Values.deployment.instance_name "kiali") (ne .Values.fullnameOverride "kiali")) }}
  {{- .Values.fullnameOverride | trunc 63 }}
{{- else }}
  {{- .Values.deployment.instance_name | trunc 63 }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "kiali-server.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Identifies the log_level.
*/}}
{{- define "kiali-server.logLevel" -}}
{{- .Values.deployment.logger.log_level -}}
{{- end }}

{{/*
Common labels
*/}}
{{- define "kiali-server.labels" -}}
helm.sh/chart: {{ include "kiali-server.chart" . }}
app: kiali
{{ include "kiali-server.selectorLabels" . }}
version: {{ .Values.deployment.version_label | default .Chart.AppVersion | quote }}
app.kubernetes.io/version: {{ .Values.deployment.version_label | default .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: "kiali"
{{- end }}

{{/*
Selector labels
*/}}
{{- define "kiali-server.selectorLabels" -}}
{{- $releaseName := .Release.Name -}}
{{- $fullName := include "kiali-server.fullname" . -}}
{{- $deployment := (lookup "apps/v1" "Deployment" .Release.Namespace $fullName) -}}
app.kubernetes.io/name: kiali
{{- if (and .Release.IsUpgrade $deployment)}}
app.kubernetes.io/instance: {{ (get (($deployment).metadata.labels) "app.kubernetes.io/instance") | default $fullName }}
{{- else }}
app.kubernetes.io/instance: {{ $fullName }}
{{- end }}
{{- end }}

{{/*
Determine the default login token signing key.
*/}}
{{- define "kiali-server.login_token.signing_key" -}}
{{- if .Values.login_token.signing_key }}
  {{- .Values.login_token.signing_key }}
{{- else }}
  {{- randAlphaNum 16 }}
{{- end }}
{{- end }}

{{/*
Determine the default web root.
*/}}
{{- define "kiali-server.server.web_root" -}}
{{- if .Values.server.web_root  }}
  {{- if (eq .Values.server.web_root "/") }}
    {{- .Values.server.web_root }}
  {{- else }}
    {{- .Values.server.web_root | trimSuffix "/" }}
  {{- end }}
{{- else }}
  {{- if .Capabilities.APIVersions.Has "route.openshift.io/v1" }}
    {{- "/" }}
  {{- else }}
    {{- "/kiali" }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
Determine the default identity cert file. There is no default if on k8s; only on OpenShift.
*/}}
{{- define "kiali-server.identity.cert_file" -}}
{{- if hasKey .Values.identity "cert_file" }}
  {{- .Values.identity.cert_file }}
{{- else }}
  {{- if .Capabilities.APIVersions.Has "route.openshift.io/v1" }}
    {{- "/kiali-cert/tls.crt" }}
  {{- else }}
    {{- "" }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
Determine the default identity private key file. There is no default if on k8s; only on OpenShift.
*/}}
{{- define "kiali-server.identity.private_key_file" -}}
{{- if hasKey .Values.identity "private_key_file" }}
  {{- .Values.identity.private_key_file }}
{{- else }}
  {{- if .Capabilities.APIVersions.Has "route.openshift.io/v1" }}
    {{- "/kiali-cert/tls.key" }}
  {{- else }}
    {{- "" }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
Determine the default deployment.ingress.enabled. Disable it on k8s; enable it on OpenShift.
*/}}
{{- define "kiali-server.deployment.ingress.enabled" -}}
{{- if hasKey .Values.deployment.ingress "enabled" }}
  {{- .Values.deployment.ingress.enabled }}
{{- else }}
  {{- if .Capabilities.APIVersions.Has "route.openshift.io/v1" }}
    {{- true }}
  {{- else }}
    {{- false }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
Determine the istio namespace - default is where Kiali is installed.
*/}}
{{- define "kiali-server.istio_namespace" -}}
{{- if .Values.istio_namespace }}
  {{- .Values.istio_namespace }}
{{- else }}
  {{- .Release.Namespace }}
{{- end }}
{{- end }}

{{/*
Determine the auth strategy to use - default is "token" on Kubernetes and "openshift" on OpenShift.
*/}}
{{- define "kiali-server.auth.strategy" -}}
{{- if .Values.auth.strategy }}
  {{- if (and (eq .Values.auth.strategy "openshift") (not .Values.kiali_route_url)) }}
    {{- fail "You did not define what the Kiali Route URL will be (--set kiali_route_url=...). Without this set, the openshift auth strategy will not work. Either set that or use a different auth strategy via the --set auth.strategy=... option." }}
  {{- end }}
  {{- .Values.auth.strategy }}
{{- else }}
  {{- if .Capabilities.APIVersions.Has "route.openshift.io/v1" }}
    {{- if not .Values.kiali_route_url }}
      {{- fail "You did not define what the Kiali Route URL will be (--set kiali_route_url=...). Without this set, the openshift auth strategy will not work. Either set that or explicitly indicate another auth strategy you want via the --set auth.strategy=... option." }}
    {{- end }}
    {{- "openshift" }}
  {{- else }}
    {{- "token" }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
Determine the root namespace - default is where Kiali is installed.
*/}}
{{- define "kiali-server.external_services.istio.root_namespace" -}}
{{- if .Values.external_services.istio.root_namespace }}
  {{- .Values.external_services.istio.root_namespace }}
{{- else }}
  {{- .Release.Namespace }}
{{- end }}
{{- end }}

{{- define "system_default_registry" -}}
{{- if .Values.global.cattle.systemDefaultRegistry -}}
{{- printf "%s/" .Values.global.cattle.systemDefaultRegistry -}}
{{- else -}}
{{- "" -}}
{{- end -}}
{{- end -}}

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
kubernetes.io/os: linux
{{- end -}}

{{/*
Autodetect remote cluster secrets if enabled - looks for secrets in the same namespace where Kiali is installed.
Returns a JSON dict whose keys are the cluster names and values are the cluster secret data.
*/}}
{{- define "kiali-server.remote-cluster-secrets" -}}
{{- $theDict := dict }}
{{- if .Values.clustering.autodetect_secrets.enabled }}
  {{- $secretLabelToLookFor := (regexSplit "=" .Values.clustering.autodetect_secrets.label 2) }}
  {{- $secretLabelNameToLookFor := first $secretLabelToLookFor }}
  {{- $secretLabelValueToLookFor := last $secretLabelToLookFor }}
  {{- range $i, $secret := (lookup "v1" "Secret" .Release.Namespace "").items }}
    {{- if (and (and (hasKey $secret.metadata "labels") (hasKey $secret.metadata.labels $secretLabelNameToLookFor)) (eq (get $secret.metadata.labels $secretLabelNameToLookFor) ($secretLabelValueToLookFor))) }}
      {{- $clusterName := $secret.metadata.name }}
      {{- if (and (hasKey $secret.metadata "annotations") (hasKey $secret.metadata.annotations "kiali.io/cluster")) }}
        {{- $clusterName = get $secret.metadata.annotations "kiali.io/cluster" }}
      {{- end }}
      {{- $theDict = set $theDict $clusterName $secret.metadata.name }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $theDict | toJson }}
{{- end }}
