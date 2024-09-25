# Rancher

{{- define "system_default_registry" -}}
{{- if .Values.global.cattle.systemDefaultRegistry -}}
{{- printf "%s/" .Values.global.cattle.systemDefaultRegistry -}}
{{- end -}}
{{- end -}}

# Windows Support

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
{{- if semverCompare "<1.14-0" .Capabilities.KubeVersion.GitVersion -}}
beta.kubernetes.io/os: linux
{{- else -}}
kubernetes.io/os: linux
{{- end -}}
{{- end -}}

# CRD Installation

{{- define "crd.established" -}}
{{- if not (regexMatch "^([a-zA-Z]+[.][a-zA-Z]*)+$" .) -}}
{{ required (printf "%s is not a valid CRD" .) "" }}
{{- else -}}
echo "beginning wait for {{ . }} to be established...";
num_tries=1;
until kubectl get crd {{ . }} -o=jsonpath='{range .status.conditions[*]}{.type}={.status} {end}' | grep -qE 'Established=True'; do
  if (( num_tries == 30 )); then
    echo "timed out waiting for {{ . }}";
    exit 1;
  fi;
  num_tries=$(( num_tries + 1 ));
  echo "{{ . }} is not established. Sleeping for 2 seconds and trying again...";
  sleep 2;
done;
echo "successfully established {{ . }}";
{{- end -}}
{{- end -}}