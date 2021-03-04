{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "kiali-server.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "kiali-server.fullname" -}}
{{- if .Values.fullnameOverride }}
  {{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
  {{- $name := default .Chart.Name .Values.nameOverride }}
  {{- printf "%s" $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "kiali-server.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Identifies the log_level with the old verbose_mode and the new log_level considered.
*/}}
{{- define "kiali-server.logLevel" -}}
{{- if .Values.deployment.verbose_mode -}}
{{- .Values.deployment.verbose_mode -}}
{{- else -}}
{{- .Values.deployment.logger.log_level -}}
{{- end -}}
{{- end }}

{{/*
Common labels
*/}}
{{- define "kiali-server.labels" -}}
helm.sh/chart: {{ include "kiali-server.chart" . }}
app: {{ include "kiali-server.name" . }}
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
app.kubernetes.io/name: {{ include "kiali-server.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Used to determine if a custom dashboard (defined in .Template.Name) should be deployed.
*/}}
{{- define "kiali-server.isDashboardEnabled" -}}
{{- if .Values.external_services.custom_dashboards.enabled }}
  {{- $includere := "" }}
  {{- range $_, $s := .Values.deployment.custom_dashboards.includes }}
    {{- if $s }}
      {{- if $includere }}
        {{- $includere = printf "%s|^%s$" $includere ($s | replace "*" ".*" | replace "?" ".") }}
      {{- else }}
        {{- $includere = printf "^%s$" ($s | replace "*" ".*" | replace "?" ".") }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- $excludere := "" }}
  {{- range $_, $s := .Values.deployment.custom_dashboards.excludes }}
    {{- if $s }}
      {{- if $excludere }}
        {{- $excludere = printf "%s|^%s$" $excludere ($s | replace "*" ".*" | replace "?" ".") }}
      {{- else }}
        {{- $excludere = printf "^%s$" ($s | replace "*" ".*" | replace "?" ".") }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- if (and (mustRegexMatch (default "no-matches" $includere) (base .Template.Name)) (not (mustRegexMatch (default "no-matches" $excludere) (base .Template.Name)))) }}
    {{- print "enabled" }}
  {{- else }}
    {{- print "" }}
  {{- end }}
{{- else }}
  {{- print "" }}
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
  {{- .Values.server.web_root | trimSuffix "/" }}
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

{{- define "system_default_registry" -}}
{{- if .Values.global.cattle.systemDefaultRegistry -}}
{{- printf "%s/" .Values.global.cattle.systemDefaultRegistry -}}
{{- else -}}
{{- "" -}}
{{- end -}}
{{- end -}}
