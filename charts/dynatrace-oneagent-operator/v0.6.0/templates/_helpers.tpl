// Copyright 2019 Dynatrace LLC

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//     http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "dynatrace-oneagent-operator.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "dynatrace-oneagent-operator.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "dynatrace-oneagent-operator.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "dynatrace-oneagent-operator.commonlabels" -}}
dynatrace: operator
operator: oneagent
helm.sh/chart: {{ include "dynatrace-oneagent-operator.chart" . }}
{{- end -}}

{{/*
Check if platform is set
*/}}
{{- define "dynatrace-oneagent-operator.platformSet" -}}
{{- if or (eq .Values.platform "kubernetes") (eq .Values.platform "openshift") -}}
    {{ default "set" }}
{{- end -}}
{{- end -}}

{{/*
Check if default oneagent image is used    
*/}}
{{- define "dynatrace-oneagent.image" -}}
{{- if .Values.oneagent.image -}}
    {{- printf "%s" .Values.oneagent.image -}}    
{{- else -}}
    {{- if eq .Values.platform "kubernetes" -}}
        {{- printf "docker.io/dynatrace/oneagent" }}
    {{- end -}}
    {{- if eq .Values.platform "openshift" -}}
        {{- printf "registry.connect.redhat.com/dynatrace/oneagent" }}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Check if default operator image is used    
*/}}
{{- define "dynatrace-oneagent-operator.image" -}}
{{- if .Values.operator.image -}}
    {{- printf "%s" .Values.operator.image -}}    
{{- else -}}
    {{- printf "%s:v%s" "quay.io/dynatrace/dynatrace-oneagent-operator" .Chart.AppVersion }}
{{- end -}}
{{- end -}}