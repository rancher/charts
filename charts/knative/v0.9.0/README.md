# Chart for Knative

This is a fork from the [Triggermesh Knative Helm chart](https://github.com/triggermesh/charts).

It installs the released manifest for knative, including Istio as [documented](https://github.com/knative/docs/blob/master/install/Knative-with-any-k8s.md)

Note that because of Istio [RBAC](https://istio.io/docs/setup/kubernetes/helm-install/#installation-steps)
you need Helm 2.10 or later.

## About this Chart

### Istio

This chart installs istio in a "lean" configuration which means it lacks the sidecar injection. This chart is generated from the [recommendation in the knative docs](https://knative.dev/docs/install/installing-istio/#installing-istio-without-sidecar-injection).

### Knative

The Knative chart is based on the the kubernetes yaml [provided in the documentation](https://knative.dev/docs/install/knative-with-any-k8s/). It only provides the knative-serving functionality and not eventing. It is configured to download the yaml and templatize it in the cloudbuild step.

## Setup the Chart repo

```
helm repo add gitlab https://charts.gitlab.io/
```

or if you would like to use the latest chart from master:

```
git clone https://gitlab.com/gitlab-org/charts/knative.git
helm install knative
```

And update your chart repos:

```
helm repo update
```

## Search for knative and install

```
helm search knative
helm install --debug --dry-run gitlab/knative
```

If you are sure you want to do the install:

```
helm install gitlab/knative
```

## Support

We would love your feedback on this chart so don't hesitate to let us know what is wrong and how we could improve it, just file an [issue](https://gitlab.com/gitlab-org/charts/knative/issues/new)

## Upgrading Knative Version

Historically, this chart was compiled using a script and downloaded the knative-serving portion from https://github.com/knative/serving/releases/download/{version}/serving-post-1.14.yaml.

You can still do that!

1. Download the new version of the knative-serving yaml
2. Replace instances of `config-domain` with `config-domain-example` (Yes, this results in resources named `config-domain-example-example`. No, we shouldn't change it at this point.)
3. Replace instances of `{{` with `{{ "{{" }}`. Helm doesn't like the `{{`, but it shows up in the template.
4. Remove instances of namespace creation so they happen as a part of the knative pre-install
5. Remove any duplicate components (I guess this happens sometimes?)
6. Add the following to custom resource definitions:
  ```
  metadata:
    annotations:
      "helm.sh/hook": "crd-install"
  ```
7. Insert the new knative-serving yaml into knative.yaml leaving the two Namespace creations at the top and the last ConfigMap creation at the bottom. (There are comments to make sure you see the right spot.)

## [Code of Conduct](https://about.gitlab.com/community/contribute/code-of-conduct/)
