# Datadog

[Datadog](https://www.datadoghq.com/) is a hosted infrastructure monitoring platform.

## Introduction

This chart adds the Datadog Agent to all nodes in your cluster via a DaemonSet. It also depends on the [kube-state-metrics chart](https://github.com/kubernetes/charts/tree/master/stable/kube-state-metrics).

Please refer to [the agent6 image documentation](https://github.com/DataDog/datadog-agent/tree/master/Dockerfiles/agent) and
[the agent6 general documentation](https://github.com/DataDog/datadog-agent/tree/master/docs) for more information.

## Prerequisites

Kubernetes 1.8+

## Deploying the Chart

1. First retrieve your DataDog API key from your [Agent Installation Instructions](https://app.datadoghq.com/account/settings#agent/kubernetes).

2. By default, this Chart creates a Secret and stores the provided API key in that Secret. Alternatively, you can point to an existing Secret containing your API key with the `datadog.apiKeyExistingSecret` value.

3. Customize the configurable parameters of the chart and deploy.

4. After a few minutes, you should see hosts and metrics being reported in your Datadog account.

## Configuration

TODO: Add table of configurable parameters

### Event Collection

The Datadog Agent can collect events from the Kubernetes API server. This can be enabled by setting the value of `apps.datadog.collectEvents` to `true`. This implicitely enables leader election among members of the Datadog DaemonSet through kubernetes to ensure only one leader agent instance is gathering events at a given time.
