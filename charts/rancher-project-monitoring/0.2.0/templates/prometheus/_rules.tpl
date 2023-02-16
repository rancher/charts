{{- define "rules.names" }}
rules:
  - "alertmanager.rules"
  - "general.rules"
  - "kubernetes-storage"
  - "prometheus"
  - "kubernetes-apps"
{{- end }}