{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{ define "drone.name" }}{{ default "drone" .Values.nameOverride | trunc 63 }}{{ end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this
(by the DNS naming spec).
*/}}
{{ define "drone.fullname" }}
{{- $name := default "drone" .Values.nameOverride -}}
{{ printf "%s-%s" .Release.Name $name | trunc 63 -}}
{{ end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "drone.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "drone.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "drone.server.provider" -}}
{{- if hasKey .Values.server.env "DRONE_PROVIDER" }}
{{- if eq .Values.server.env.DRONE_PROVIDER "github" -}}
{{ printf "DRONE_GITHUB" -}}
{{- else if eq .Values.server.env.DRONE_PROVIDER "gitlab" }}
{{ printf "DRONE_GITLAB" -}}
{{- else if eq .Values.server.env.DRONE_PROVIDER "gitea" }}
{{ printf "DRONE_GITEA" -}}
{{- else if eq .Values.server.env.DRONE_PROVIDER "gogs" }}
{{ printf "DRONE_GOGS" -}}
{{- else if eq .Values.server.env.DRONE_PROVIDER "bitbucket" }}
{{ printf "DRONE_BITBUCKET" -}}
{{- else if eq .Values.server.env.DRONE_PROVIDER "coding" }}
{{ printf "DRONE_CODING" -}}
{{- end -}}
{{- end -}}
{{- end -}}
