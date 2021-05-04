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
{{- define "windowsExporter.name" -}}
{{ printf "%s-windows-exporter" .Release.Name }}
{{- end -}}

{{- define "windowsExporter.namespace" -}}
{{- default .Release.Namespace .Values.namespaceOverride -}}
{{- end -}}

{{- define "windowsExporter.labels" -}}
k8s-app: {{ template "windowsExporter.name" . }}
release: {{ .Release.Name }}
component: "windows-exporter"
provider: kubernetes
{{- end -}}

# Client

{{- define "windowsExporter.client.nodeSelector" -}}
{{- if semverCompare "<1.14-0" .Capabilities.KubeVersion.GitVersion -}}
beta.kubernetes.io/os: windows
{{- else -}}
kubernetes.io/os: windows
{{- end -}}
{{- if .Values.clients.nodeSelector }}
{{ toYaml .Values.clients.nodeSelector }}
{{- end }}
{{- end -}}

{{- define "windowsExporter.client.tolerations" -}}
{{- if .Values.clients.tolerations -}}
{{ toYaml .Values.clients.tolerations }}
{{- else -}}
- operator: Exists
{{- end -}}
{{- end -}}

{{- define "windowsExporter.client.env" -}}
- name: LISTEN_PORT
  value: {{ required "Need .Values.clients.port to figure out where to get metrics from" .Values.clients.port | quote }}
{{- if .Values.clients.enabledCollectors }}
- name: ENABLED_COLLECTORS
  value: {{ .Values.clients.enabledCollectors | quote }}
{{- end }}
{{- if .Values.clients.env }}
{{ toYaml .Values.clients.env }}
{{- end }}
{{- end -}}

{{- define "windowsExporter.validatePathPrefix" -}}
{{- if .Values.global.cattle.rkeWindowsPathPrefix -}}
{{- $prefixPath := (.Values.global.cattle.rkeWindowsPathPrefix | replace "/" "\\") -}}
{{- if (not (hasSuffix "\\" $prefixPath)) -}}
{{- fail (printf ".Values.global.cattle.rkeWindowsPathPrefix must end in '/' or '\\', found %s" $prefixPath) -}}
{{- end -}}
{{- end -}}
{{- end -}}
