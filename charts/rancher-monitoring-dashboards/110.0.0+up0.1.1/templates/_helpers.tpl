{{- define "rancher-monitoring.name" -}}
{{ .Chart.Name }}
{{- end -}}

{{- define "rancher-monitoring.namespace" -}}
{{.Release.Namespace }}
{{- end -}}

{{- define "rancher-monitoring.chartref" -}}
{{- printf "%s-%s" .Chart.Name (.Chart.Version | replace "+" "_") -}}
{{- end -}}

{{- define "rancher-monitoring.labels" -}}
app.kubernetes.io/name: {{ include "rancher-monitoring.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/part-of: {{ include "rancher-monitoring.name" . }}
helm.sh/chart: {{ include "rancher-monitoring.chartref" . }}
chart: {{ include "rancher-monitoring.chartref" . }}
release: {{ .Release.Name | quote }}
heritage: {{ .Release.Service | quote }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end -}}

{{- define "rancher-monitoring.selectorLabels" -}}
app.kubernetes.io/name: {{ include "rancher-monitoring.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "rancher-monitoring.dashboardArtifacts.enabled" -}}
{{- if .Values.dashboardArtifacts.enabled -}}true{{- else if .Values.grafana.forceDeployDashboards -}}true{{- end -}}
{{- end -}}

{{- define "rancher-monitoring.dashboardNamespace" -}}
{{- if .Values.dashboardArtifacts.namespace -}}
{{- .Values.dashboardArtifacts.namespace -}}
{{- else -}}
{{- .Values.grafana.defaultDashboards.namespace -}}
{{- end -}}
{{- end -}}

{{- define "rancher-monitoring.dashboardLabel" -}}
{{- if .Values.dashboardArtifacts.label -}}
{{- .Values.dashboardArtifacts.label -}}
{{- else -}}
{{- .Values.grafana.sidecar.dashboards.label -}}
{{- end -}}
{{- end -}}

{{- define "rancher-monitoring.dashboardLabelValue" -}}
{{- if .Values.dashboardArtifacts.labelValue -}}
{{- .Values.dashboardArtifacts.labelValue -}}
{{- else -}}
{{- default "1" .Values.grafana.sidecar.dashboards.labelValue -}}
{{- end -}}
{{- end -}}

{{- define "rancher-monitoring.dashboardAnnotations" -}}
{{- $annotations := .Values.dashboardArtifacts.annotations -}}
{{- if empty $annotations -}}
{{- $annotations = .Values.grafana.sidecar.dashboards.annotations -}}
{{- end -}}
{{- with $annotations -}}
{{ toYaml . }}
{{- end -}}
{{- end -}}

{{- define "rancher-monitoring.dashboardLabels" -}}
{{- $label := include "rancher-monitoring.dashboardLabel" . -}}
{{- if $label }}
{{ $label }}: {{ include "rancher-monitoring.dashboardLabelValue" . | quote }}
{{- end }}
app.kubernetes.io/component: dashboard-artifact
app: {{ include "rancher-monitoring.name" . }}-dashboards
{{ include "rancher-monitoring.labels" . }}
{{- end -}}

{{- define "system_default_registry" -}}
{{- if .Values.global.cattle.systemDefaultRegistry -}}
{{- printf "%s/" .Values.global.cattle.systemDefaultRegistry -}}
{{- end -}}
{{- end -}}

{{- define "rancher.serviceMonitor.selector" -}}
{{- if .Values.rancherMonitoring.selector }}
{{ .Values.rancherMonitoring.selector | toYaml }}
{{- else }}
{{- $rancherDeployment := (lookup "apps/v1" "Deployment" "cattle-system" "rancher") }}
{{- if $rancherDeployment }}
matchLabels:
  app: rancher
  chart: {{ index $rancherDeployment.metadata.labels "chart" }}
  release: rancher
{{- end }}
{{- end }}
{{- end -}}

{{- define "exporter.kubeEtcd.enabled" -}}
{{ if not (.Values.etcd.enabled) -}}
"true"
{{- end -}}
{{- end }}

{{- define "exporter.kubeControllerManager.jobName" -}}
{{- if .Values.k3sServer.enabled -}}
k3s-server
{{- else -}}
kube-controller-manager
{{- end -}}
{{- end -}}

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
