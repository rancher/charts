# Rancher
{{- define "system_default_registry" -}}
{{- if .Values.global.cattle.systemDefaultRegistry -}}
{{- printf "%s/" .Values.global.cattle.systemDefaultRegistry -}}
{{- end -}}
{{- end -}}

# Special Exporters
{{- define "exporter.kubeEtcd.enabled" -}}
{{- if or .Values.kubeEtcd.enabled .Values.rkeEtcd.enabled .Values.kubeAdmEtcd.enabled .Values.rke2Etcd.enabled -}}
"true"
{{- end -}}
{{- end }}

{{- define "exporter.kubeControllerManager.enabled" -}}
{{- if or .Values.kubeControllerManager.enabled .Values.rkeControllerManager.enabled .Values.k3sServer.enabled .Values.kubeAdmControllerManager.enabled .Values.rke2ControllerManager.enabled -}}
"true"
{{- end -}}
{{- end }}

{{- define "exporter.kubeScheduler.enabled" -}}
{{- if or .Values.kubeScheduler.enabled .Values.rkeScheduler.enabled .Values.k3sServer.enabled .Values.kubeAdmScheduler.enabled .Values.rke2Scheduler.enabled -}}
"true"
{{- end -}}
{{- end }}

{{- define "exporter.kubeProxy.enabled" -}}
{{- if or .Values.kubeProxy.enabled .Values.rkeProxy.enabled .Values.k3sServer.enabled .Values.kubeAdmProxy.enabled .Values.rke2Proxy.enabled -}}
"true"
{{- end -}}
{{- end }}

{{- define "exporter.kubeControllerManager.jobName" -}}
{{- if .Values.k3sServer.enabled -}}
k3s-server
{{- else -}}
kube-controller-manager
{{- end -}}
{{- end }}

{{- define "exporter.kubeScheduler.jobName" -}}
{{- if .Values.k3sServer.enabled -}}
k3s-server
{{- else -}}
kube-scheduler
{{- end -}}
{{- end }}

{{- define "exporter.kubeProxy.jobName" -}}
{{- if .Values.k3sServer.enabled -}}
k3s-server
{{- else -}}
kube-proxy
{{- end -}}
{{- end }}

# Prometheus Operator

{{/* vim: set filetype=mustache: */}}
{{/* Expand the name of the chart. This is suffixed with -alertmanager, which means subtract 13 from longest 63 available */}}
{{- define "kube-prometheus-stack.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 50 | trimSuffix "-" -}}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
The components in this chart create additional resources that expand the longest created name strings.
The longest name that gets created adds and extra 37 characters, so truncation should be 63-35=26.
*/}}
{{- define "kube-prometheus-stack.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 26 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 26 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 26 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* Fullname suffixed with operator */}}
{{- define "kube-prometheus-stack.operator.fullname" -}}
{{- printf "%s-operator" (include "kube-prometheus-stack.fullname" .) -}}
{{- end }}

{{/* Fullname suffixed with prometheus */}}
{{- define "kube-prometheus-stack.prometheus.fullname" -}}
{{- printf "%s-prometheus" (include "kube-prometheus-stack.fullname" .) -}}
{{- end }}

{{/* Fullname suffixed with alertmanager */}}
{{- define "kube-prometheus-stack.alertmanager.fullname" -}}
{{- printf "%s-alertmanager" (include "kube-prometheus-stack.fullname" .) -}}
{{- end }}

{{/* Create chart name and version as used by the chart label. */}}
{{- define "kube-prometheus-stack.chartref" -}}
{{- replace "+" "_" .Chart.Version | printf "%s-%s" .Chart.Name -}}
{{- end }}

{{/* Generate basic labels */}}
{{- define "kube-prometheus-stack.labels" }}
chart: {{ template "kube-prometheus-stack.chartref" . }}
release: {{ $.Release.Name | quote }}
heritage: {{ $.Release.Service | quote }}
{{- if .Values.commonLabels}}
{{ toYaml .Values.commonLabels }}
{{- end }}
{{- end }}

{{/* Create the name of kube-prometheus-stack service account to use */}}
{{- define "kube-prometheus-stack.operator.serviceAccountName" -}}
{{- if .Values.prometheusOperator.serviceAccount.create -}}
    {{ default (include "kube-prometheus-stack.operator.fullname" .) .Values.prometheusOperator.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.prometheusOperator.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/* Create the name of prometheus service account to use */}}
{{- define "kube-prometheus-stack.prometheus.serviceAccountName" -}}
{{- if .Values.prometheus.serviceAccount.create -}}
    {{ default (include "kube-prometheus-stack.prometheus.fullname" .) .Values.prometheus.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.prometheus.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/* Create the name of alertmanager service account to use */}}
{{- define "kube-prometheus-stack.alertmanager.serviceAccountName" -}}
{{- if .Values.alertmanager.serviceAccount.create -}}
    {{ default (include "kube-prometheus-stack.alertmanager.fullname" .) .Values.alertmanager.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.alertmanager.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Allow the release namespace to be overridden for multi-namespace deployments in combined charts
*/}}
{{- define "kube-prometheus-stack.namespace" -}}
  {{- if .Values.namespaceOverride -}}
    {{- .Values.namespaceOverride -}}
  {{- else -}}
    {{- .Release.Namespace -}}
  {{- end -}}
{{- end -}}