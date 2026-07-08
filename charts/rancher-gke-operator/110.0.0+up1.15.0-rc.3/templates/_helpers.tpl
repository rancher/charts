{{/* vim: set filetype=mustache: */}}

{{- define "system_default_registry" -}}
{{- if .Values.global.cattle.systemDefaultRegistry -}}
{{- printf "%s/" .Values.global.cattle.systemDefaultRegistry -}}
{{- else -}}
{{- "" -}}
{{- end -}}
{{- end -}}

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
kubernetes.io/os: linux
{{- end -}}

{{/*
Renders imagePullSecrets, accepting either object references ({ name: <secret> })
or plain strings, deduplicating the result.
*/}}
{{- define "imagePullSecrets" -}}
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
  - name: {{ . }}
  {{- end }}
{{- end -}}
{{- end -}}

