# NeuVector

Visibility and Security: The NeuVector ‘Multi-Vector Container Security Platform’

[NeuVector](https://neuvector.com) provides a real-time Kubernetes and OpenShift container security solution that adapts easily to your changing environment and secures containers at their most vulnerable point – during run-time. The declarative security policy ensures that applications scale up or scale down quickly without manual intervention. The NeuVector solution is a Red Hat and Docker Certified container itself which deploys easily on each host, providing a container firewall, host monitoring and security, security auditing with CIS benchmarks, and vulnerability scanning.

The installation will deploy the NeuVector Enforcer container on each worker node as a daemon set, and by default 3 controller containers (for HA, one is elected the leader). The controllers can be deployed on any node, including Master, Infra or management nodes. See the NeuVector docs for node labeling to control where controllers are deployed.

## Prerequisites

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

## Downloading the Chart

Clone or download this repository.

## Installing the Chart

#### Kubernetes

- Create the NeuVector namespace.

```console
$ kubectl create namespace neuvector
```

- Configure Kubernetes to pull from the private NeuVector registry on Docker Hub.

```console
$ kubectl create secret docker-registry regsecret -n neuvector --docker-server=https://index.docker.io/v1/ --docker-username=your-name --docker-password=your-pword --docker-email=your-email
```

Where ’your-name’ is your Docker username, ’your-pword’ is your Docker password, ’your-email’ is your Docker email.

To install the chart with the release name `my-release` and image pull secret:

```console
$ helm install my-release --namespace neuvector ./neuvector-helm/ --set imagePullSecrets=regsecret
```

> If you already installed neuvector in your cluster without using helm, please `kubectl delete -f your-neuvector-yaml.yaml` before trying to use helm install.

#### RedHat OpenShift

- Create a new project. Note: If the --node-selector argument is used when creating a project this will restrict pod placement such as for the Neuvector enforcer to specific nodes.

```console
$ oc new-project neuvector
```

- Grant Service Account Access to the Privileged SCC.

```console
$ oc -n neuvector adm policy add-scc-to-user privileged -z default
```

To install the chart with the release name `my-release` and your private registry:

```console
$ helm install my-release --namespace neuvector ./neuvector-helm/ --set openshift=true,registry=your-private-registry
```

If you are using a private registry, and want to enable the updater cronjob, please create a script, run it as a cronjob before midnight or the updater daily schedule.

```console
$ docker login docker.io
$ docker pull docker.io/neuvector/updater
$ docker logout docker.io

$ oc login -u <user_name>
# this user_name is the one when you install neuvector

$ docker login -u <user_name> -p `oc whoami -t` docker-registry.default.svc:5000
$ docker tag docker.io/neuvector/updater docker-registry.default.svc:5000/neuvector/updater
$ docker push docker-registry.default.svc:5000/neuvector/updater
$ docker logout docker-registry.default.svc:5000
```

## Rolling upgrade

Please `git pull` the latest neuvector-helm/ before upgrade.

```console
$ helm upgrade my-release --set imagePullSecrets=regsecret,tag=2.2.0 ./neuvector-helm/
```

Please keep all of the previous settings you do not want to change during rolling upgrade.

```console
$ helm upgrade my-release --set openshift=true,registry=your-private-registry,cve.updater.enabled=true ./neuvector-helm/
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the NeuVector chart and their default values.

Parameter | Description | Default | Notes
--------- | ----------- | ------- | -----
`openshift` | If deploying in OpenShift, set this to true | `false` |
`registry` | image registry | `docker.io` | If Azure, set to my-reg.azurecr.io;<br>if OpenShift, set to docker-registry.default.svc:5000
`tag` | image tag for controller enforcer manager | `latest` |
`imagePullSecrets` | image pull secret | `nil` |
`psp` | NeuVector Pod Security Policy when psp policy is enabled | `false` |
`controller.enabled` | If true, create controller | `true` |
`controller.image.repository` | controller image repository | `neuvector/controller` |
`controller.replicas` | controller replicas | `3` |
`controller.disruptionbudget` | controller PodDisruptionBudget. 0 to disable. Recommended value: 2. | `0` |
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
`enforcer.tolerations` | List of node taints to tolerate | `- effect: NoSchedule`<br>`key: node-role.kubernetes.io/master` | other taints can be added after the default
`manager.enabled` | If true, create manager | `true` |
`manager.image.repository` | manager image repository | `neuvector/manager` |
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
`cve.updater.schedule` | cronjob cve updater schedule | `0 0 * * *` |
`cve.scanner.enabled` | If true, external scanners will be deployed | `true` |
`cve.scanner.image.repository` | external scanner image repository | `neuvector/scanner` |
`cve.scanner.replicas` | external scanner replicas | `3` |
`cve.scanner.dockerPath` | the remote docker socket if CI/CD integration need scan images before they are pushed to the registry | `nil` |
`docker.path` | docker path | `/var/run/docker.sock` |
`containerd.enabled` | Set to true, if the container runtime is containerd | `false` |
`containerd.path` | If containerd is enabled, this local containerd socket path will be used | `/var/run/containerd/containerd.sock` |
`crio.enabled` | Set to true, if the container runtime is cri-o | `false` |
`crio.path` | If cri-o is enabled, this local cri-o socket path will be used | `/var/run/crio/crio.sock` |
`admissionwebhook.type` | admission webhook type | `ClusterIP` |
`crdwebhook.type` | crd webhook type | `ClusterIP` |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```console
$ helm install my-release --namespace neuvector ./neuvector-helm/ --set manager.env.ssl=off
```

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart. For example,

```console
$ helm install my-release --namespace neuvector ./neuvector-helm/ -f values.yaml
```

> **Tip**: You can use the default [values.yaml](values.yaml)

## RBAC Configuration

If you installed neuvector before and manually created the cluster role and cluster role binding for neuvector-binding, you need to delete the cluster role binding first, then delete the cluster role.

```console
$ kubectl delete clusterrolebinding neuvector-binding
$ kubectl delete clusterrole neuvector-binding
```

If helm install returns error because of an existing cluster role, you need to delete the release before install again.

```console
$ helm delete --purge my-release
```

## Enabling/Disabling Ingress

Enabling/Disabling ingress  by changing `manager.ingress.enabled` from `true` to `false` and vice versa - and simply updating your chart will fail, because `manager.svc.type` will be changed between 'NodePort' (default) and 'ClusterIp' - this isn't possible. The working way is:

- Disable 'manager' (`manager.enabled=false`)
- Update chart
- Enable/Disable ingress and re-enable manager
- Update chart

---
Contact <support@neuvector.com> for access to Docker Hub and docs.

