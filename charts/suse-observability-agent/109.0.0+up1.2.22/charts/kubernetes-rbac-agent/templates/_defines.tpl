{{- define "kubernetes-rbac-agent.app.name" -}}
{{ .Release.Name | trunc 52 | trimSuffix "-" }}-rbac-agent
{{- end -}}

{{- define "kubernetes-rbac-agent.global.name" -}}
{{ printf "%s-%s" .Release.Namespace .Release.Name | trunc 52 | trimSuffix "-" }}-rbac-agent
{{- end -}}

{{- define "kubernetes-rbac-agent.serviceaccount.name" -}}
{{ include "kubernetes-rbac-agent.app.name" . }}
{{- end -}}

{{- define "kubernetes-rbac-agent.pull-secret.name" -}}
{{ include "kubernetes-rbac-agent.app.name" . }}-pull-secret
{{- end -}}

{{- define "kubernetes-rbac-agent.externalOrInternal" -}}
{{- if .external }}
{{- tpl .external . }}
{{- else }}
{{- template "kubernetes-rbac-agent.app.name" . }}-{{ .internalName }}
{{- end }}
{{- end }}

{{- define "kubernetes-rbac-agent.api-key.secret.internal.name" -}}
{{ include "kubernetes-rbac-agent.app.name" . }}-api-key
{{- end -}}

{{- define "kubernetes-rbac-agent.url.configmap.internal.name" -}}
{{ include "kubernetes-rbac-agent.app.name" . }}-url
{{- end -}}

{{- define "kubernetes-rbac-agent.clusterName.configmap.internal.name" -}}
{{ include "kubernetes-rbac-agent.app.name" . }}-cluster-name
{{- end -}}

{{- define "kubernetes-rbac-agent.api-key.secret.name" -}}
{{ include "kubernetes-rbac-agent.externalOrInternal" (merge (dict "external" .Values.global.apiKey.fromSecret "internalName" "api-key") .) | quote }}
{{- end }}

{{- define "kubernetes-rbac-agent.url.configmap.name" -}}
{{ include "kubernetes-rbac-agent.externalOrInternal" (merge (dict "external" .Values.url.fromConfigMap "internalName" "url") .) | quote }}
{{- end }}

{{- define "kubernetes-rbac-agent.clusterName.configmap.name" -}}
{{ include "kubernetes-rbac-agent.externalOrInternal" (merge (dict "external" .Values.clusterName.fromConfigMap "internalName" "cluster-name") .) | quote }}
{{- end }}

{{- define "kubernetes-rbac-agent.image.registry.global" -}}
  {{- if .Values.global }}
    {{- .Values.global.imageRegistry | default "quay.io" -}}
  {{- else -}}
    quay.io
  {{- end -}}
{{- end -}}

{{- define "kubernetes-rbac-agent.image.registry" -}}
  {{- if ((.ContainerConfig).image).registry -}}
    {{- tpl .ContainerConfig.image.registry . -}}
  {{- else -}}
    {{- include "kubernetes-rbac-agent.image.registry.global" . }}
  {{- end -}}
{{- end -}}

{{- define "kubernetes-rbac-agent.image.pullSecrets" -}}
  {{- $pullSecrets := list }}
  {{- $pullSecrets = append $pullSecrets (include "kubernetes-rbac-agent.pull-secret.name" .) }}
  {{- range .Values.global.imagePullSecrets -}}
    {{- $pullSecrets = append $pullSecrets .  -}}
  {{- end -}}
  {{- if (not (empty $pullSecrets)) -}}
imagePullSecrets:
    {{- range $pullSecrets | uniq }}
  - name: {{ . }}
    {{- end }}
  {{- end -}}
{{- end -}}


{{/*
Returns a YAML with common annotations merged with extra annotations (extra has precedence).
*/}}
{{- define "kubernetes-rbac-agent.global.commonAnnotations" -}}
{{- $commonAnnotations := .Values.global.commonAnnotations | default dict }}
{{- $extraAnnotations := .Values.global.extraAnnotations | default dict }}
{{- $merged := merge $extraAnnotations $commonAnnotations }}
{{- if $merged }}
{{ toYaml $merged }}
{{- end }}
{{- end -}}

{{/*
Returns a YAML with common labels merged with extra labels (extra has precedence).
*/}}
{{- define "kubernetes-rbac-agent.global.commonLabels" -}}
{{- $commonLabels := .Values.global.commonLabels | default dict }}
{{- $extraLabels := .Values.global.extraLabels | default dict }}
{{- $merged := merge $extraLabels $commonLabels }}
{{- if $merged }}
{{ toYaml $merged }}
{{- end }}
{{- end -}}

{{/*
Custom certificates ConfigMap name
*/}}
{{- define "kubernetes-rbac-agent.customCertificates.configmap.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}-custom-certificates
{{- end -}}

{{/*
Custom certificates volume definition
*/}}
{{- define "kubernetes-rbac-agent.customCertificates.volume" -}}
{{- if .Values.global.customCertificates.enabled }}
- name: custom-certificates
  configMap:
    name: {{ if .Values.global.customCertificates.configMapName }}{{ .Values.global.customCertificates.configMapName }}{{ else }}{{ include "kubernetes-rbac-agent.customCertificates.configmap.name" . }}{{ end }}
{{- end }}
{{- end -}}

{{/*
Custom certificates volume mount definition
*/}}
{{- define "kubernetes-rbac-agent.customCertificates.volumeMount" -}}
{{- if .Values.global.customCertificates.enabled }}
- name: custom-certificates
  mountPath: /etc/pki/tls/certs
  readOnly: true
{{- end }}
{{- end -}}

{{/*
Custom certificates ConfigMap checksum annotation
*/}}
{{- define "kubernetes-rbac-agent.customCertificates.checksum" -}}
{{- if and .Values.global.customCertificates.enabled .Values.global.customCertificates.pemData (not .Values.global.customCertificates.configMapName) }}
checksum/custom-certificates: {{ include (print $.Template.BasePath "/custom-certificates-configmap.yaml") . | sha256sum }}
{{- end }}
{{- end -}}

{{/*
Custom certificates validation - fail if both configMapName and pemData are provided
*/}}
{{- define "kubernetes-rbac-agent.customCertificates.validate" -}}
{{- if and .Values.global.customCertificates.enabled .Values.global.customCertificates.configMapName .Values.global.customCertificates.pemData }}
{{- fail "Error: Both global.customCertificates.configMapName and global.customCertificates.pemData are provided. Please use only one approach - either specify an external ConfigMap name OR provide PEM data directly, not both." }}
{{- end }}
{{- end -}}

