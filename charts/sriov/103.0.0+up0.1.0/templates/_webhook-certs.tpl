{{/*
Generate TLS certificates for webhooks.
Note: these 2 lines, that are repeated several times below, are a trick to
ensure the CA certs are generated only once:
    $ca := .ca | default (genCA "sriov-network-operator.k8s.cni.cncf.io" 365)
    $_ := set . "ca" $ca
Please, don't try to "simplify" them as without this trick, every generated
certificate would be signed by a different CA.
*/}}
{{- define "sriov_operator_ca_cert" }}
{{- $ca := .ca | default (genCA "sriov-network-operator.k8s.cni.cncf.io" 365) -}}
{{- $_ := set . "ca" $ca -}}
{{- printf "%s" $ca.Cert | b64enc -}}
{{- end }}
{{- define "sriov_operator_cert" }}
{{- $ca := .ca | default (genCA "sriov-network-operator.k8s.cni.cncf.io" 365) -}}
{{- $_ := set . "ca" $ca -}}
{{- $cn := printf "operator-webhook-service.%s.svc" .Release.Namespace -}}
{{- $cert := genSignedCert $cn nil (list $cn) 365 $ca -}}
tls.crt: {{ $cert.Cert | b64enc }}
tls.key: {{ $cert.Key | b64enc }}
{{- end }}
{{- define "sriov_resource_injector_cert" }}
{{- $ca := .ca | default (genCA "sriov-network-operator.k8s.cni.cncf.io" 365) -}}
{{- $_ := set . "ca" $ca -}}
{{- $cn := printf "network-resources-injector-service.%s.svc" .Release.Namespace -}}
{{- $cert := genSignedCert $cn nil (list $cn) 365 $ca -}}
tls.crt: {{ $cert.Cert | b64enc }}
tls.key: {{ $cert.Key | b64enc }}
{{- end }}

