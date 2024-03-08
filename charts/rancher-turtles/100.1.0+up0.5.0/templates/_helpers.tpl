{{/*
    This removes the part after the + in the kubernetes version string.
    v1.27.4+k3s1 -> v1.27.4
    v1.26.12-eks-5e0fdde -> v1.26.12
    v1.26.12-gke.1 -> v1.26.12
    v1.28.0 -> v1.28.0
*/}}
{{- define "strippedKubeVersion" -}}
    {{- if (.Capabilities.KubeVersion.Version | contains "-eks-") -}}
        {{- $parts := split "-eks-" .Capabilities.KubeVersion.Version -}}
        {{- print $parts._0 -}}
    {{- else if (.Capabilities.KubeVersion.Version | contains "-gke.") -}}
        {{- $parts := split "-gke." .Capabilities.KubeVersion.Version -}}
        {{- print $parts._0 -}}
    {{- else if (.Capabilities.KubeVersion.Version | contains "-aks") -}}
        {{- $parts := split "-aks" .Capabilities.KubeVersion.Version -}}
        {{- print $parts._0 -}}
    {{- else -}}
        {{- $parts := split "+" .Capabilities.KubeVersion.Version -}}
        {{- print $parts._0 -}}
    {{- end -}}
{{- end -}}
