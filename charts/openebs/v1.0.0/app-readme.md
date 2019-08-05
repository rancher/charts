# OpenEBS

OpenEBS is an open source storage platform that provides persistent container attached, cloud-native block storage for DevOps and for Kubernetes environments.

OpenEBS allows you to treat your persistent workload containers, such as DBs on containers, just like other containers. OpenEBS itself is deployed as just another container on your host and enables storage services that can be designated on a per pod, application, cluster or container level, including:
- Data persistence across nodes, dramatically reducing time spent rebuilding Cassandra rings for example.
- Synchronization of data across availability zones and cloud providers.
- Use of commodity hardware plus a container engine to deliver so called container attached block storage.
- Integration with Kubernetes, so  developer and application intent flows into OpenEBS configurations automatically.
- Management of tiering to and from S3 and other targets.
