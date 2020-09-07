# Bluehub: Enterprise Messaging Platform

Blue Spire’s expertise helps you to more quickly and with less risk, achieve a well-architected Kafka-as-a-Service (KaaS) platform that spans the cloud, and the Edge

### APACHE KAFKA ECOSYSTEM / COMPONENTS

![Image of Apache Kafka](https://img1.wsimg.com/isteam/ip/7e52756c-d3af-4a2f-88f5-4ecd75659529/bluespire_kafka_app_data_flow.png/:/rs=h:650,cg:true,m)

Apache Kafka ecosystem

    * Kafka Core
    * Broker
    * Clients library (producer, consumer, admin)
    * Kafka Connect
    * Kafka Streams
    * Mirror Maker

Apache Kafka components

    * Kafka Broker
    * Central component responsible for hosting topics and delivering messages
    * One or more brokers run in a cluster alongside with a Zookeeper ensemble
    * Kafka Producers and Consumers
    * Java-based clients for sending and receiving messages
    * Kafka Admin tools
    * Java- and Scala- based tools for managing Kafka brokers
    * Managing topics, ACLs, monitoring etc.

## Enterprise Messaging Hub - with Advanced Kafka Framework
![Image of Apache Kafka](https://img1.wsimg.com/isteam/ip/7e52756c-d3af-4a2f-88f5-4ecd75659529/Product.jpg/:/rs=w:400,cg:true,m)

### Introduction
This chart bootstraps a suite of messaging components deployment on a Kubernetes cluster using Helm package manager.

Bluespire charts can be used with any Kubernetes distros.

### Prerequisites
* Kubernetes 1.12+
* Helm 2.21+ or Helm 3.0
* Provisioner support for underlying infrastructure (on-prem and cloud)

### Installing the Chart
helm repo add bluespireinc https://github.com/bluespireinc/charts
helm install release-name bluespireinc/bluehub

See Parameters section below that can be configured during the installation

### Uninstalling the Chart
helm delete release-name

### Docker Hub
* https://hub.docker.com/repository/docker/bluespireinc/kproducer
* https://hub.docker.com/repository/docker/bluespireinc/clustermgr
* https://hub.docker.com/repository/docker/bluespireinc/securitymgr
* https://hub.docker.com/repository/docker/bluespireinc/kafka
* https://hub.docker.com/repository/docker/bluespireinc/zookeeper

The command will remove all kubernetes components associated with the chart with an exception of few workloads which has configured with helm.io/hooks

## Parameters
You can use the default values.yaml from the list of files for reference

### Zookeeper

Parameter | Description | Default
--------- | ----------- | -------
zookeeper.enabled | If true, installs the zookeeper | false
zookeeper.imgName | Zookeeper container image to deploy | bluespireinc/zookeeper
zookeeper.imgVersion | Zookeeper container version to deploy | 3.5.8
zookeeper.type | Deployment Service type ClusterIP, NodePort or LoadBalancer | ClusterIP
zookeeper.port | Port number where Zookeeper service is listening | 2181
zookeeper.replicas | Number of zookeeper instances to deploy | 5
zookeeper.heapOpts | Heap allocation to Zookeeper process | -Xms1024M -Xmx1024M
zookeeper.tickTime | | 2000
zookeeper.syncLimit | | 5
zookeeper.initLlimit | | 10
zookeeper.maxClientConnections | Allowed number of client connections to Zookeeper | 60
zookeeper.podManagementPolicy | Deploy the PODs in either Parallel or OrderedReady | OrderedReady
zookeeper.resources.requests.cpu | Guaranteed cpu allocated for the POD | 2000m
zookeeper.resources.requests.memory | Guaranteed memory allocated for the POD | 1Gi
zookeeper.resources.limits.cpu | Extended cpu allocated for the POD | 4000m
zookeeper.resources.limits.memory | Extended memory allocated for the POD | 2Gi
zookeeper.storage.class | Storage class name |
zookeeper.storage.capacity | Storage capacity name | 10Gi
zookeeper.metrics.port | JMX port where metrics are exposed | 9141
zookeeper.metrics.service | zookeeper port running the service | 2181

### Kafka

Parameter | Description | Default
--------- | ----------- | -------
kafka.enabled | If true, installs the Kafka brokers | false
kafka.replicas | Number of Kafka instances to deploy | 5
kafka.imgName | Kafka container image to deploy | bluespireinc/kafka
kafka.imgVersion | Kafka container version to deploy | 2.5.0
kafka.type | Deployment Service type ClusterIP, NodePort or LoadBalancer | ClusterIP
kafka.heapOpts | Heap allocation to Kafka process | -Xms6144M -Xmx6144M
kafka.securePort | Secured port with SASL_SSL and SSL enabled | 9093
kafka.nonSecurePort | Port for PLAINTEXT enabled | 9092
kafka.externalIP | One of the kubernetes node IP address |
kafka.externalPort | Port exposed to all Kubernetes instances |
kafka.internalPort | Port internal accessible | 19092
kafka.logRetentionHours | Log retention policy | 168
kafka.podManagementPolicy | Deploy the PODs in either Parallel or OrderedReady | OrderedReady
kafka.sslEnabledProtocols | TLS protocols allowed | TLSv1.2
kafka.topicReplicationFactor | Number of copies of data | 3
kafka.topicDeleteEnabled | Topic deletion | true
kafka.autoTopicCreateEnabled | Topic automatically created if not present | false
kafka.numNetworkThreads | Number of threads for parallel processing | 8
kafka.compressionType | Algorithm used for compression | snappy
kafka.zookeeper.port | Port number where Zookeeper service is listening | 2181
kafka.resources.requests.cpu | Guaranteed cpu allocated for the POD | 2000m
kafka.resources.requests.memory | Guranteed memory allocated for the POD | 16Gi
kafka.resources.limits.cpu | Guaranteed cpu allocated for the POD | 8000m
kafka.resources.limits.memory | Guaranteed memory allocated for the POD | 32Gi
kafka.storage.class | Storage class name |
kafka.storage.capacity | Storage capacity name | 500Gi
kafka.metrics.port | JMX port where metrics are made available | 9308

### Schema Registry
Parameter | Description | Default
--------- | ----------- | -------
schemareg.enabled | If true, installs the Schema Registry | false
schemareg.replicas | Number of Schema Registry instances to deploy | 2
schemareg.imgName | Schema Registry container image to deploy | bluespireinc/schemareg
schemareg.imgVersion | Schema Registry container version to deploy | 5.5.1
schemareg.port | Port number where Schema Registry service is listening | 8081
schemareg.type | Deployment Service type ClusterIP, NodePort or LoadBalancer | ClusterIP
schemareg.heapOpts | Heap allocation to Kafka process | -Xms1024M -Xmx1024M
schemareg.sslEnabledProtocols | TLS protocols allowed | TLSv1.2
schemareg.topic | topic name for holding the schemas | schemas
schemareg.topicReplicationFactor | copies of schemas replicated in topic | 3
schemareg.kafka.port | Secured Kafka Broker Port | 9093
schemareg.resources.requests.cpu | Guaranteed cpu allocated for the POD | 1000m
schemareg.resources.requests.memory | Guranteed memory allocated for the POD | 1Gi
schemareg.resources.limits.cpu | Guaranteed cpu allocated for the POD | 2000m
schemareg.resources.limits.memory | Guranteed memory allocated for the POD | 2Gi

### Cluster Manager
Parameter | Description | Default
--------- | ----------- | -------
clustermgr.enabled | If true, installs the Cluster Manager | false
clustermgr.replicas | Number of Cluster Manager instances to deploy | 1
clustermgr.imgName | Cluster Manager container image to deploy | bluespireinc/clustermgr
clustermgr.imgVersion | Cluster Manager container version to deploy | 1.0.0
clustermgr.port | Port number where Cluster Manager service is listening | 9000
clustermgr.zookeeper.port | Port number where Zookeeper service is listening | 2181
clustermgr.type | Deployment Service type ClusterIP, NodePort or LoadBalancer | ClusterIP
clustermgr.resources.requests.cpu | Guaranteed cpu allocated for the POD | 100m
clustermgr.resources.requests.memory | Guranteed memory allocated for the POD | 128Mi
clustermgr.resources.limits.cpu | Guaranteed cpu allocated for the POD | 200m
clustermgr.resources.limits.memory | Guranteed memory allocated for the POD | 256Mi

### Security Manager
Parameter | Description | Default
--------- | ----------- | -------
securitymgr.enabled | If true, installs the Security Manager | false
securitymgr.replicas | Number of Security Manager instances to deploy | 1
securitymgr.imgName | Security Manager container image to deploy | bluespireinc/securitymgr
securitymgr.imgVersion | Security Manager container version to deploy | 1.0.0
securitymgr.refreshRateInMS | Auto refresh of ACLs policies | 10000
securitymgr.resources.requests.cpu | Guaranteed cpu allocated for the POD | 250m
securitymgr.resources.requests.memory | Guranteed memory allocated for the POD | 128Mi
securitymgr.resources.limits.cpu | Guaranteed cpu allocated for the POD | 350m
securitymgr.resources.limits.memory | Guranteed memory allocated for the POD | 256Mi

### Kproducer
Parameter | Description | Default
--------- | ----------- | -------
kproducer.enabled | If true, installs the kproducer | false
kproducer.replicas | Number of kproducer instances to deploy | 10
kproducer.imgName | kproducer container image to deploy | bluespireinc/kproducer
kproducer.imgVersion | kproducer container version to deploy | 1.0.0
kproducer.port | Port on which kproducer service runs | 3443
kproducer.type | Deployment Service type ClusterIP, NodePort or LoadBalancer | ClusterIP
kproducer.maxBodySize | Maximum allowed Payload size in bytes producer can take as input | 50000
kproducer.resources.requests.cpu | Guaranteed cpu allocated for the POD | 1000m
kproducer.resources.requests.memory | Guranteed memory allocated for the POD | 16Gi
kproducer.resources.limits.cpu | Guaranteed cpu allocated for the POD | 2000m
kproducer.resources.limits.memory | Guranteed memory allocated for the POD | 32Gi

## Secrets
Below are the secrets which are needed for the above messaging components to work efficiently

### bluehub-zookeeper-secrets
* zk_jaas.conf | File Path with JAAS configuration

### bluehub-kafka-secrets
* kfk_jaas.conf | File Path with JAAS configuration
* kafka.key.creds | JKS key credentials file
* kafka.keystore.creds | JKS keystore credentials file
* kafka.truststore.creds | JKS truststore credentials file
* kafka.keystore.jks | Server JKS keystore file
* kafka.truststore.jks | Server JKS trust file
* kafka.client.keystore.jks | Client JKS keystore file
* kafka.client.truststore.jks | Client JKS trust file

### bluehub-exporter-secrets
* sasl_username | SASL username
* sasl_password | SASL password

### bluehub-schemareg-secrets
* kafka.keystore.jks | Server JKS keystore file
* kafka.truststore.jks | Server JKS trust file
* schemareg_key_password | JKS key credentials file
* schemareg_keystore_password | JKS keystore credentials file
* schemareg_truststore_password | JKS truststore credentials file
* schemareg_sasl_username | SASL username
* schemareg_sasl_password | SASL password

### bluehub-clustermgr-secrets
* clustermgr_username | SASL username
* clustermgr_password | SASL password

### bluehub-securitymgr-secrets
* securitymgr_truststore_password | JKS truststore credentials
* securitymgr_sasl_username | SASL username
* securitymgr_sasl_password | SASL password
* securitymgr_keystore_password | JKS keystore credentials
* kafka.keystore.jks | JKS keystore file
* kafka.truststore.jks | JKS truststore file
* acls.csv | Kafka authorization policies

### bluehub-kproducer-secrets
* client-ca.pem | client cert

### bluehub-kproducer-producers-secrets
json | list of files with different producer configuration

### bluehub-kproducer-schemas-secrets
avsc | list of schemas for producers in avro format
