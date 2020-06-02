# Flux

[Flux](https://github.com/fluxcd/flux) is a tool that automatically ensures that the state of a cluster matches the config in git.
It uses an operator in the cluster to trigger deployments inside Kubernetes, which means you don't need a separate CD tool.
It monitors all relevant image repositories, detects new images, triggers deployments and updates the desired running
configuration based on that (and a configurable policy).

## Prerequisites

Kubernetes >= v1.11