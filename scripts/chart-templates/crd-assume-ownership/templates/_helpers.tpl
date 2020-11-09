# Rancher

{{- define "system_default_registry" -}}
{{- if .Values.global.cattle.systemDefaultRegistry -}}
{{- printf "%s/" .Values.global.cattle.systemDefaultRegistry -}}
{{- end -}}
{{- end -}}

{{/*
Creates a list of ConfigMaps that contain CRD files with the following format.
It ensures that no ConfigMap is >1mb in size.
name: $name-manifest-xx
crds:
  {{ path }}: {{ File }}
size: {{ size in characters }}
*/}}
{{- define "crd_manifest_configmaps" -}}
{{- \$currentScope := . -}}
{{- \$counter := dict "i" 0 -}}
{{/* Initialize the first configMap and add it to the list of ConfigMaps necessary */}}
{{- \$currName := (printf "%s-manifest-%02d" \$currentScope.Chart.Name (get \$counter "i")) -}}
{{- \$currConfigMap := dict "name" \$currName "size" 0 "crds" (dict) -}}
{{- \$configMaps := dict \$currName \$currConfigMap -}}
{{/* Iterate through the CRDs to add to the configMap or create a new one */}}
{{- range \$filepath, \$_ :=  (.Files.Glob "crd-manifest/**.yaml") -}}
{{- with \$currentScope -}}
{{/* Get current values from the dictionary */}}
{{- \$currConfigMap := get \$configMaps \$currName -}}
{{- \$currSize := get \$currConfigMap "size" -}}
{{- \$currCRDs := get \$currConfigMap "crds" -}}
{{/* Get the next CRD file that needs to be added to a ConfigMap */}}
{{- \$path := base \$filepath -}}
{{- \$file := .Files.Get \$filepath -}}
{{/* Check if the file size of the CRD causes size to exceed 1048576 characters, which requires a new ConfigMap */}}
{{- \$currSize := (add \$currSize (len \$file)) -}}
{{- if ge \$currSize 1000000 -}}
{{/* Create a new configMap */}}
{{- \$_ := set \$counter "i" (add (get \$counter "i") 1) }}
{{- \$currName := (printf "%s-manifest-%02d" \$currentScope.Chart.Name (get \$counter "i")) -}}
{{- \$currConfigMap := dict "name" \$currName "size" (len \$file) "crds" (dict \$path \$file) -}}
{{- \$_ := set \$configMaps \$currName \$currConfigMap -}}
{{- else -}}
{{/* Update the configMap */}}
{{- \$_ := set \$currCRDs \$path \$file -}}
{{- \$_ := set \$currConfigMap "crds" \$currCRDs -}}
{{- \$_ := set \$currConfigMap "size" \$currSize -}}
{{- \$_ := set \$configMaps \$currName \$currConfigMap -}}
{{- end -}}
{{- end -}}{{- end -}}
{{ \$configMaps | toYaml }}
{{- end -}}
