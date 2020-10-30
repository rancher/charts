# Changelog

## v1.1.2

* Improvement: Seamless support for Instana static agent images: When using an `agent.image.name` starting with `containers.instana.io`, automatically create a secret called `containers-instana-io` containing the `.dockerconfigjson` for `containers.instana.io`, using `_` as username and `agent.downloadKey` or, if missing, `agent.key` as password. If you want to control the creation of the image pull secret, or disable it, you can use `agent.image.pullSecrets`, passing to it the YAML to use for the `imagePullSecrets` field of the Daemonset spec, including an empty array `[]` to mount no pull secrets, no matter what.

## v1.1.1

* Fix: Automatically recreate agent pods if there is a change in the ConfigMap created by this Helm chart.
