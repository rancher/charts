## How to resolve patch failures


### Problem 

- This guide will help you resolve patch failure errors like the one shown below. 

```
time="2023-12-01T13:45:56+05:30" level=info msg="Pulling k8snetworkplumbingwg/sriov-network-operator@bcab8844d807ee1db558533248273ccd492874bb/deployment/sriov-network-operator from upstream into charts"
time="2023-12-01T13:46:31+05:30" level=info msg="Loading dependencies for chart"
time="2023-12-01T13:46:31+05:30" level=info msg="Pulling https://github.com/kubernetes-sigs/node-feature-discovery/releases/download/v0.14.1/node-feature-discovery-chart-0.14.1.tgz from upstream into charts"
time="2023-12-01T13:46:33+05:30" level=info msg="Loading dependencies for chart"
time="2023-12-01T13:46:33+05:30" level=info msg="Applying changes from generated-changes"
time="2023-12-01T13:46:33+05:30" level=info msg="Updating chart metadata with dependencies"
time="2023-12-01T13:46:33+05:30" level=warning msg="Detected 'apiVersion:v2' within Chart.yaml; these types of charts require additional testing"
time="2023-12-01T13:46:33+05:30" level=info msg="Applying changes from generated-changes"
time="2023-12-01T13:46:33+05:30" level=info msg="Applying: generated-changes/patch/Chart.yaml.patch"
time="2023-12-01T13:46:33+05:30" level=error msg="\npatching file Chart.yaml\nHunk #1 FAILED at 1.\n1 out of 1 hunk FAILED -- saving rejects to file Chart.yaml.rej\n"
time="2023-12-01T13:46:33+05:30" level=fatal msg="encountered error while preparing main chart: encountered error while trying to apply changes to charts: unable to generate patch with error: exit status 1"
```

- This patch failure occured when running `make prepare` on `rancher-sriov` package. The patch file Chart.yaml.patch failed to apply here. So, how do you fix these kinds of patch failures.

### Solution

- First, we move out the patch file `Chart.yaml.patch` out of `generated-changes` folder. Here, for example, I am moving the patch file to the github repo directory.

```
charts$ mv packages/rancher-sriov/generated-changes/patch/Chart.yaml.patch ./
```

- Later, we run `make prepare` again. If any of the patch files fail, we move out in the similar manner and run `make prepare` again.


- Now, we manually apply the Chart.yaml.patch onto `./packages/rancher-sriov/charts/Chart.yaml`. After manually applying the patch file 


##### *Chart.yaml.patch*

```--- charts-original/Chart.yaml
+++ charts/Chart.yaml
@@ -1,17 +1,29 @@
+annotations:
+  catalog.cattle.io/auto-install: sriov-crd=match
+  catalog.cattle.io/certified: rancher
+  catalog.cattle.io/experimental: "true"
+  catalog.cattle.io/kube-version: '>= 1.16.0-0 < 1.28.0-0'
+  catalog.cattle.io/namespace: cattle-sriov-system
+  catalog.cattle.io/os: linux
+  catalog.cattle.io/permits-os: linux
+  catalog.cattle.io/rancher-version: '>= 2.8.0-0 < 2.9.0-0'
+  catalog.cattle.io/release-name: sriov
+  catalog.cattle.io/upstream-version: 1.2.0
 apiVersion: v2
-appVersion: 1.1.0
-dependencies:
-- condition: rancher-nfd.enabled
-  name: rancher-nfd
-  repository: file://./charts/rancher-nfd
+appVersion: 1.2.0
 description: SR-IOV network operator configures and manages SR-IOV networks in the
   kubernetes cluster
 home: https://github.com/k8snetworkplumbingwg/sriov-network-operator
+icon: https://charts.rancher.io/assets/logos/sr-iov.svg
 keywords:
 - sriov
+- Networking
 kubeVersion: '>= 1.16.0'
-name: sriov-network-operator
+maintainers:
+- email: charts@rancher.com
+  name: Rancher Labs
+name: sriov
 sources:
-- https://github.com/k8snetworkplumbingwg/sriov-network-operator
+- https://github.com/rancher/charts
 type: application
 version: 0.1.0
```

the `./packages/rancher-sriov/charts/Chart.yaml` is modified from


##### *Chart.yaml before manual patching*


```
apiVersion: v2
appVersion: 1.1.0
dependencies:
- condition: rancher-nfd.enabled
  name: rancher-nfd
  repository: file://./charts/rancher-nfd
  version: 0.14.1
description: SR-IOV network operator configures and manages SR-IOV networks in the
  kubernetes cluster
home: https://github.com/k8snetworkplumbingwg/sriov-network-operator
keywords:
- sriov
kubeVersion: '>= 1.16.0'
name: sriov-network-operator
sources:
- https://github.com/k8snetworkplumbingwg/sriov-network-operator
type: application
version: 0.1.0
```

to

##### *Chart.yaml after manual patching*

 ```
 annotations:
  catalog.cattle.io/auto-install: sriov-crd=match
  catalog.cattle.io/certified: rancher
  catalog.cattle.io/experimental: "true"
  catalog.cattle.io/kube-version: '>= 1.16.0-0 < 1.28.0-0'
  catalog.cattle.io/namespace: cattle-sriov-system
  catalog.cattle.io/os: linux
  catalog.cattle.io/permits-os: linux
  catalog.cattle.io/rancher-version: '>= 2.8.0-0 < 2.9.0-0'
  catalog.cattle.io/release-name: sriov
  catalog.cattle.io/upstream-version: 1.2.0
apiVersion: v2
appVersion: 1.2.0
description: SR-IOV network operator configures and manages SR-IOV networks in the
  kubernetes cluster
home: https://github.com/k8snetworkplumbingwg/sriov-network-operator
icon: https://charts.rancher.io/assets/logos/sr-iov.svg
keywords:
- sriov
- Networking
kubeVersion: '>= 1.16.0'
name: sriov
maintainers:
- email: charts@rancher.com
  name: Rancher Labs
sources:
- https://github.com/rancher/charts
type: application
version: 0.1.0
 ```


That's all. `maker prepare` is completed. Make sure to delete the `Chart.yaml.patch` in the repo directory

```
charts$ rm Chart.yaml.patch
```

