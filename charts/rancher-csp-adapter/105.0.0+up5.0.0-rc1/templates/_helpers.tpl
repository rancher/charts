{{- define "csp-adapter.labels" -}}
app: rancher-csp-adapter
{{- end }}

{{- define "csp-adapter.outputConfigMap" -}}
csp-config
{{- end }}

{{- define "csp-adapter.outputNotification" -}}
csp-compliance
{{- end }}

{{- define "csp-adapter.cacheSecret" -}}
csp-adapter-cache
{{- end }}

{{- define "csp-adapter.hostnameSetting" -}}
server-url
{{- end }}

{{- define "csp-adapter.versionSetting" -}}
server-version
{{- end }}

{{- define "csp-adapter.csp" -}}
{{- if .Values.aws -}}
    {{- if .Values.aws.enabled -}}
aws
    {{- end -}}
{{- else -}}
""
{{- end -}}
{{- end }}

{{- define "csp-adapter.awsValuesSet" -}}
{{- if .Values.aws -}}
    {{- if and .Values.aws.accountNumber .Values.aws.roleName -}}
    true
    {{- else -}}
    false
    {{- end -}}
{{- else -}}
false
{{- end -}}
{{- end }}

{{- define "system_default_registry" -}}
{{- if .Values.global.cattle.systemDefaultRegistry -}}
{{- printf "%s/" .Values.global.cattle.systemDefaultRegistry -}}
{{- else -}}
    {{- if eq (include "csp-adapter.csp" .) "aws" -}}
    {{- "709825985650.dkr.ecr.us-east-1.amazonaws.com/suse/" -}}
    {{- else -}}
    {{- "" -}}
    {{- end -}}
{{- end -}}
{{- end -}}
