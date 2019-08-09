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
{{- if eq .Values.server.env.DRONE_PROVIDER "github" -}}
{{- print "DRONE_GITHUB" -}}
{{- else if eq .Values.server.env.DRONE_PROVIDER "gitlab" -}}
{{- print "DRONE_GITLAB" -}}
{{- else if eq .Values.server.env.DRONE_PROVIDER "gitea" -}}
{{- print "DRONE_GITEA" -}}
{{- else if eq .Values.server.env.DRONE_PROVIDER "gogs" -}}
{{- print "DRONE_GOGS" -}}
{{- else if eq .Values.server.env.DRONE_PROVIDER "bitbucket" -}}
{{- print "DRONE_BITBUCKET" -}}
{{- else if eq .Values.server.env.DRONE_PROVIDER "coding" -}}
{{- print "DRONE_CODING" -}}
{{- end -}}
{{- end -}}
