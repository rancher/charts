
# Automated installer

Scripted in-cluster install of Knative.
Our primary goal is repeatability rather than configurability.

## Running

The install script passes on [helm](https://docs.helm.sh/helm/#helm-install) flags such as `--set` and `-f`.
It must run in the `kube-system` namespace or have appropriate RBAC.

For example using the [development](#development) build:

```
kubectl -n kube-system run -i -t knative-installer --image=knative.registry.svc.cluster.local/triggermesh/knative-installer --image-pull-policy=Never --restart=Never --rm -- --set 'domain=minikube,istioIngressType=NodePort'
```

Or as a Job:

```
cat <<EOF | kubectl -n kube-system apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: knative-installer
spec:
  template:
    spec:
      containers:
      - name: installer
        image: gcr.io/triggermesh/knative-installer
        args:
        - --set
        - domain=example.com,istioIngressType=NodePort
      restartPolicy: Never
  backoffLimit: 0
EOF
```

## Development

With Minikube running:

```
eval $(minikube docker-env)
rm -rf ./w; cloud-build-local --write-workspace=./w --dryrun=false .
docker build -t knative.registry.svc.cluster.local/triggermesh/knative-installer --file ./installer/Dockerfile ./w
kubectl -n kube-system run -i -t knative-installer-dev --image=knative.registry.svc.cluster.local/triggermesh/knative-installer --image-pull-policy=Never --restart=Never --rm --command -- bash
```

The registry name is from https://github.com/triggermesh/knative-local-registry.
