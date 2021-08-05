# externalip-webhook

This chart was created to mitigate [CVE-2020-8554](https://www.cvedetails.com/cve/CVE-2020-8554/)

External IP Webhook is a validating k8s webhook which prevents services from using random external IPs. Cluster administrators
can specify list of CIDRs allowed to be used as external IP by specifying `allowed-external-ip-cidrs` parameter. 
The webhook will only allow services which either don’t set external IP, or whose external IPs are within the range specified by the administrator.

For more information, review the Helm README of this chart.
