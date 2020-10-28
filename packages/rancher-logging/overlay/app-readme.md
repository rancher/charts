# Rancher Logging

Rancher Logging, powered by the [Banzai Logging Operator](https://banzaicloud.com/docs/one-eye/logging-operator/). Logging Operator, allows users to configure complex logging pipelines with a few simple resources:

- [Output](https://banzaicloud.com/docs/one-eye/logging-operator/crds/v1beta1/output_types/) configures where to store the collected logs within the namespace they are created in
- [Flow](https://banzaicloud.com/docs/one-eye/logging-operator/crds/v1beta1/flow_types/) configures what logs in the namespace are sent to the configured outputs. 
- [ClusterOutput](https://banzaicloud.com/docs/one-eye/logging-operator/crds/v1beta1/clusteroutput_types/) configures where to store logs collected for the cluster.
- [ClusterFlow](https://banzaicloud.com/docs/one-eye/logging-operator/crds/v1beta1/clusterflow_types/) configures what logs to direct to the cluster outputs.
