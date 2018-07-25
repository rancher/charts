# Elasticsearch Chart
This chart is based on the [elasticsearch/elasticsearch](https://www.docker.elastic.co/) image.
 
# Fluent-Bit Chart
[Fluent Bit](http://fluentbit.io/) is an open source and multi-platform Log Forwarder. 

This chart will do the following:
* Install a configmap for Fluent Bit
* Install a daemonset that provisions Fluent Bit [per-host architecture]

# kibana
[kibana](https://github.com/elastic/kibana) is your window into the Elastic Stack. Specifically, it's an open source (Apache Licensed), browser-based analytics and search dashboard for Elasticsearch.

# Configurations

## Elasticsearch
The following table lists the configurable parameters of the elasticsearch chart and their default values.

|              Parameter               |                             Description                             |               Default                |
| ------------------------------------ | ------------------------------------------------------------------- | ------------------------------------ |
| `image.repository`                   | Container image name                                                | `docker.elastic.co/elasticsearch/elasticsearch-oss` |
| `image.tag`                          | Container image tag                                                 | `6.2.4`                              |
| `image.pullPolicy`                   | Container pull policy                                               | `IfNotPresent`                       |
| `master.exposeHttp`                  | Expose http port 9200 on master Pods for monitoring, etc            | `true`                               |
| `master.replicas`                    | Master node replicas (statefulset)                                  | `3`                                  |
| `master.resources`                   | Master node resources requests & limits                             | `{} - cpu limit must be an integer`  |
| `master.heapSize`                    | Master node heap size                                               | `512m`                               |
| `master.name`                        | Master component name                                               | `master`                             |
| `master.persistence.enabled`         | Master persistent enabled/disabled                                  | `true`                               |
| `master.persistence.name`            | Master statefulset PVC template name                                | `data`                               |
| `master.persistence.size`            | Master persistent volume size                                       | `10Gi`                                |
| `master.persistence.storageClass`    | Master persistent volume Class                                      | `nil`                                |
| `master.persistence.accessMode`      | Master persistent Access Mode                                       | `ReadWriteOnce`                      |
| `master.antiAffinity`                | Data anti-affinity policy                                           | `soft`                               |
| `rbac.create`                        | Create service account and ClusterRoleBinding for Kubernetes plugin | `false`                              |


## Kibana
The following table lists the configurable parameters of the kibana chart and their default values.

Parameter | Description | Default
--- | --- | ---
`affinity` | node/pod affinities | None
`env` | Environment variables to configure Kibana | `{}`
`image.pullPolicy` | Image pull policy | `IfNotPresent`
`image.repository` | Image repository | `kibana`
`image.tag` | Image tag | `6.0.0`
`image.pullSecrets` |Specify image pull secrets | `nil`
`commandline.args` | add additional commandline args | `nil`
`ingress.enabled` | Enables Ingress | `false`
`ingress.annotations` | Ingress annotations | None:
`ingress.hosts` | Ingress accepted hostnames | None:
`ingress.tls` | Ingress TLS configuration | None:
`nodeSelector` | node labels for pod assignment | `{}`
`podAnnotations` | annotations to add to each pod | `{}`
`replicaCount` | desired number of pods | `1`
`resources` | pod resource requests & limits | `{}`
`service.externalPort` | external port for the service | `443`
`service.internalPort` | internal port for the service | `4180`
`service.externalIPs` | external IP addresses | None:
`service.loadBalancerIP` | Load Balancer IP address (to use with service.type LoadBalancer) | None:
`service.type` | type of service | `ClusterIP`
`service.annotations` | Kubernetes service annotations | None:
`tolerations` | List of node taints to tolerate | `[]`


## Fluent-Bit
The following tables lists the configurable parameters of the Fluent-Bit chart and the default values.

| Parameter                  | Description                        | Default                 |
| -----------------------    | ---------------------------------- | ----------------------- |
| **Backend Selection**      |
| `backend.type`             | Set the backend to which Fluent-Bit should flush the information it gathers | `forward` |
| **Forward Backend**        |
| `backend.forward.host`     | Target host where Fluent-Bit or Fluentd are listening for Forward messages | `fluentd` |
| `backend.forward.port`     | TCP Port of the target service | `24284` |
| **ElasticSearch Backend**  |
| `backend.es.host`          | IP address or hostname of the target Elasticsearch instance | `elasticsearch` |
| `backend.es.port`          | TCP port of the target Elasticsearch instance. | `9200` |
| `backend.es.index`         | Elastic Index name | `kubernetes_cluster` |
| `backend.es.type`          | Elastic Type name | `flb_type` |
| `backend.es.logstash_prefix`  | Index Prefix. If Logstash_Prefix is equals to 'mydata' your index will become 'mydata-YYYY.MM.DD'. | `kubernetes_cluster` |
| `backend.es.http_user`        | Optional username credential for Elastic X-Pack access. | `` |
| `backend.es.http_passwd:`     | Password for user defined in HTTP_User. | `` |
| `backend.es.tls`              | Enable or disable TLS support | `off` |
| `backend.es.tls_verify`       | Force certificate validation  | `on` |
| `backend.es.tls_ca`           | TLS CA certificate for the Elastic instance (in PEM format). Specify if tls: on. | `` |
| `backend.es.tls_debug`        | Set TLS debug verbosity level. It accept the following values: 0-4 | `1` |
| **HTTP Backend**              |
| `backend.http.host`           | IP address or hostname of the target HTTP Server | `127.0.0.1` |
| `backend.http.port`           | TCP port of the target HTTP Server | `80` |
| `backend.http.uri`            | Specify an optional HTTP URI for the target web server, e.g: /something | `"/"`
| `backend.http.format`         | Specify the data format to be used in the HTTP request body, by default it uses msgpack, optionally it can be set to json.  | `msgpack` |
| **Parsers**                   |
| `parsers.regex`                    | List of regex parsers | `NULL` |
| `parsers.json`                     | List of json parsers | `NULL` |
| **General**                   |
| `annotations`                      | Optional deamonset set annotations        | `NULL`                |
| `podAnnotations`                   | Optional pod annotations                  | `NULL`                |
| `existingConfigMap`                | ConfigMap override                         | ``                    |
| `extraVolumeMounts`                | Mount an extra volume, required to mount ssl certificates when elasticsearch has tls enabled |          |
| `extraVolume`                      | Extra volume                               |                                                |
| `filter.kubeURL`                   | Optional custom configmaps                 | `https://kubernetes.default.svc:443`            |
| `filter.kubeCAFile`                | Optional custom configmaps       | `/var/run/secrets/kubernetes.io/serviceaccount/ca.crt`    |
| `filter.kubeTokenFile`             | Optional custom configmaps       | `/var/run/secrets/kubernetes.io/serviceaccount/token`     |
| `filter.kubeTag`                   | Optional top-level tag for matching in filter         | `kube`                                 |
| `image.fluent_bit.repository`      | Image                                      | `fluent/fluent-bit`                               |
| `image.fluent_bit.tag`             | Image tag                                  | `0.13.0`                                          |
| `image.pullPolicy`                 | Image pull policy                          | `Always`                                          |
| `rbac.create`                      | Specifies whether RBAC resources should be created.   | `true`                                 |
| `serviceAccount.create`            | Specifies whether a ServiceAccount should be created. | `true`                                 |
| `serviceAccount.name`              | The name of the ServiceAccount to use.     | `NULL`                                            |
| `resources.limits.cpu`             | CPU limit                                  | `100m`                                            |
| `resources.limits.memory`          | Memory limit                               | `500Mi`                                           |
| `resources.requests.cpu`           | CPU request                                | `100m`                                            |
| `resources.requests.memory`        | Memory request                             | `200Mi`                                           |
| `tolerations`                      | Optional daemonset tolerations             | `NULL`                                            |
| `nodeSelector`                     | Node labels for fluent-bit pod assignment  | `NULL`                                            |
| `metrics.enabled`                  | Specifies whether a service for metrics should be exposed | `false`                            |
| `metrics.service.port`             | Port on where metrics should be exposed    | `2020`                                            |
| `metrics.service.type`             | Service type for metrics                   | `ClusterIP`                                       |
| | | |
