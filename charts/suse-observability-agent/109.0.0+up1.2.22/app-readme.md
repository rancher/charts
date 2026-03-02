The data collection agent for [SUSE Observability](https://docs.stackstate.com/get-started/k8s-quick-start-guide)

## Introduction

This chart installs an agent that does cluster-wide collection of metrics, topology, logs and traces and forwards that data to a SUSE Observability instance.

## Installation

Installation of the agent requires an installed version of [SUSE Observability](https://docs.stackstate.com/get-started/k8s-quick-start-guide) which is accessible from the cluster.

To install proceed as follows:

1. Open a second browser tab and navigate to the target instance of SUSE Observability
2. In the SUSE Observability UI, open the main menu by clicking in the top left of the screen and go to `StackPacks` > `Integrations` > `Kubernetes`.
3. Install a new instance of the Kubernetes StackPack:
   * Specify a Kubernetes Cluster Name
        * This name will be used to identify the cluster in SUSE Observability
   * Click install.
4. Once installed, the state of the instance turns to `Waiting for data`. Click the installed instance to see instructions appear for how to install the agent. This will also show a section `Instance credentials` that is required to proceed in the Rancher UI.
5. Click install on this page, select a namespace to install the SUSE Observability agent into and fill in the data from the `Instance credentials` section into the chart values.
