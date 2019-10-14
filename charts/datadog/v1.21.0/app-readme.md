# Datadog

[Datadog](https://www.datadoghq.com/) is a hosted infrastructure monitoring platform.

## Introduction

This chart adds the Datadog Agent to all nodes in your cluster via a DaemonSet. It also optionally depends on the [kube-state-metrics chart](https://github.com/kubernetes/charts/tree/master/stable/kube-state-metrics). For more information about monitoring Kubernetes with Datadog, please refer to the [Datadog documentation website](https://docs.datadoghq.com/agent/basic_agent_usage/kubernetes/).

For more details of the datadog-agent v6 environment configurations, please reference the [docs](https://github.com/DataDog/datadog-agent/tree/master/Dockerfiles/agent) here.
