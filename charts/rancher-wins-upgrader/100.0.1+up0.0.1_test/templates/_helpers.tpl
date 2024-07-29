# Rancher

{{- define "system_default_registry" -}}
{{- if .Values.global.cattle.systemDefaultRegistry -}}
{{- printf "%s/" .Values.global.cattle.systemDefaultRegistry -}}
{{- end -}}
{{- end -}}

# General

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
The components in this chart create additional resources that expand the longest created name strings.
The longest name that gets created adds and extra 37 characters, so truncation should be 63-35=26.
*/}}
{{- define "winsUpgrader.name" -}}
wins-upgrader
{{- end -}}

{{- define "winsUpgrader.namespace" -}}
{{- default .Release.Namespace .Values.namespaceOverride -}}
{{- end -}}

{{- define "winsUpgrader.labels" -}}
k8s-app: {{ template "winsUpgrader.name" . }}
release: {{ .Release.Name }}
provider: kubernetes
{{- end -}}

{{- define "winsUpgrader.validatePathPrefix" -}}
{{- if .Values.global.cattle.rkeWindowsPathPrefix -}}
{{- $prefixPath := (.Values.global.cattle.rkeWindowsPathPrefix | replace "/" "\\") -}}
{{- if (not (hasSuffix "\\" $prefixPath)) -}}
{{- fail (printf ".Values.global.cattle.rkeWindowsPathPrefix must end in '/' or '\\', found %s" $prefixPath) -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "winsUpgrader.winsHostPath" -}}
{{ default "c:\\" .Values.global.cattle.rkeWindowsPathPrefix | replace "\\\\" "\\" | replace "\\" "/" }}etc/rancher/wins
{{- end -}}

{{- define "winsUpgrader.winsMasqueradePath" -}}
{{ tpl .Values.masquerade.as . | required "Must provide name for .Values.masquerade.as if enabled" | replace "\\\\" "\\" | replace "\\" "/" }}
{{- end -}}

{{- define "winsUpgrader.winsMasqueradeHostPath" -}}
{{ include "winsUpgrader.winsMasqueradePath" . | dir }}
{{- end -}}

{{- define "winsUpgrader.nodeSelector" -}}
{{- if semverCompare "<1.14-0" .Capabilities.KubeVersion.GitVersion -}}
beta.kubernetes.io/os: windows
{{- else -}}
kubernetes.io/os: windows
{{- end -}}
{{- end -}}

{{- define "winsUpgrader.tolerations" -}}
- operator: Exists
{{- end -}}
