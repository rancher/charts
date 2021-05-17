# Rancher Logging

This chart is based off of the upstream [Banzai Logging Operator](https://banzaicloud.com/docs/one-eye/logging-operator/) chart. The chart deploys a logging operator and CRDs, which allows users to configure complex logging pipelines with a few simple custom resources. There are two levels of logging, which allow you to collect all logs in a cluster or from a single namespace.

For more information on how to use the feature, refer to our [docs](https://rancher.com/docs/rancher/v2.x/en/logging/v2.5/).

## Namespace-level logging

To collect logs from a single namespace, users create flows and these flows are connected to outputs or cluster outputs.

## Cluster-level logging

To collect logs from an entire cluster, users create cluster flows and cluster outputs.

## CRDs
- [Cluster Flow](https://banzaicloud.com/docs/one-eye/logging-operator/crds/v1beta1/clusterflow_types/) - A cluster flow is a CRD (`ClusterFlow`) that defines what logs to collect from the entire cluster. The cluster flow must be deployed in the same namespace as the logging operator.
- [Cluster Output](https://banzaicloud.com/docs/one-eye/logging-operator/crds/v1beta1/clusteroutput_types/) - A cluster output is a CRD (`ClusterOutput`) that defines how to connect to logging providers so they can start collecting logs. The cluster output must be deployed in the same namespace as the logging operator. The convenience of using a cluster output is that either a cluster flow or flow can send logs to those providers without needing to define specific outputs in each namespace for each flow.
- [Flow](https://banzaicloud.com/docs/one-eye/logging-operator/crds/v1beta1/flow_types/) - A flow is a CRD (`Flow`) that defines what logs to collect from the namespace that it is deployed in.
- [Output](https://banzaicloud.com/docs/one-eye/logging-operator/crds/v1beta1/output_types/) - An output is a CRD (`Output`) that defines how to connect to logging providers so logs can be sent to the provider.

For more information on how to configure the Helm chart, refer to the Helm README.
