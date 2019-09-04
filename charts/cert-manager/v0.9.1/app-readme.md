# cert-manager

cert-manager is a Kubernetes addon to automate the management and issuance of TLS certificates from various issuing sources.  
It will ensure certificates are valid and up to date periodically, and attempt to renew certificates at an appropriate time before expiry.

## How to Use It
In order to begin issuing certificates, you will need to set up a ClusterIssuer or Issuer resource (for example, by creating a 'letsencrypt-staging' issuer).
More information on the different types of issuers and how to configure them can be found in our [documentation](https://docs.cert-manager.io/en/latest/tasks/issuers/index.html).

### Automatically creating Certificates for Ingress resources - [Ingress-shim](https://cert-manager.readthedocs.io/en/latest/reference/ingress-shim.html#ingress-shim)
cert-manager can be configured to automatically provision TLS certificates for Ingress resources via annotations on your Ingresses.
```
certmanager.k8s.io/cluster-issuer: letsencrypt-staging # your cluerissuer name
```

The following example describe how to issue certificate with `cert-manager` in your Ingress definition.
```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations: 
    # add an annotation indicating the issuer to use.
    certmanager.k8s.io/cluster-issuer: nameOfClusterIssuer
spec:
  tls: # < placing a host in the TLS config will indicate a cert should be created
  - hosts:
    - myingress.com
    secretName: myingress-cert # < cert-manager will store the created certificate in this secret.
```
