{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "harvester-csi-driver.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "harvester-csi-driver.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "harvester-csi-driver.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "harvester-csi-driver.labels" -}}
helm.sh/chart: {{ include "harvester-csi-driver.chart" . }}
{{ include "harvester-csi-driver.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "harvester-csi-driver.selectorLabels" -}}
app.kubernetes.io/name: {{ include "harvester-csi-driver.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Global system default registry
*/}}
{{- define "system_default_registry" -}}
{{- if .Values.global.cattle.systemDefaultRegistry -}}
{{- printf "%s/" .Values.global.cattle.systemDefaultRegistry -}}
{{- else -}}
{{- "" -}}
{{- end -}}
{{- end -}}

{{/*
Render imagePullSecrets, accepting either strings or object references.
*/}}
{{- define "harvester-csi-driver.imagePullSecrets" -}}
{{- $pullSecrets := list -}}
{{- range .Values.global.cattle.imagePullSecrets -}}
  {{- if kindIs "map" . -}}
    {{- if .name -}}
      {{- $pullSecrets = append $pullSecrets .name -}}
    {{- end -}}
  {{- else if not (empty .) -}}
    {{- $pullSecrets = append $pullSecrets . -}}
  {{- end -}}
{{- end -}}
{{- if not (empty $pullSecrets) -}}
imagePullSecrets:
  {{- range $pullSecrets | uniq }}
  - name: {{ . | quote }}
  {{- end }}
{{- end -}}
{{- end -}}

{{/*
Decide storageclass.kubernetes.io/is-default-class for the chart-managed
"harvester" StorageClass. Keep harvester as default unless a *different*
StorageClass in the cluster is already marked as default (day-2 change), so
Helm upgrades do not overwrite that choice.
Note: lookup returns an empty result during `helm template` / client-side
dry-run, which falls through to "true" (the fresh-install default).
*/}}
{{- define "harvester-csi-driver.annotations.defaultStorageClass" -}}
{{- $stable := "storageclass.kubernetes.io/is-default-class" -}}
{{- $beta := "storageclass.beta.kubernetes.io/is-default-class" -}}
{{- $result := dict $stable "true" $beta "false" -}}
{{- range (lookup "storage.k8s.io/v1" "StorageClass" "" "").items -}}
  {{- if ne .metadata.name "harvester" -}}
    {{- $flags := pick (.metadata.annotations | default dict) $stable $beta -}}
    {{- if has "true" (values $flags) -}}
      {{- $_ := set $result $stable "false" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- toYaml $result -}}
{{- end -}}
