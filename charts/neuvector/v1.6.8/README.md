# NeuVector Helm Chart

Helm chart for NeuVector container security's core services.
 
## Preparation if using Helm 2

- Kubernetes 1.7+
- Helm installed and Tiller pod is running
- Cluster role `cluster-admin` available, check by:

```console
$ kubectl get clusterrole cluster-admin
```

If nothing returned, then add the `cluster-admin`:

cluster-admin.yaml
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-admin
rules:
- apiGroups:
  - '*'
  resources:
  - '*'
  verbs:
  - '*'
- nonResourceURLs:
  - '*'
  verbs:
  - '*'
```

```console
$ kubectl create -f cluster-admin.yaml
```

- If you have not created a service account for tiller, and give it admin abilities on the cluster:

```console
$ kubectl create serviceaccount --namespace kube-system tiller
$ kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
$ kubectl patch deployment tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}' -n kube-system
```

## CRD
Because the CRD (Custom Resource Definition) poclies can be deployed before NeuVector's core product, a new 'crd' helm chart is created. The crd template in the 'core' chart is kept for the backward compatibility. Please set 'crdwebhook.enabled' to false, if you use the new 'crd' chart.


## Configuration

The following table lists the configurable parameters of the NeuVector chart and their default values.

Parameter | Description | Default | Notes
--------- | ----------- | ------- | -----
`openshift` | If deploying in OpenShift, set this to true | `false` |
`registry` | image registry | `docker.io` | If Azure, set to my-reg.azurecr.io;<br>if OpenShift, set to docker-registry.default.svc:5000
`tag` | image tag for controller enforcer manager | `latest` |
`imagePullSecrets` | image pull secret | `nil` |
`psp` | NeuVector Pod Security Policy when psp policy is enabled | `false` |
`serviceAccount` | Service account name for NeuVector components | `default` |
`controller.enabled` | If true, create controller | `true` |
`controller.image.repository` | controller image repository | `neuvector/controller` |
`controller.replicas` | controller replicas | `3` |
`controller.disruptionbudget` | controller PodDisruptionBudget. 0 to disable. Recommended value: 2. | `0` |
`controller.priorityClassName` | controller priorityClassName. Must exist prior to helm deployment. Leave empty to disable. | `nil` |
`controller.pvc.enabled` | If true, enable persistence for controller using PVC | `false` | Require persistent volume type RWX, and storage 1Gi
`controller.pvc.storageClass` | Storage Class to be used | `default` |
`controller.azureFileShare.enabled` | If true, enable the usage of an existing or statically provisioned Azure File Share | `false` |
`controller.azureFileShare.secretName` | The name of the secret containing the Azure file share storage account name and key | `nil` |
`controller.azureFileShare.shareName` | The name of the Azure file share to use | `nil` |
`controller.apisvc.type` | Controller REST API service type | `nil` |
`controller.federation.mastersvc.type` | Multi-cluster master cluster service type. If specified, the deployment will be used to manage other clusters. Possible values include NodePort, LoadBalancer and Ingress.  | `nil` |
`controller.federation.managedsvc.type` | Multi-cluster managed cluster service type. If specified, the deployment will be managed by the master clsuter. Possible values include NodePort, LoadBalancer and Ingress. | `nil` |
`controller.ingress.enabled` | If true, create ingress for rest api, must also set ingress host value | `false` | enable this if ingress controller is installed
`controller.ingress.host` | Must set this host value if ingress is enabled | `nil` |
`controller.ingress.path` | Set ingress path |`/` | If set, it might be necessary to set a rewrite rule in annotations.
`controller.ingress.annotations` | Add annotations to ingress to influence behavior | `ingress.kubernetes.io/protocol: https ingress.kubernetes.io/rewrite-target: /` | see examples in [values.yaml](values.yaml)
`controller.configmap.enabled` | If true, configure NeuVector using a ConfigMap | `false`
`controller.configmap.data` | NeuVector configuration in YAML format | `{}`
`enforcer.enabled` | If true, create enforcer | `true` |
`enforcer.image.repository` | enforcer image repository | `neuvector/enforcer` |
`enforcer.priorityClassName` | enforcer priorityClassName. Must exist prior to helm deployment. Leave empty to disable. | `nil` |
`enforcer.tolerations` | List of node taints to tolerate | `- effect: NoSchedule`<br>`key: node-role.kubernetes.io/master` | other taints can be added after the default
`manager.enabled` | If true, create manager | `true` |
`manager.image.repository` | manager image repository | `neuvector/manager` |
`manager.priorityClassName` | manager priorityClassName. Must exist prior to helm deployment. Leave empty to disable. | `nil` |
`manager.env.ssl` | If false, manager will listen on HTTP access instead of HTTPS | `true` |
`manager.svc.type` | set manager service type for native Kubernetes | `NodePort`;<br>if it is OpenShift platform or ingress is enabled, then default is `ClusterIP` | set to LoadBalancer if using cloud providers, such as Azure, Amazon, Google
`manager.ingress.enabled` | If true, create ingress, must also set ingress host value | `false` | enable this if ingress controller is installed
`manager.ingress.host` | Must set this host value if ingress is enabled | `nil` |
`manager.ingress.path` | Set ingress path |`/` | If set, it might be necessary to set a rewrite rule in annotations. Currently only supports `/`
`manager.ingress.annotations` | Add annotations to ingress to influence behavior | `{}` | see examples in [values.yaml](values.yaml)
`manager.ingress.tls` | If true, TLS is enabled for manager ingress service |`false` | If set, the tls-host used is the one set with `manager.ingress.host`.
`manager.ingress.secretName` | Name of the secret to be used for TLS-encryption | `nil` | Secret must be created separately (Let's encrypt, manually)
`cve.updater.enabled` | If true, create cve updater | `true` |
`cve.updater.image.repository` | cve updater image repository | `neuvector/updater` |
`cve.updater.image.tag` | image tag for cve updater | `latest` |
`cve.updater.priorityClassName` | cve updater priorityClassName. Must exist prior to helm deployment. Leave empty to disable. | `nil` |
`cve.updater.schedule` | cronjob cve updater schedule | `0 0 * * *` |
`cve.scanner.enabled` | If true, external scanners will be deployed | `true` |
`cve.scanner.image.repository` | external scanner image repository | `neuvector/scanner` |
`cve.scanner.priorityClassName` | cve scanner priorityClassName. Must exist prior to helm deployment. Leave empty to disable. | `nil` |
`cve.scanner.replicas` | external scanner replicas | `3` |
`cve.scanner.dockerPath` | the remote docker socket if CI/CD integration need scan images before they are pushed to the registry | `nil` |
`docker.path` | docker path | `/var/run/docker.sock` |
`containerd.enabled` | Set to true, if the container runtime is containerd | `false` |
`containerd.path` | If containerd is enabled, this local containerd socket path will be used | `/var/run/containerd/containerd.sock` |
`crio.enabled` | Set to true, if the container runtime is cri-o | `false` |
`crio.path` | If cri-o is enabled, this local cri-o socket path will be used | `/var/run/crio/crio.sock` |
`admissionwebhook.type` | admission webhook type | `ClusterIP` |
`crdwebhook.enabled` | Enable crd service and create crd related resources | `true` |
`crdwebhook.type` | crd webhook type | `ClusterIP` |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```console
$ helm install --name my-release --namespace neuvector ./neuvector-helm/ --set manager.env.ssl=off
```

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart. For example,

```console
$ helm install --name my-release --namespace neuvector ./neuvector-helm/ -f values.yaml
```

---
Contact <support@neuvector.com> for access to Docker Hub and docs.

