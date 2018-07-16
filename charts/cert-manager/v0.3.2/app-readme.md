# Cert-Manager

cert-manager is a Kubernetes addon to automate the management and issuance of
TLS certificates from various issuing sources.

It will ensure certificates are valid and up to date periodically, and attempt
to renew certificates at an appropriate time before expiry.

## How to Use It
Cert-manager will create Certificate resources that reference the ClusterIssuer for all Ingresses that have a `kubernetes.io/tls-acme: "true"` annotation.
