{{/* vim: set filetype=mustache: */}}

{{- define "charts.exporter-kubelets.fullname" -}}
{{- printf "exporter-kubelets-%s" .Release.Name -}}
{{- end -}}


{{- define "charts.prometheus.serviceaccount.fullname" -}}
{{- printf "prometheus-%s" .Release.Name -}}
{{- end -}}


{{- define "app.name" -}}
{{- default .Chart.Name .Values.nameOverride -}}
{{- end -}}


{{- define "app.version" -}}
{{- $name := include "app.name" . -}}
{{- $version := .Chart.Version | replace "+" "_" -}}
{{- printf "%s-%s" $name $version -}}
{{- end -}}


{{- define "app.fullname" -}}
{{- $name := include "app.name" . -}}
{{- printf "%s-%s" $name .Release.Name -}}
{{- end -}}


{{- define "app.dnsname" -}}
{{- include "app.fullname" . | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{- define "app.psp.fullname" -}}
{{- $name := include "app.name" . -}}
{{- printf "%s-%s-psp" $name .Release.Name -}}
{{- end -}}


{{- define "app.nginx.fullname" -}}
{{- $name := include "app.name" . -}}
{{- printf "%s-%s-nginx" $name .Release.Name -}}
{{- end -}}


{{- define "app.dashboards.fullname" -}}
{{- $name := include "app.name" . -}}
{{- printf "%s-%s-dashboards" $name .Release.Name -}}
{{- end -}}


{{- define "app.hooks.fullname" -}}
{{- $name := include "app.name" . -}}
{{- printf "%s-%s-hooks" $name .Release.Name -}}
{{- end -}}


{{- define "app.cleanup.fullname" -}}
{{- $name := include "app.name" . -}}
{{- printf "%s-%s-cleanup" $name .Release.Name -}}
{{- end -}}


{{- define "kube_version" -}}
{{- printf "%s.%s" .Capabilities.KubeVersion.Major .Capabilities.KubeVersion.Minor -}}
{{- end -}}


{{- define "operator_api_version" -}}
{{- default "monitoring.coreos.com/v1" (.Values.apiGroup | printf "%s/v1") -}}
{{- end -}}


{{- define "operator_api_group" -}}
{{- $apiVersion := include "operator_api_version" . -}}
{{- index (regexSplit "/" $apiVersion 2) 0 | printf "%s" -}}
{{- end -}}


{{- define "deployment_api_version" -}}
{{- if .Capabilities.APIVersions.Has "apps/v1" -}}
{{- "apps/v1" -}}
{{- else if .Capabilities.APIVersions.Has "apps/v1beta2" -}}
{{- "apps/v1beta1" -}}
{{- else if .Capabilities.APIVersions.Has "apps/v1beta1" -}}
{{- "apps/v1beta1" -}}
{{- else -}}
{{- "extensions/v1beta1" -}}
{{- end -}}
{{- end -}}


{{- define "statefulset_api_version" -}}
{{- if .Capabilities.APIVersions.Has "apps/v1" -}}
{{- "apps/v1" -}}
{{- else if .Capabilities.APIVersions.Has "apps/v1beta2" -}}
{{- "apps/v1beta2" -}}
{{- else -}}
{{- "apps/v1beta1" -}}
{{- end -}}
{{- end -}}


{{- define "daemonset_api_version" -}}
{{- if .Capabilities.APIVersions.Has "apps/v1" -}}
{{- "apps/v1" -}}
{{- else if .Capabilities.APIVersions.Has "apps/v1beta2" -}}
{{- "apps/v1beta2" -}}
{{- else -}}
{{- "extensions/v1beta1" -}}
{{- end -}}
{{- end -}}


{{- define "rbac_api_version" -}}
{{- if .Capabilities.APIVersions.Has "rbac.authorization.k8s.io/v1" -}}
{{- "rbac.authorization.k8s.io/v1" -}}
{{- else if .Capabilities.APIVersions.Has "rbac.authorization.k8s.io/v1beta1" -}}
{{- "rbac.authorization.k8s.io/v1beta1" -}}
{{- else -}}
{{- "rbac.authorization.k8s.io/v1alpha1" -}}
{{- end -}}
{{- end -}}
