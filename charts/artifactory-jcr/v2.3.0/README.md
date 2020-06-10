# JFrog Container Registry Helm Chart

JFrog Container Registry is a free Artifactory edition with Docker and Helm repositories support.

## Prerequisites Details

* Kubernetes 1.12+

## Chart Details
This chart will do the following:

* Deploy JFrog Container Registry
* Deploy an optional Nginx server
* Deploy an optional PostgreSQL Database
* Optionally expose Artifactory with Ingress [Ingress documentation](https://kubernetes.io/docs/concepts/services-networking/ingress/)

## Installing the Chart

### Add JFrog Helm repository
Before installing JFrog helm charts, you need to add the [JFrog helm repository](https://charts.jfrog.io/) to your helm client
```bash
helm repo add jfrog https://charts.jfrog.io
```

### Install Chart
To install the chart with the release name `jfrog-container-registry`:
```bash
helm upgrade --install jfrog-container-registry --set postgresql.postgresqlPassword=<postgres_password> --namespace artifactory-jcr jfrog/artifactory-jcr
```

### Accessing JFrog Container Registry
**NOTE:** If using artifactory or nginx service type `LoadBalancer`, it might take a few minutes for JFrog Container Registry's public IP to become available.

### Updating JFrog Container Registry
Once you have a new chart version, you can upgrade your deployment with
```bash
helm upgrade jfrog-container-registry jfrog/artifactory-jcr
```

### Deleting JFrog Container Registry

On helm v2:
```bash
helm delete --purge jfrog-container-registry
```

On helm v3:
```bash                                                                                                                                                                 
helm delete jfrog-container-registry --namespace artifactory-jcr                                                                                                                       
```  

This will delete your JFrog Container Registry deployment.<br>
**NOTE:** You might have left behind persistent volumes. You should explicitly delete them with
```bash
kubectl delete pvc ...
kubectl delete pv ...
```

## Database
The JFrog Container Registry chart comes with PostgreSQL deployed by default.<br>
For details on the PostgreSQL configuration or customising the database, Look at the options described in the [Artifactory helm chart](https://github.com/jfrog/charts/tree/master/stable/artifactory). 

## Configuration
The following table lists the **basic** configurable parameters of the JFrog Container Registry chart and their default values.

**NOTE:** All supported parameters are documented in the main [artifactory helm chart](https://github.com/jfrog/charts/tree/master/stable/artifactory).

|         Parameter                              |           Description             |                         Default                   |
|------------------------------------------------|-----------------------------------|---------------------------------------------------|
| `artifactory.artifactory.image.repository`     | Container image                   | `docker.bintray.io/jfrog/artifactory-jcr`         |
| `artifactory.artifactory.image.version`        | Container tag                     | `.Chart.AppVersion`                               |
| `artifactory.artifactory.resources`            | Artifactory container resources   | `{}`                                              |
| `artifactory.artifactory.javaOpts`             | Artifactory Java options          | `{}`                                              |
| `artifactory.nginx.enabled`                    | Deploy nginx server               | `true`                                            |
| `artifactory.nginx.service.type`               | Nginx service type                | `LoadBalancer`                                    |
| `artifactory.nginx.tlsSecretName`              | TLS secret for Nginx pod          | ``                                                |
| `artifactory.ingress.enabled`                  | Enable Ingress (should come with `artifactory.nginx.enabled=false`) | `false`         |
| `artifactory.ingress.tls`                      | Ingress TLS configuration (YAML)  | `[]`                                              |
| `artifactory.postgresql.enabled`               | Use the Artifactory PostgreSQL sub chart       | `true`                               |
| `artifactory.database`                         | Custom database configuration (if not using bundled PostgreSQL sub-chart) |           |
| `postgresql.enabled`                           | Enable the Artifactory PostgreSQL sub chart    | `true`                               |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

### Ingress and TLS
To get Helm to create an ingress object with a hostname, add these two lines to your Helm command:
```bash
helm upgrade --install jfrog-container-registry \
  --set artifactory.nginx.enabled=false \
  --set artifactory.ingress.enabled=true \
  --set artifactory.ingress.hosts[0]="artifactory.company.com" \
  --set artifactory.artifactory.service.type=NodePort \
  --namespace artifactory-jcr jfrog/artifactory-jcr
```

To manually configure TLS, first create/retrieve a key & certificate pair for the address(es) you wish to protect. Then create a TLS secret in the namespace:

```bash
kubectl create secret tls artifactory-tls --cert=path/to/tls.cert --key=path/to/tls.key
```

Include the secret's name, along with the desired hostnames, in the Artifactory Ingress TLS section of your custom `values.yaml` file:

```yaml
artifactory:
  artifactory:
    ingress:
      ## If true, Artifactory Ingress will be created
      ##
      enabled: true

      ## Artifactory Ingress hostnames
      ## Must be provided if Ingress is enabled
      ##
      hosts:
        - jfrog-container-registry.domain.com
      annotations:
        kubernetes.io/tls-acme: "true"
      ## Artifactory Ingress TLS configuration
      ## Secrets must be manually created in the namespace
      ##
      tls:
        - secretName: artifactory-tls
          hosts:
            - jfrog-container-registry.domain.com
```

## Useful links
https://www.jfrog.com
https://www.jfrog.com/confluence/
