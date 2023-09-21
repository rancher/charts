# s3gw

s3gw is an easy-to-use Open Source and Cloud Native S3 service running on
Rancher's Kubernetes.

* It complements the Rancher portfolio by offering an S3 service for Longhorn
  volume backups, Harvester backups, Epinio backups and OPNI models.
* It is deployed on a single pod, ideal for development, Edge, IoT and smaller
  on-prem deployments.
* It leverages the feature-rich S3 gateway from Ceph but without the rest of
  the Ceph stack.

For more information, see the [manual][1] and the [chart documentation][2].

[1]: https://s3gw-docs.readthedocs.io
[2]: https://github.com/aquarist-labs/s3gw-charts/blob/main/README.md
