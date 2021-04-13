{{/* Gets the correct API Version based on the version of the cluster
*/}}

{{- define "rbac.apiVersion" -}}
{{- if semverCompare ">= 1.8-0" .Capabilities.KubeVersion.GitVersion -}}
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
{{- $version := .Capabilities.KubeVersion.GitVersion -}}
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
        {{cat (trim .Values.customRegistryURL) "/portworx/" | replace " " ""}}
    {{- end -}}
{{- else -}}
        {{ "portworx" }}
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

{{- define "px.registryConfigType" -}}
{{- if semverCompare ">=1.9-0" .Capabilities.KubeVersion.GitVersion -}}
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
 String concatenation for drives in AWS section
*/}}
{{- define "px.storage" -}}
{{- $awsType1 := .Values.drive_1.aws.type -}}
{{- $awsType2 := .Values.drive_2.aws.type -}}
{{- $awsType3 := .Values.drive_3.aws.type -}}
{{- $awsType4 := .Values.drive_4.aws.type -}}
{{- $awsType5 := .Values.drive_5.aws.type -}}
{{- $awsType6 := .Values.drive_6.aws.type -}}
{{- $awsType7 := .Values.drive_7.aws.type -}}
{{- $awsType8 := .Values.drive_8.aws.type -}}
{{- $awsType9 := .Values.drive_9.aws.type -}}
{{- $awsType10 := .Values.drive_10.aws.type -}}

{{- $awsSize1 := .Values.drive_1.aws.size -}}
{{- $awsSize2 := .Values.drive_2.aws.size -}}
{{- $awsSize3 := .Values.drive_3.aws.size -}}
{{- $awsSize4 := .Values.drive_4.aws.size -}}
{{- $awsSize5 := .Values.drive_5.aws.size -}}
{{- $awsSize6 := .Values.drive_6.aws.size -}}
{{- $awsSize7 := .Values.drive_7.aws.size -}}
{{- $awsSize8 := .Values.drive_8.aws.size -}}
{{- $awsSize9 := .Values.drive_9.aws.size -}}
{{- $awsSize10 := .Values.drive_10.aws.size -}}

{{- $awsIops1 := .Values.drive_1.aws.iops -}}
{{- $awsIops2 := .Values.drive_2.aws.iops -}}
{{- $awsIops3 := .Values.drive_3.aws.iops -}}
{{- $awsIops4 := .Values.drive_4.aws.iops -}}
{{- $awsIops5 := .Values.drive_5.aws.iops -}}
{{- $awsIops6 := .Values.drive_6.aws.iops -}}
{{- $awsIops7 := .Values.drive_7.aws.iops -}}
{{- $awsIops8 := .Values.drive_8.aws.iops -}}
{{- $awsIops9 := .Values.drive_9.aws.iops -}}
{{- $awsIops10 := .Values.drive_10.aws.iops -}}

{{- $gcType1 := .Values.drive_1.gc.type -}}
{{- $gcType2 := .Values.drive_2.gc.type -}}
{{- $gcType3 := .Values.drive_3.gc.type -}}
{{- $gcType4 := .Values.drive_4.gc.type -}}
{{- $gcType5 := .Values.drive_5.gc.type -}}
{{- $gcType6 := .Values.drive_6.gc.type -}}
{{- $gcType7 := .Values.drive_7.gc.type -}}
{{- $gcType8 := .Values.drive_8.gc.type -}}
{{- $gcType9 := .Values.drive_9.gc.type -}}
{{- $gcType10 := .Values.drive_10.gc.type -}}

{{- $gcSize1 := .Values.drive_1.gc.size -}}
{{- $gcSize2 := .Values.drive_2.gc.size -}}
{{- $gcSize3 := .Values.drive_3.gc.size -}}
{{- $gcSize4 := .Values.drive_4.gc.size -}}
{{- $gcSize5 := .Values.drive_5.gc.size -}}
{{- $gcSize6 := .Values.drive_6.gc.size -}}
{{- $gcSize7 := .Values.drive_7.gc.size -}}
{{- $gcSize8 := .Values.drive_8.gc.size -}}
{{- $gcSize9 := .Values.drive_9.gc.size -}}
{{- $gcSize10 := .Values.drive_10.gc.size -}}

{{- $usefileSystemDrive := .Values.usefileSystemDrive | default false }}
{{- $usedrivesAndPartitions := .Values.usedrivesAndPartitions | default false }}
{{- $deployEnvironmentIKS := .Capabilities.KubeVersion.GitVersion | regexMatch "IKS" }}

{{- if eq "OnPrem" .Values.environment -}}
    {{- if eq "Manually specify disks" .Values.onpremStorage }}
            {{- if ne "none" .Values.existingDisk1 }}
                "-s", "{{- .Values.existingDisk1 }}",
            {{- end }}
            {{- if ne "none" .Values.existingDisk2 -}}
                "-s", "{{- .Values.existingDisk2 }}",
            {{- end }}
            {{- if ne "none" .Values.existingDisk3 -}}
                "-s", "{{- .Values.existingDisk3 }}",
            {{- end }}
            {{- if ne "none" .Values.existingDisk4 -}}
                "-s", "{{- .Values.existingDisk4 }}",
            {{- end }}
            {{- if ne "none" .Values.existingDisk5 }}
                "-s", "{{- .Values.existingDisk5 }}",
            {{- end }}
    {{- else if eq "Automatically scan disks" .Values.onpremStorage -}}
       {{- if or $usedrivesAndPartitions $deployEnvironmentIKS }}
           "-f",
       {{- end }}
       {{- if eq $usedrivesAndPartitions true }}
           "-A",
       {{- else }}
           "-a",
       {{- end -}}
    {{- end -}}

{{- else if eq "Cloud" .Values.environment -}}
    {{- if eq "Consume Unused" .Values.deviceConfig -}}
       {{- if or $usedrivesAndPartitions $deployEnvironmentIKS }}
           "-f",
       {{- end }}
       {{- if eq $usedrivesAndPartitions true }}
           "-A",
       {{- else }}
           "-a",
       {{- end -}}
    {{- end }}
{{/*------------------- ----------------- Google cloud/GKE -------------- --------------- */}}
    {{- if eq "Google cloud/GKE" .Values.provider -}}
        {{- if eq "Use Existing Disks" .Values.deviceConfig -}}
            {{- if .Values.existingDisk1 -}}
                "-s", "{{- .Values.existingDisk1 -}}",
            {{- end -}}
            {{- if ne "none" .Values.existingDisk2 -}}
                "-s", "{{- .Values.existingDisk2 -}}",
            {{- end -}}
            {{- if ne "none" .Values.existingDisk3 -}}
                "-s", "{{- .Values.existingDisk3 -}}",
            {{- end -}}
            {{- if ne "none" .Values.existingDisk4 -}}
                "-s", "{{- .Values.existingDisk4 -}}",
            {{- end -}}
            {{- if ne "none" .Values.existingDisk5 -}}
                "-s", "{{- .Values.existingDisk5 -}}",
            {{- end -}}
        {{- else if eq "Create Using a Spec" .Values.deviceConfig -}}
            {{- if $gcType1 }}
                "-s", "type=pd-{{$gcType1 | lower}},size={{$gcSize1}}",
            {{- end }}
            {{/*------------------- DRIVE 2 --------------- */}}
            {{- if $gcType2 -}}
                "-s", "type=pd-{{$gcType2 | lower}},size={{$gcSize2}}",
            {{- end }}
            {{/*------------------- DRIVE 3 --------------- */}}
            {{- if $gcType3 -}}
                "-s", "type=pd-{{$gcType3 | lower}},size={{$gcSize3}}",
            {{- end }}
            {{/*------------------- DRIVE 4 --------------- */}}
            {{- if $gcType4 -}}
                "-s", "type=pd-{{$gcType4 | lower}},size={{$gcSize4}}",
            {{- end }}
            {{/*------------------- DRIVE 5 --------------- */}}
            {{- if $gcType5 -}}
                "-s", "type=pd-{{$gcType5 | lower}},size={{$gcSize5}}",
            {{- end }}
            {{/*------------------- DRIVE 6 --------------- */}}
            {{- if $gcType6 -}}
                "-s", "type=pd-{{$gcType6 | lower}},size={{$gcSize6}}",
            {{- end }}
            {{/*------------------- DRIVE 7 --------------- */}}
            {{- if $gcType7 -}}
                "-s", "type=pd-{{$gcType7 | lower}},size={{$gcSize7}}",
            {{- end }}
            {{/*------------------- DRIVE 8 --------------- */}}
            {{- if $gcType8 -}}
                "-s", "type=pd-{{$gcType8 | lower}},size={{$gcSize8}}",
            {{- end }}
            {{/*------------------- DRIVE 9 --------------- */}}
            {{- if $gcType9 -}}
                "-s", "type=pd-{{$gcType9 | lower}},size={{$gcSize9}}",
            {{- end }}
            {{/*------------------- DRIVE 10 --------------- */}}
            {{- if $gcType10 -}}
                "-s", "type=pd-{{$gcType1 | lower}},size={{$gcSize10}}",
            {{- end }}
        {{- end -}}
{{/*------------------- ----------------- AWS -------------- --------------- */}}
    {{- else if eq "AWS" .Values.provider -}}
        {{- if eq "Use Existing Disks" .Values.deviceConfig -}}
            {{- if ne "none" .Values.existingDisk1 -}}
                "-s", "{{ .Values.existingDisk1 }}",
            {{- end -}}
            {{- if ne "none" .Values.existingDisk2 -}}
                "-s", "{{ .Values.existingDisk2 }}",
            {{- end -}}
            {{- if ne "none" .Values.existingDisk3 -}}
                "-s", "{{ .Values.existingDisk3 }}",
            {{- end -}}
            {{- if ne "none" .Values.existingDisk4 -}}
                "-s", "{{ .Values.existingDisk4 }}",
            {{- end -}}
            {{- if ne "none" .Values.existingDisk5 -}}
                "-s", "{{ .Values.existingDisk5 }}",
            {{- end -}}
        {{- else if eq "Create Using a Spec" .Values.deviceConfig -}}
            {{- if ne "none" $awsType1 }}
                {{- if eq "GP2" $awsType1 -}}
                    "-s", "type={{$awsType1 | lower}},size={{$awsSize1}}",
                {{- else if eq "IO1" $awsType1 -}}
                    "-s", "type={{$awsType1 | lower}},size={{$awsSize1}},iops={{$awsIops1}}",
                {{- end }}
            {{- end }}
            {{/*------------------- DRIVE 2 --------------- */}}
            {{- if ne "none" $awsType2 -}}
                {{- if eq "GP2" $awsType2 -}}
                    "-s", "type={{$awsType2 | lower}},size={{$awsSize2}}",
                {{- else if eq "IO1" $awsType2 -}}
                    "-s", "type={{$awsType2 | lower}},size={{$awsSize2}},iops={{$awsIops2}}",
                {{- end -}}
            {{- end }}
            {{/*------------------- DRIVE 3 --------------- */}}
            {{- if ne "none" $awsType3 }}
                {{- if eq "GP2" $awsType3 -}}
                    "-s", "type={{$awsType3 | lower}},size={{$awsSize3}}",
                {{- else if eq "IO1" $awsType3 -}}
                    "-s", "type={{$awsType3 | lower}},size={{$awsSize3}},iops={{$awsIops3}}",
                {{- end -}}
            {{- end }}
            {{/*------------------- DRIVE 4 --------------- */}}
            {{- if ne "none" $awsType4 }}
                {{- if eq "GP2" $awsType4 -}}
                    "-s", "type={{$awsType4 | lower}},size={{$awsSize4}}",
                {{- else if eq "IO1" $awsType4 -}}
                    "-s", "type={{$awsType4 | lower}},size={{$awsSize4}},iops={{$awsIops4}}",
                {{- end -}}
            {{- end }}
            {{/*------------------- DRIVE 5 --------------- */}}
            {{- if ne "none" $awsType5 }}
                {{- if eq "GP2" $awsType5 -}}
                    "-s", "type={{$awsType5 | lower}},size={{$awsSize5}}",
                {{- else if eq "IO1" $awsType5 -}}
                    "-s", "type={{$awsType5 | lower}},size={{$awsSize5}},iops={{$awsIops5}}",
                {{- end -}}
            {{- end }}
            {{/*------------------- DRIVE 6 --------------- */}}
            {{- if ne "none" $awsType6 }}
                {{- if eq "GP2" $awsType6 -}}
                    "-s", "type={{$awsType6 | lower}},size={{$awsSize6}}",
                {{- else if eq "IO1" $awsType6 -}}
                    "-s", "type={{$awsType6 | lower}},size={{$awsSize6}},iops={{$awsIops6}}",
                {{- end -}}
            {{- end }}
            {{/*------------------- DRIVE 7 --------------- */}}
            {{- if ne "none" $awsType7 }}
                {{- if eq "GP2" $awsType7 -}}
                    "-s", "type={{$awsType7 | lower}},size={{$awsSize7}}",
                {{- else if eq "IO1" $awsType7 -}}
                    "-s", "type={{$awsType7 | lower}},size={{$awsSize7}},iops={{$awsIops7}}",
                {{- end -}}
            {{- end }}
            {{/*------------------- DRIVE 8 --------------- */}}
            {{- if ne "none" $awsType8 }}
                {{- if eq "GP2" $awsType8 -}}
                    "-s", "type={{$awsType8 | lower}},size={{$awsSize8}}",
                {{- else if eq "IO1" $awsType8 -}}
                    "-s", "type={{$awsType8 | lower}},size={{$awsSize8}},iops={{$awsIops8}}",
                {{- end -}}
            {{- end }}
            {{/*------------------- DRIVE 9 --------------- */}}
            {{- if ne "none" $awsType9 }}
                {{- if eq "GP2" $awsType9 -}}
                    "-s", "type={{$awsType9 | lower}},size={{$awsSize9}}",
                {{- else if eq "IO1" $awsType9 -}}
                    "-s", "type={{$awsType9 | lower}},size={{$awsSize9}},iops={{$awsIops9}}",
                {{- end -}}
            {{- end }}
            {{/*------------------- DRIVE 10 --------------- */}}
            {{- if ne "none" $awsType10 }}
                {{- if eq "GP2" $awsType10 -}}
                    "-s", "type={{$awsType10 | lower}},size={{$awsSize10}}",
                {{- else if eq "IO1" $awsType10 -}}
                    "-s", "type={{$awsType10 | lower}},size={{$awsSize10}},iops={{$awsIops10}}",
                {{- end -}}
            {{- end }}
        {{- end -}}
        {{- end -}}
    {{- end -}}
{{- end }}

