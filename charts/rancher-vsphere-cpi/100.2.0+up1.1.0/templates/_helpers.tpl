{{- define "system_default_registry" -}}
{{- if .Values.global.cattle.systemDefaultRegistry -}}
{{- printf "%s/" .Values.global.cattle.systemDefaultRegistry -}}
{{- else -}}
{{- "" -}}
{{- end -}}
{{- end -}}

{{- /* Return the image override if one is defined in the chart values. */ -}}
{{- define "get_image_override" -}}
{{- if hasKey .Values.cloudControllerManager.image "override" -}}
{{- if and (hasKey .Values.cloudControllerManager.image.override "repository") (hasKey .Values.cloudControllerManager.image.override "tag") -}}
{{- printf "%s:%s" .Values.cloudControllerManager.image.override.repository .Values.cloudControllerManager.image.override.tag -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- /* Return the image's repository and tag corresponding to the cluster's kubernetes version. */ -}}
{{- define "get_image" -}}
{{- $kubeVersion := printf "%s.%s" .Capabilities.KubeVersion.Major .Capabilities.KubeVersion.Minor -}}
{{- if hasKey .Values.cloudControllerManager.image $kubeVersion -}}
{{- $imageForKubeVersion := get .Values.cloudControllerManager.image $kubeVersion -}}
{{- printf "%s:%s" $imageForKubeVersion.repository $imageForKubeVersion.tag -}}
{{- else -}}
{{- $supportedVersions := include "get_supported_k8s_versions" . -}}
{{- required (printf "unsupported Kubernetes version: %s (supported versions: %s)" $kubeVersion $supportedVersions) "" -}}
{{- end -}}
{{- end -}}

{{- /* Return string of a comma separated list of the k8s version lines the chart supports in the `major.minor.x` format. */ -}}
{{- define "get_supported_k8s_versions" -}}
{{- $versions := list -}}
{{- range $k, $v := .Values.cloudControllerManager.image -}}
{{- $versions = append $versions (printf "%s.x" $k) -}}
{{- end -}}
{{- join ", " $versions -}}
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