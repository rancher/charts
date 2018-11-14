## Prerequisites

1. Kubernetes v1.10+
2. `qemu-kvm` installed on all Kubernetes nodes

## Uninstall

Run the following `kubectl` commands first:
```
NS=ranchervm-system
kubectl -n ${NS} delete deployment.apps/backend
kubectl -n ${NS} delete deployment.apps/frontend
kubectl -n ${NS} delete deployment.apps/ip-controller
kubectl -n ${NS} delete deployment.apps/vm-controller
kubectl -n ${NS} get arptables.vm.rancher.io -o yaml | sed "s/\- deletion.vm.rancher.io//g" | kubectl apply -f -
kubectl -n ${NS} get credentials.vm.rancher.io -o yaml | sed "s/\- deletion.vm.rancher.io//g" | kubectl apply -f -
kubectl -n ${NS} get virtualmachines.vm.rancher.io -o yaml | sed "s/\- deletion.vm.rancher.io//g" | kubectl apply -f -
kubectl -n ${NS} delete arptables.vm.rancher.io --all
kubectl -n ${NS} delete credentials.vm.rancher.io --all
kubectl -n ${NS} delete virtualmachines.vm.rancher.io --all
```

Delete the `ranchervm` deployment from `Catalog Apps` screen.

## Source Code

RancherVM is 100% open source software. Project source code is available in these repositories:

1. [K8s Controllers and REST API](https://github.com/rancher/vm)
2. [Dashboard](https://github.com/llparse/longhorn-ui)
3. [Rancher 2.0 Chart](https://github.com/LLParse/charts-rancher/tree/ranchervm-v0.1.0/proposed/ranchervm/latest)

---
Please see [link](https://github.com/rancher/vm) for more information.
