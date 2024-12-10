{{/* Gets the correct API Version based on the version of the cluster
*/}}

{{- define "rbac.apiVersion" -}}
{{$version := .Capabilities.KubeVersion.GitVersion | regexFind "^v\\d+\\.\\d+\\.\\d+" | trimPrefix "v"}}
{{- if semverCompare ">= 1.8" $version -}}
"rbac.authorization.k8s.io/v1"
{{- else -}}
"rbac.authorization.k8s.io/v1beta1"
{{- end -}}
{{- end -}}

{{- define "px.labels" -}}
chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
heritage: {{ .Release.Service | quote }}
release: {{ .Release.Name | quote }}
{{- end -}}

{{- define "driveOpts" }}
{{ $v := .Values.installOptions.drives | split "," }}
{{$v._0}}
{{- end -}}

{{- define "px.kubernetesVersion" -}}
{{$version := .Capabilities.KubeVersion.GitVersion | regexFind "^v\\d+\\.\\d+\\.\\d+"}}{{$version}}
{{- end -}}

{{- define "px.kubectlImageTag" -}}
{{$version := .Capabilities.KubeVersion.GitVersion | regexFind "^v\\d+\\.\\d+\\.\\d+" | trimPrefix "v" | split "."}}
{{- $major := index $version "_0" -}}
{{- $minor := index $version "_1" -}}
{{printf "%s.%s" $major $minor }}
{{- end -}}

{{- define "px.getPxOperatorImage" -}}
{{- if (.Values.customRegistryURL) -}}
    {{- if (eq "/" (.Values.customRegistryURL | regexFind "/")) -}}
        {{ cat (trim .Values.customRegistryURL) "/px-operator" | replace " " ""}}
    {{- else -}}
        {{cat (trim .Values.customRegistryURL) "/portworx/px-operator" | replace " " ""}}
    {{- end -}}
{{- else -}}
    {{ "portworx/px-operator" }}
{{- end -}}
{{- end -}}

{{- define "px.getImage" -}}
{{- if (.Values.customRegistryURL) -}}
    {{- if (eq "/" (.Values.customRegistryURL | regexFind "/")) -}}
        {{- if .Values.openshiftInstall -}}
            {{ cat (trim .Values.customRegistryURL) "/px-monitor" | replace " " ""}}
        {{- else -}}
            {{ cat (trim .Values.customRegistryURL) "/oci-monitor" | replace " " ""}}
        {{- end -}}
    {{- else -}}
        {{- if .Values.openshiftInstall -}}
            {{cat (trim .Values.customRegistryURL) "/portworx/px-monitor" | replace " " ""}}
        {{- else -}}
            {{cat (trim .Values.customRegistryURL) "/portworx/oci-monitor" | replace " " ""}}
        {{- end -}}
    {{- end -}}
{{- else -}}
    {{- if .Values.openshiftInstall -}}
        {{ "registry.connect.redhat.com/portworx/px-monitor" }}
    {{- else -}}
        {{ "portworx/oci-monitor" }}
    {{- end -}}
{{- end -}}
{{- end -}}

{{- define "px.getStorkImage" -}}
{{- if (.Values.customRegistryURL) -}}
    {{- if (eq "/" (.Values.customRegistryURL | regexFind "/")) -}}
        {{ cat (trim .Values.customRegistryURL) "/stork" | replace " " ""}}
    {{- else -}}
        {{cat (trim .Values.customRegistryURL) "/openstorage/stork" | replace " " ""}}
    {{- end -}}
{{- else -}}
    {{ "openstorage/stork" }}
{{- end -}}
{{- end -}}

{{- define "px.getk8sImages" -}}
{{- $version := .Capabilities.KubeVersion.GitVersion | regexFind "^v\\d+\\.\\d+\\.\\d+" | trimPrefix "v" -}}
{{- if (.Values.customRegistryURL) -}}
    {{- if (eq "/" (.Values.customRegistryURL | regexFind "/")) -}}
        {{ trim .Values.customRegistryURL }}
    {{- else -}}
        {{- if or (or (and (semverCompare ">= 1.16.14" $version ) (semverCompare "<=1.17.0"  $version)) (and (semverCompare ">= 1.17.10" $version) (semverCompare "<=1.18.0" $version ))) (semverCompare ">=1.18.7" $version) -}}
           {{cat (trim .Values.customRegistryURL) "/k8s.gcr.io" | replace " " ""}}
        {{- else -}}
           {{cat (trim .Values.customRegistryURL) "/gcr.io/google_containers" | replace " " ""}}
        {{- end -}}
    {{- end -}}
{{- else -}}
     {{- if or (or (and (semverCompare ">= 1.16.14" $version ) (semverCompare "<=1.17.0"  $version)) (and (semverCompare ">= 1.17.10" $version) (semverCompare "<=1.18.0" $version ))) (semverCompare ">=1.18.7" $version) -}}
        {{ "k8s.gcr.io" }}
     {{- else -}}
        {{ "gcr.io/google_containers" }}
    {{- end -}}
{{- end -}}
{{- end -}}


{{- define "px.getPauseImage" -}}
{{- if (.Values.customRegistryURL) -}}
    {{- if (eq "/" (.Values.customRegistryURL | regexFind "/")) -}}
        {{ trim .Values.customRegistryURL }}
    {{- else -}}
        {{cat (trim .Values.customRegistryURL) "/k8s.gcr.io" | replace " " ""}}
    {{- end -}}
{{- else -}}
        {{ "k8s.gcr.io" }}
{{- end -}}
{{- end -}}

{{- define "px.getcsiImages" -}}
{{- if (.Values.customRegistryURL) -}}
    {{- if (eq "/" (.Values.customRegistryURL | regexFind "/")) -}}
        {{ trim .Values.customRegistryURL }}
    {{- else -}}
        {{cat (trim .Values.customRegistryURL) "/quay.io/k8scsi" | replace " " ""}}
    {{- end -}}
{{- else -}}
        {{ "quay.io/k8scsi" }}
{{- end -}}
{{- end -}}

{{- define "px.getLighthouseImages" -}}
{{- if (.Values.customRegistryURL) -}}
    {{- if (eq "/" (.Values.customRegistryURL | regexFind "/")) -}}
        {{ trim .Values.customRegistryURL }}
    {{- else -}}
        {{cat (trim .Values.customRegistryURL) "/portworx" | replace " " ""}}
    {{- end -}}
{{- else -}}
        {{ "portworx" }}
{{- end -}}
{{- end -}}

{{- define "px.registryConfigType" -}}
{{- $version := .Capabilities.KubeVersion.GitVersion | regexFind "^v\\d+\\.\\d+\\.\\d+" | trimPrefix "v" -}}
{{- if semverCompare ">=1.9" $version -}}
".dockerconfigjson"
{{- else -}}
".dockercfg"
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use for hooks
*/}}
{{- define "px.hookServiceAccount" -}}
{{- if .Values.serviceAccount.hook.create -}}
    {{- printf "%s-hook" .Chart.Name | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
    {{ default "default" .Values.serviceAccount.hook.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the cluster role to use for hooks
*/}}
{{- define "px.hookClusterRole" -}}
{{- if .Values.serviceAccount.hook.create -}}
    {{- printf "%s-hook" .Chart.Name | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
    {{ default "default" .Values.serviceAccount.hook.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the cluster role binding to use for hooks
*/}}
{{- define "px.hookClusterRoleBinding" -}}
{{- if .Values.serviceAccount.hook.create -}}
    {{- printf "%s-hook" .Chart.Name | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
    {{ default "default" .Values.serviceAccount.hook.name }}
{{- end -}}
{{- end -}}


{{/*
Create the name of the role to use for hooks
*/}}
{{- define "px.hookRole" -}}
{{- if .Values.serviceAccount.hook.create -}}
    {{- printf "%s-hook" .Chart.Name | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
    {{ default "default" .Values.serviceAccount.hook.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the role binding to use for hooks
*/}}
{{- define "px.hookRoleBinding" -}}
{{- if .Values.serviceAccount.hook.create -}}
    {{- printf "%s-hook" .Chart.Name | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
    {{ default "default" .Values.serviceAccount.hook.name }}
{{- end -}}
{{- end -}}

{{/*
Generate a random token for storage provisioning
*/}}

{{- define "portworx-cluster-key" -}}
{{- randAlphaNum 16 | nospace | b64enc -}}
{{- end -}}


{{- define "px.affinityPxEnabledOperator" -}}
{{- if .Values.requirePxEnabledTag -}}
    {{- "In" }}
{{- else -}}
    {{ "NotIn" }}
{{- end -}}
{{- end -}}


{{- define "px.getDeploymentNamespace" -}}
{{- if (.Release.Namespace) -}}
    {{- if (eq "default" .Release.Namespace) -}}
        {{- printf "kube-system"  -}}
    {{- else -}}
        {{- printf "%s" .Release.Namespace -}}
    {{- end -}}
{{- end -}}
{{- end -}}



{{- define "px.affinityPxEnabledValue" -}}
{{- if .Values.requirePxEnabledTag -}}
    {{- "true"  | quote }}
{{- else -}}
    {{ "false" | quote }}
{{- end -}}
{{- end -}}

{{- define "px.deprecatedKvdbArgs" }}
{{- $result := "" }}
{{- if ne .Values.etcd.credentials "none:none" }}
    {{- $result = printf "%s -userpwd %s" $result .Values.etcd.credentials }}
{{- end }}
{{- if ne .Values.etcd.ca "none" }}
    {{- $result = printf "%s -ca %s" $result .Values.etcd.ca }}
{{- end }}
{{- if ne .Values.etcd.cert "none" }}
    {{- $result = printf "%s -cert %s" $result .Values.etcd.cert }}
{{- end }}
{{- if ne .Values.etcd.key "none" }}
    {{- $result = printf "%s -key %s" $result .Values.etcd.key }}
{{- end }}
{{- if ne .Values.consul.token "none" }}
    {{- $result = printf "%s -acltoken %s" $result .Values.consul.token }}
{{- end }}
{{- trim $result }}
{{- end }}

{{- define "px.miscArgs" }}
{{- $result := "" }}
{{- if (include "px.deprecatedKvdbArgs" .) }}
    {{- $result = printf "%s %s" $result (include "px.deprecatedKvdbArgs" .) }}
{{- end }}
{{- if ne .Values.miscArgs "none" }}
    {{- $result = printf "%s %s" $result .Values.miscArgs }}
{{- end }}
{{- trim $result }}
{{- end }}

{{- define "px.volumesPresent" }}
{{- $result := false }}
{{- if (default false .Values.isTargetOSCoreOS) }}
    {{- $result = true }}
{{- end }}
{{- if ne (default "none" .Values.etcd.certPath) "none" }}
    {{- $result = true }}
{{- end }}
{{- if .Values.volumes }}
    {{- $result = true }}
{{- end }}
{{- $result }}
{{- end }}
