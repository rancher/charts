### Run-Time Protection Without Compromise

NeuVector delivers a complete run-time security solution with container process/file system protection and vulnerability scanning combined with the only true Layer 7 container firewall. Protect sensitive data with a complete container security platform.

Helm chart for NeuVector's monitoring services. Please make sure REST API service for controller in core chart is enabled.
 
Starting from version 5.4.6, NeuVector generates a secure password and stores it in the neuvector-bootstrap-secret. On first login, the default admin must retrieve the password using: 
`kubectl get secret -n cattle-neuvector-system neuvector-bootstrap-secret  -o go-template='{{ .data.bootstrapPassword | base64decode }}{{ "\n" }}'`
The password must be changed during the first login via the NeuVector UI. User should provide this admin password when deploying prometheus exporter.
