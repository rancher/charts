{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "neuvector.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "neuvector.fullname" -}}
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
{{- define "neuvector.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Will populate value with Rancher's configured system default registry (i.e. registry.rancher.com)
*/}}
{{- define "system_default_registry" -}}
{{- if .Values.global.cattle.systemDefaultRegistry -}}
{{- printf "%s/" .Values.global.cattle.systemDefaultRegistry -}}
{{- else -}}
{{- "" -}}
{{- end -}}
{{- end -}}

{{/*
CRI volume dictionary for 'enforcer-daemonset.yaml' and 'controller-deployment.yaml'
*/}}
{{- define "neuvector.criVolume" -}}
  {{- with .Values.systemSettings.containerRuntime }}
  {{- $criVolume := dict "bottlerocket" "/run/dockershim.sock" "containerd" "/var/run/containerd/containerd.sock" "crio" "/var/run/crio/crio.sock" "docker" "/var/run/docker.sock" "k3s" "/run/k3s/containerd/containerd.sock" "rke2" "/run/k3s/containerd/containerd.sock" -}}
  {{- get $criVolume . }}
  {{- end -}}
{{- end -}}

{{/*
CRI volumeMount dictionary for 'enforcer-daemonset.yaml' and 'controller-deployment.yaml'
*/}}
{{- define "neuvector.criVolumeMount" -}}
  {{- with .Values.systemSettings.containerRuntime }}
  {{- $criVolumeMount := dict "bottlerocket" "/run/dockershim.sock" "containerd" "/var/run/containerd/containerd.sock" "crio" "/var/run/crio/crio.sock" "docker" "/var/run/docker.sock" "k3s" "/var/run/containerd/containerd.sock" "rke2" "/var/run/containerd/containerd.sock" -}}
  {{- get $criVolumeMount . }}
  {{- end -}}
{{- end -}}

{{/*
RKE/2 Control Plane Tolerations. Used in 'controller.tolerateControlPlane:' and 'enforcer.tolerateControlPlane:'
*/}}
{{- define "neuvector.ctlplaneTolerations" -}}
- effect: NoExecute
  key: node-role.kubernetes.io/etcd
- effect: NoSchedule
  key: node-role.kubernetes.io/controlplane
- effect: NoSchedule
  key: node-role.kubernetes.io/control-plane
- effect: NoSchedule
  key: node-role.kubernetes.io/master
{{- end -}}

{{/*
The below templates will generate YAML documents for 'init-configmap.yaml'
and 'init-secret.yaml'.  Previously, these documents had to be explicitly
(and manually) created under 'controller.configmap' and 'controller.secret' blocks.
Further examples and options can be found at: https://raw.githubusercontent.com/neuvector/manifests/main/kubernetes/5.0.0/initcfg.yaml
*/}}

{{/*
Template for creating 'passwordprofileinitcfg.yaml'.  In values.yaml this is 'localPasswordProfile:'
*/}}
{{- define "neuvector.passwordprofileinitcfg" -}}
{{- with .Values.localPasswordProfile -}}
active_profile_name: default
pwd_profiles:
- name: default
  comment: default from configMap
  min_len: {{ .minLength | default 6 | int }}
  min_uppercase_count: {{ .minUppercase | default 0 | int }}
  min_lowercase_count: {{ .minLowercase | default 0 | int }}
  min_digit_count: {{ .minNumeric | default 0 | int }}
  min_special_count: {{ .minSpecialChar | default 0 | int }}
  enable_block_after_failed_login: {{ .lockoutEnabled | default "false" }}
  block_after_failed_login_count: {{ .lockoutAttempts | default 0 | int }}
  block_minutes: {{ .lockoutDuration | default 0 | int }}
  enable_password_expiration: {{ .expireEnabled | default "false" }}
  password_expire_after_days: {{ .expireAfter | default 0 | int }}
  enable_password_history: {{ .historyEnabled | default "false" }}
  password_keep_history_count: {{ .historyCount | default 0 | int }}
{{- end }}
{{- end }}

{{/*
Template for creating 'roleinitcfg.yaml'. In values.yaml this is 'customUserRoles:'
*/}}
{{- define "neuvector.roleinitcfg" -}}
{{- with .Values.customUserRoles }}
{{- if .enabled -}}
roles:
{{- range $roles := .roles }}
- Comment: {{ .roleDescription | quote }}
  Name: {{ required "Role name is required." .roleName | quote }}
  Permissions:
    - id: {{ required "RoleID is required." .roleID | quote }}
      read: {{ .read }}
      write: {{ .write }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Template for creating 'sysinitcfg.yaml'.  In values.yaml this is 'systemSettings:'
*/}}
{{- define "neuvector.sysinitcfg" -}}
{{- with .Values.systemSettings -}}
always_reload: true
New_Service_Policy_Mode: {{ .newServiceMode | default "Discover" | quote }}
New_Service_Profile_Baseline: {{ .zeroDrift | default "zero-drift" | quote }}
{{- if .syslog.enabled }}
Syslog_ip: {{ required "Syslog server IP is required if Syslog is enabled." .syslog.serverIP | quote }}
Syslog_IP_Proto: {{ if eq .syslog.protocol "udp" }} 
                  {{- print 17 | int -}}
                  {{ else if eq .syslog.protocol "tcp" }} 
                  {{- print 6 | int -}}
                  {{ end }}
Syslog_Port: {{ .syslog.serverPort | default 514 | int }}
Syslog_Level: {{ .syslog.loglevel | default "Info" | quote }}
Syslog_status: {{ .syslog.enabled | default "false"}}
Syslog_Categories:
{{- range $syslogCategory := .syslog.categories }}
  - {{ $syslogCategory }}
{{- end }}
Syslog_in_json: {{ .syslog.jsonOutput }}
{{- end }}
Auth_By_Platform: true
{{- if .notificationWebhooks.enabled }}
Webhooks:
  {{- range $webhooks := .notificationWebhooks.webhooks }}
  - name: {{ $webhooks.name }}
    url: {{ $webhooks.url }}
    type: {{ $webhooks.type }}
    enable: {{ $webhooks.enable | default "true" }}
  {{- end }}
{{- end }}  
Cluster_Name: {{ .clusterName | default "cluster.local" | quote }}
{{- if .registryProxy.http.enabled }}
{{- with .registryProxy.http }}
Registry_Http_Proxy_Status: true
Registry_Http_Proxy:
  URL: {{ required "URL must be set if HTTP proxy is enabled." .httpProxy.url | quote }}
  Username: {{ .httpProxy.username | quote }}
  Password: {{ .httpProxy.password | quote }}
{{- end }}
{{- end }}
{{- if .registryProxy.https.enabled }}
{{- with .registryProxy.https }}
Registry_Https_Proxy_Status: true
Registry_Https_Proxy:
  URL: {{ required "URL must be set if HTTPS proxy is enabled." .httpsProxy.url | quote }}
  Username: {{ .httpsProxy.username | quote }}
  Password: {{ .httpsProxy.password | quote }}
{{- end }}
{{- end }}
Xff_Enabled: true
Net_Service_Status: false
Net_Service_Policy_Mode: Discover
Scanner_Autoscale:
{{- with .scannerAutoscale }}
  Strategy: {{ .strategy | default "delayed" | quote }}
  Min_Pods: {{ .minPods | default 1 | int }}
  Max_Pods: {{ .maxPods | default 3 | int }}
{{- end }}
No_Telemetry_Report: {{ .noTelemetryReport }}
Scan_Config:
  Auto_Scan: {{ .autoScan | default "false" }}
Unused_Group_Aging: {{ .unusedGroupAging | default 24 | int }}
{{- end }}
{{- end }}

{{/*
Template for creating 'userinitcfg.yaml'. In values.yaml this is 'localUsers:'
*/}}
always_reload: true
{{- define "neuvector.userinitcfg" -}}
{{- with .Values.localUsers -}}
users:
{{- if .enabled }}
{{- range $users := .users }}
- Fullname: {{ $users.username | quote }}
  Password: {{ $users.password | quote }}
  Role: {{ $users.role | quote }}
  Email: {{ $users.email | quote }}
  Locale: {{ $users.locale | quote }}
  Timeout: {{ $users.timeout | default 450 | int }}
{{- end }}
{{- end }}
{{- end }}
{{- with .Values.monitoring -}}
{{- if and .enabled .exporter.enabled }}
- Fullname: {{ .exporter.credentials.Fullname | quote }}
  Password: {{ .exporter.credentials.Password | quote }}
  Role: "reader"
{{- end }}
{{- end }}
{{- with .Values.systemSettings.createLocalAdmin }}
{{- if .create }}
- Fullname: "admin"
  Password: {{ required "Admin password must be set." .password | quote }}
  Role: "admin"
{{- end }}
{{- end }}
{{- end }}

{{/*
End of YAML document templates
*/}}