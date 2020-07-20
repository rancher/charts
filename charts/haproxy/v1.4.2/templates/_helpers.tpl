{{/*
Copyright 2019 HAProxy Technologies LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/}}

{{/*
Expand the name of the chart.
*/}}
{{- define "kubernetes-ingress.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "kubernetes-ingress.fullname" -}}
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
{{- define "kubernetes-ingress.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{kubernetes-ingress.publishServicePath{/*
Encode an imagePullSecret string.
*/}}
{{- define "kubernetes-ingress.imagePullSecret" }}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" .Values.controller.imageCredentials.registry (printf "%s:%s" .Values.controller.imageCredentials.username .Values.controller.imageCredentials.password | b64enc) | b64enc }}
{{- end }}

{{/*
Generate default certificate for HAProxy.
*/}}
{{- define "kubernetes-ingress.gen-certs" -}}
{{- $ca := genCA "kubernetes-ingress-ca" 365 -}}
{{- $cn := printf "%s.%s" .Release.Name .Release.Namespace -}}
{{- $cert := genSignedCert $cn nil nil 365 $ca -}}
tls.crt: {{ $cert.Cert | b64enc }}
tls.key: {{ $cert.Key | b64enc }}
{{- end -}}

{{/*
Create the name of the controller service account to use.
*/}}
{{- define "kubernetes-ingress.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "kubernetes-ingress.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the backend service account to use - only used when podsecuritypolicy is also enabled
*/}}
{{- define "kubernetes-ingress.defaultBackend.serviceAccountName" -}}
{{- if or .Values.serviceAccount.create .Values.defaultBackend.serviceAccount.create -}}
    {{ default (printf "%s-%s" (include "kubernetes-ingress.fullname" .) .Values.defaultBackend.name) .Values.defaultBackend.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.defaultBackend.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified default backend name.
*/}}
{{- define "kubernetes-ingress.defaultBackend.fullname" -}}
{{- printf "%s-%s" (include "kubernetes-ingress.fullname" .) .Values.defaultBackend.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified default cert secret name.
*/}}
{{- define "kubernetes-ingress.defaultTLSSecret.fullname" -}}
{{- printf "%s-%s" (include "kubernetes-ingress.fullname" .) "default-cert" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Construct the path for the publish-service.
By default this will use the <namespace>/<service-name> matching the controller's service name.
Users can provide an override for an explicit service they want to use via `.Values.controller.publishService.pathOverride`
*/}}
{{- define "kubernetes-ingress.publishServicePath" -}}
{{- $defServicePath := printf "%s/%s" .Release.Namespace (include "kubernetes-ingress.fullname" .) -}}
{{- $servicePath := default $defServicePath .Values.controller.publishService.pathOverride }}
{{- print $servicePath | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* vim: set filetype=mustache: */}}
