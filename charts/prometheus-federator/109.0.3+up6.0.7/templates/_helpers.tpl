# Rancher
{{- define "system_default_registry" -}}
{{- if .Values.global.cattle.systemDefaultRegistry -}}
{{- printf "%s/" .Values.global.cattle.systemDefaultRegistry -}}
{{- end -}}
{{- end -}}

{{- define "helm-controller.imageRegistry" -}}
{{- if and .Values.image .Values.image.registry }}{{- printf "%s/" .Values.image.registry -}}
{{- else if .Values.helmController.deployment.image.registry }}{{- printf "%s/" .Values.helmController.deployment.image.registry -}}
{{- else }}{{ template "system_default_registry" .  }}
{{- end }}
{{- end }}

{{/* Define the image registry to use; either values, or systemdefault if set, or nothing */}}
{{- define "prometheus-federator.imageRegistry" -}}
{{- if and .Values.image .Values.image.registry }}{{- printf "%s/" .Values.image.registry -}}
{{- else if .Values.helmProjectOperator.image.registry }}{{- printf "%s/" .Values.helmProjectOperator.image.registry -}}
{{- else }}{{ template "system_default_registry" .  }}
{{- end }}
{{- end }}

{{- define "prometheus-federator.imageRepository" -}}
{{- if and .Values.image .Values.image.repository }}{{ .Values.image.repository }}
{{- else if .Values.helmProjectOperator.image.repository }}{{ .Values.helmProjectOperator.image.repository }}
{{- end }}
{{- end }}

{{- define "prometheus-federator.imageTag" -}}
{{- if and .Values.image .Values.image.tag -}}{{- .Values.image.tag -}}
{{- else if and .Values.helmProjectOperator.image.tag -}}{{- .Values.helmProjectOperator.image.tag -}}
{{- else -}}{{- .Chart.AppVersion -}}
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

# Helm Project Operator

{{/* vim: set filetype=mustache: */}}
{{/* Expand the name of the chart. This is suffixed with -alertmanager, which means subtract 13 from longest 63 available */}}
{{- define "prometheus-federator.name" -}}
{{- default .Chart.Name (default .Values.helmProjectOperator.nameOverride .Values.nameOverride) | trunc 50 | trimSuffix "-" -}}
{{- end }}

{{/*
Allow the release namespace to be overridden for multi-namespace deployments in combined charts
*/}}
{{- define "prometheus-federator.namespace" -}}
  {{- if .Values.namespaceOverride -}}
    {{- .Values.namespaceOverride -}}
  {{- else if .Values.helmProjectOperator.namespaceOverride -}}
    {{- .Values.helmProjectOperator.namespaceOverride -}}
  {{- else -}}
    {{- .Release.Namespace -}}
  {{- end -}}
{{- end -}}

{{/* Create chart name and version as used by the chart label. */}}
{{- define "prometheus-federator.chartref" -}}
{{- replace "+" "_" .Chart.Version | printf "%s-%s" .Chart.Name -}}
{{- end }}

{{/* Generate basic labels */}}
{{- define "prometheus-federator.labels" }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: "{{ replace "+" "_" .Chart.Version }}"
app.kubernetes.io/part-of: {{ template "prometheus-federator.name" . }}
chart: {{ template "prometheus-federator.chartref" . }}
release: {{ $.Release.Name | quote }}
heritage: {{ $.Release.Service | quote }}
{{- if .Values.commonLabels}}
{{ toYaml .Values.commonLabels }}
{{- end }}
{{- end }}