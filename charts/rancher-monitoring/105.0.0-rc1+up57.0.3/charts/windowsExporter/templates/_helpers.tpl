{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
The components in this chart create additional resources that expand the longest created name strings.
The longest name that gets created adds and extra 37 characters, so truncation should be 63-35=26.
*/}}
{{- define "prometheus-windows-exporter.fullname" -}}
{{ printf "%s-windows-exporter" .Release.Name }}
{{- end -}}

{{- define "system_default_registry" -}}
{{- if .Values.global.cattle.systemDefaultRegistry -}}
{{- printf "%s/" .Values.global.cattle.systemDefaultRegistry -}}
{{- end -}}
{{- end -}}

{{- define "windowsExporter.renamedMetricsRelabeling" -}}
{{- range $original, $new := (include "windowsExporter.renamedMetrics" . | fromJson) -}}
- sourceLabels: [__name__]
  regex: {{ $original }}
  replacement: '{{ $new }}'
  targetLabel: __name__
{{ end -}}
{{- end -}}

{{- define "windowsExporter.labels" -}}
k8s-app: {{ template "prometheus-windows-exporter.fullname" . }}
release: {{ .Release.Name }}
component: "windows-exporter"
provider: kubernetes
{{- end -}}

{{- define "windowsExporter.renamedMetrics" -}}
{{- $renamed := dict -}}
{{/* v0.15.0 */}}
{{- $_ := set $renamed "windows_mssql_transactions_active_total" "windows_mssql_transactions_active" -}}
{{/* v0.16.0 */}}
{{- $_ := set $renamed "windows_adfs_ad_login_connection_failures" "windows_adfs_ad_login_connection_failures_total" -}}
{{- $_ := set $renamed "windows_adfs_certificate_authentications" "windows_adfs_certificate_authentications_total" -}}
{{- $_ := set $renamed "windows_adfs_device_authentications" "windows_adfs_device_authentications_total" -}}
{{- $_ := set $renamed "windows_adfs_extranet_account_lockouts" "windows_adfs_extranet_account_lockouts_total" -}}
{{- $_ := set $renamed "windows_adfs_federated_authentications" "windows_adfs_federated_authentications_total" -}}
{{- $_ := set $renamed "windows_adfs_passport_authentications" "windows_adfs_passport_authentications_total" -}}
{{- $_ := set $renamed "windows_adfs_password_change_failed" "windows_adfs_password_change_failed_total" -}}
{{- $_ := set $renamed "windows_adfs_password_change_succeeded" "windows_adfs_password_change_succeeded_total" -}}
{{- $_ := set $renamed "windows_adfs_token_requests" "windows_adfs_token_requests_total" -}}
{{- $_ := set $renamed "windows_adfs_windows_integrated_authentications" "windows_adfs_windows_integrated_authentications_total" -}}
{{- $_ := set $renamed "windows_net_packets_outbound_errors" "windows_net_packets_outbound_errors_total" -}}
{{- $_ := set $renamed "windows_net_packets_received_discarded" "windows_net_packets_received_discarded_total" -}}
{{- $_ := set $renamed "windows_net_packets_received_errors" "windows_net_packets_received_errors_total" -}}
{{- $_ := set $renamed "windows_net_packets_received_total" "windows_net_packets_received_total_total" -}}
{{- $_ := set $renamed "windows_net_packets_received_unknown" "windows_net_packets_received_unknown_total" -}}
{{- $_ := set $renamed "windows_dns_memory_used_bytes_total" "windows_dns_memory_used_bytes" -}}
{{- $renamed | toJson -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "prometheus-windows-exporter.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "prometheus-windows-exporter.labels" -}}
helm.sh/chart: {{ include "prometheus-windows-exporter.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: metrics
app.kubernetes.io/part-of: {{ include "prometheus-windows-exporter.name" . }}
{{ include "prometheus-windows-exporter.selectorLabels" . }}
{{- with .Chart.AppVersion }}
app.kubernetes.io/version: {{ . | quote }}
{{- end }}
{{- with .Values.podLabels }}
{{ toYaml . }}
{{- end }}
{{- if .Values.releaseLabel }}
release: {{ .Release.Name }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "prometheus-windows-exporter.selectorLabels" -}}
app.kubernetes.io/name: {{ include "prometheus-windows-exporter.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{/*
Create the name of the service account to use
*/}}
{{- define "prometheus-windows-exporter.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "prometheus-windows-exporter.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
The image to use
*/}}
{{- define "prometheus-windows-exporter.image" -}}
{{- if .Values.image.sha }}
{{- fail "image.sha forbidden. Use image.digest instead" }}
{{- else if .Values.image.digest }}
{{- if .Values.global.cattle.systemDefaultRegistry }}
{{- printf "%s/%s:%s@%s" .Values.global.cattle.systemDefaultRegistry .Values.image.repository (default .Chart.AppVersion .Values.image.tag) .Values.image.digest }}
{{- else }}
{{- printf "%s/%s:%s@%s" .Values.image.registry .Values.image.repository (default .Chart.AppVersion .Values.image.tag) .Values.image.digest }}
{{- end }}
{{- else }}
{{- if .Values.global.cattle.systemDefaultRegistry }}
{{- printf "%s/%s:%s" .Values.global.cattle.systemDefaultRegistry .Values.image.repository (default .Chart.AppVersion .Values.image.tag) }}
{{- else }}
{{- printf "%s/%s:%s" .Values.image.registry .Values.image.repository (default .Chart.AppVersion .Values.image.tag) }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Allow the release namespace to be overridden for multi-namespace deployments in combined charts
*/}}
{{- define "prometheus-windows-exporter.namespace" -}}
{{- if .Values.namespaceOverride }}
{{- .Values.namespaceOverride }}
{{- else }}
{{- .Release.Namespace }}
{{- end }}
{{- end }}

{{/*
Create the namespace name of the service monitor
*/}}
{{- define "prometheus-windows-exporter.monitor-namespace" -}}
{{- if .Values.namespaceOverride }}
{{- .Values.namespaceOverride }}
{{- else }}
{{- if .Values.prometheus.monitor.namespace }}
{{- .Values.prometheus.monitor.namespace }}
{{- else }}
{{- .Release.Namespace }}
{{- end }}
{{- end }}
{{- end }}

{{/* Sets default scrape limits for servicemonitor */}}
{{- define "servicemonitor.scrapeLimits" -}}
{{- with .sampleLimit }}
sampleLimit: {{ . }}
{{- end }}
{{- with .targetLimit }}
targetLimit: {{ . }}
{{- end }}
{{- with .labelLimit }}
labelLimit: {{ . }}
{{- end }}
{{- with .labelNameLengthLimit }}
labelNameLengthLimit: {{ . }}
{{- end }}
{{- with .labelValueLengthLimit }}
labelValueLengthLimit: {{ . }}
{{- end }}
{{- end }}

{{/*
Formats imagePullSecrets. Input is (dict "Values" .Values "imagePullSecrets" .{specific imagePullSecrets})
*/}}
{{- define "prometheus-windows-exporter.imagePullSecrets" -}}
{{- range (concat .Values.global.imagePullSecrets .imagePullSecrets) }}
  {{- if eq (typeOf .) "map[string]interface {}" }}
- {{ toYaml . | trim }}
  {{- else }}
- name: {{ . }}
  {{- end }}
{{- end }}
{{- end -}}

{{/*
Create the namespace name of the pod monitor
*/}}
{{- define "prometheus-windows-exporter.podmonitor-namespace" -}}
{{- if .Values.namespaceOverride }}
{{- .Values.namespaceOverride }}
{{- else }}
{{- if .Values.prometheus.podMonitor.namespace }}
{{- .Values.prometheus.podMonitor.namespace }}
{{- else }}
{{- .Release.Namespace }}
{{- end }}
{{- end }}
{{- end }}

{{/* Sets default scrape limits for podmonitor */}}
{{- define "podmonitor.scrapeLimits" -}}
{{- with .sampleLimit }}
sampleLimit: {{ . }}
{{- end }}
{{- with .targetLimit }}
targetLimit: {{ . }}
{{- end }}
{{- with .labelLimit }}
labelLimit: {{ . }}
{{- end }}
{{- with .labelNameLengthLimit }}
labelNameLengthLimit: {{ . }}
{{- end }}
{{- with .labelValueLengthLimit }}
labelValueLengthLimit: {{ . }}
{{- end }}
{{- end }}
