{{- define "featuresList" -}}
{{- $local := dict "first" true -}}
"features":{ {{- range $k, $v := . -}}
    {{- if not $local.first -}},{{- end -}}
    "{{$k}}":{"enabled":{{$v}}}{{- $_ := set $local "first" false -}}
    {{- end -}}
{{- end -}}}

