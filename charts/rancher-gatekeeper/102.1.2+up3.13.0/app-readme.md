# Rancher OPA Gatekeeper

This chart is based off of the upstream [OPA Gatekeeper](https://github.com/open-policy-agent/gatekeeper/tree/master/charts/gatekeeper) chart.

For more information on how to use the feature, refer to our [docs](https://rancher.com/docs/rancher/v2.x/en/opa-gatekeper/).

The chart installs the following components:

- OPA Gatekeeper Controller-Manager - OPA Gatekeeper is a policy engine for providing policy based governance for Kubernetes clusters. The controller installs as a [validating admission controller webhook](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#validatingadmissionwebhook) on the cluster and intercepts all admission requests that create, update or delete a resource in the cluster.
- [Audit](https://github.com/open-policy-agent/gatekeeper#audit) - A periodic audit of the cluster resources against the enforced policies. Any existing resource that violates a policy will be recorded as violations.
- [Constraint Template](https://github.com/open-policy-agent/gatekeeper#constraint-templates) - A template is a CRD (`ConstraintTemplate`) that defines the schema and Rego logic of a policy to be applied to the cluster by Gatekeeper's admission controller webhook. This chart installs a few default `ConstraintTemplate` custom resources.
- [Constraint](https://github.com/open-policy-agent/gatekeeper#constraints) - A constraint is a custom resource that defines the scope of resources which a specific constraint template should apply to. The complete policy is defined by a combination of `ConstraintTemplates` (i.e. what the policy is) and `Constraints` (i.e. what resource to apply the policy to).

For more information on how to configure the Helm chart, refer to the Helm README.

## Upgrading to Kubernetes v1.25+

Starting in Kubernetes v1.25, [Pod Security Policies](https://kubernetes.io/docs/concepts/security/pod-security-policy/) have been removed from the Kubernetes API.

As a result, **before upgrading to Kubernetes v1.25** (or on a fresh install in a Kubernetes v1.25+ cluster), users are expected to perform an in-place upgrade of this chart with `global.cattle.psp.enabled` set to `false` if it has been previously set to `true`.

> **Note:**
> In this chart release, any previous field that was associated with any PSP resources have been removed in favor of a single global field: `global.cattle.psp.enabled`.

> **Note:**
> If you upgrade your cluster to Kubernetes v1.25+ before removing PSPs via a `helm upgrade` (even if you manually clean up resources), **it will leave the Helm release in a broken state within the cluster such that further Helm operations will not work (`helm uninstall`, `helm upgrade`, etc.).**
>
> If your charts get stuck in this state, please consult the Rancher docs on how to clean up your Helm release secrets.

Upon setting `global.cattle.psp.enabled` to false, the chart will remove any PSP resources deployed on its behalf from the cluster. This is the default setting for this chart.

As a replacement for PSPs, [Pod Security Admission](https://kubernetes.io/docs/concepts/security/pod-security-admission/) should be used. Please consult the Rancher docs for more details on how to configure your chart release namespaces to work with the new Pod Security Admission and apply Pod Security Standards.
