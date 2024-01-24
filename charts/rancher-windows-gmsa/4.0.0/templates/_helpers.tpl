# Rancher

{{- define "system_default_registry" -}}
{{- if .Values.global.cattle.systemDefaultRegistry -}}
{{- printf "%s/" .Values.global.cattle.systemDefaultRegistry -}}
{{- end -}}
{{- end -}}

{{/* Create chart name and version as used by the chart label. */}}
{{- define "gmsa.chartref" -}}
chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end }}

{{/* Determine apiVersion for cert-manager */}}
{{- define "cert-manager.apiversion" -}}
  {{- $certmanagerVer :=  split "." .Values.certificates.certManager.version -}}
  {{- if or (.Capabilities.APIVersions.Has "cert-manager.io/v1") (and (gt (len $certmanagerVer._0) 0) (eq (int $certmanagerVer._0) 1) (ge (int $certmanagerVer._1) 0)) }}
apiVersion: cert-manager.io/v1
  {{- else if or (.Capabilities.APIVersions.Has "cert-manager.io/v1beta1") (and (gt (len $certmanagerVer._0) 0) (eq (int $certmanagerVer._0) 0) (ge (int $certmanagerVer._1) 16)) }}
apiVersion: cert-manager.io/v1beta1
  {{- else if or (.Capabilities.APIVersions.Has "cert-manager.io/v1alpha2") (and (gt (len $certmanagerVer._0) 0) (eq (int $certmanagerVer._0) 0) (ge (int $certmanagerVer._1) 11)) }}
apiVersion: cert-manager.io/v1alpha2
  {{- else if or (.Capabilities.APIVersions.Has "certmanager.k8s.io/v1alpha1") (and (gt (len $certmanagerVer._0) 0) (eq (int $certmanagerVer._0) 0) (lt (int $certmanagerVer._1) 11)) }}
apiVersion: cert-manager.io/v1alpha1
  {{- else }}
apiVersion: cert-manager.io/v1
  {{- end }}
{{- end }}

{{- define "certificates.cabundle"}}
{{- if gt (len (lookup "rbac.authorization.k8s.io/v1" "ClusterRole" "" "")) 0 -}}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace .Values.certificates.secretName) -}}
{{- if lt (len $secret) 1 -}}
{{- required (printf "CA Bundle secret '%s' in namespace '%s' must exist" .Values.certificates.secretName .Release.Namespace) "" -}}
{{- else -}}
{{- if not (hasKey $secret "data") -}}
{{- required (printf "CA Bundle secret '%s' in namespace '%s' is empty" .Values.certificates.secretName .Release.Namespace) "" -}}
{{- end -}}
{{- if or (not (hasKey $secret.data "ca.crt")) (not (hasKey $secret.data "tls.crt")) (not (hasKey $secret.data "tls.key")) -}}
{{- required (printf "CA Bundle secret '%s' in namespace '%s' must contain ca.crt, tls.key, and tls.cert; found the following keys in the secret: %s" .Values.certificates.secretName .Release.Namespace $secret.data) "" -}}
{{- end -}}
{{- end -}}
{{- get $secret.data "ca.crt" }}
{{- else -}}
INSERT_CERTIFICATE_FROM_SECRET
{{- end -}}
{{- end }}

