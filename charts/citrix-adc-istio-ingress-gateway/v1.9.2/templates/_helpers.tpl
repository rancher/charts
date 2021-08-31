{{- define "exporter_nsip" -}}
{{- $match := .Values.ingressGateway.netscalerUrl | toString | regexFind "//.*[:]*" -}}
{{- $match | trimAll ":" | trimAll "/" -}}
{{- end -}}

{{/* A common function to generate name of the resource. 
   * Usage: {{ template "generate-name" (list . (dict "suffixname" "citrix-deployment")) }} 
   * In above example, arguments are given in the list. 
   * First one is `.` indicating global chart-level scope. 
   * Second argument name is `suffixname` and value is `citrix-deployment`.
   * If release name is `my-release`, then generate-name function would output "my-release-citrix-deployment".
   * The function truncates name to 63 chars due to Kubernetes name length restrictions
*/}}
{{- define "generate-name" -}}
{{- $top := index . 0 -}}
{{- $arg1 := index . 1 "suffixname" -}}
{{- printf "%s-%s" $top.Release.Name $arg1 | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Another common function to generate name of the resource. 
   * Usage: {{ template "generate-name" (list . "citrix-deployment") }} 
   * In above example, arguments are given in the list. 
   * First one is `.` indicating global chart-level scope. 
   * Second argument is unnamed and takes value as `citrix-deployment`.
   * If release name is `my-release`, then generate-name function would output "my-release-citrix-deployment".
   * The function truncates name to 63 chars due to Kubernetes name length restrictions
*/}}
{{- define "generate-name2" -}}
{{- $top := index . 0 -}}
{{- $arg1 := index . 1 -}}
{{- printf "%s-%s" $top.Release.Name $arg1 | trunc 63 | trimSuffix "-" }}
{{- end }}

