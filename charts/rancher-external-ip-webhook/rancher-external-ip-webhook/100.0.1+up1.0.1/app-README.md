# externalip-webhook

This chart was created to mitigate [CVE-2020-8554](https://www.cvedetails.com/cve/CVE-2020-8554/)

External IP Webhook is a validating k8s webhook which prevents services from using random external IPs. 
Cluster administrators can specify list of CIDRs allowed to be used as external IP by specifying `allowed-external-ip-cidrs` parameter. The webhook will only allow services which either don’t set external IP, or whose external IPs are within the range specified by the administrator.

External IP Webhook certificates are required. They can be generated in 2 ways:
* cert-manager: This is the default chart configuration. Cert manager should be already installed at the k8s cluster
* uploading certs: Disable `Cert Manager integration` and set `Secret name` and `CA Bundle` at  `Certificates` section.

For more information, review the Helm README of this chart.
