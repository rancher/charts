# Rancher OPA Gatekeeper

This chart is based off of the upstream [OPA Gatekeeper](https://github.com/open-policy-agent/gatekeeper/tree/master/charts/gatekeeper) chart.

For more information on how to use the feature, refer to our [docs](https://rancher.com/docs/rancher/v2.x/en/opa-gatekeper/).

The chart installs the following components:

- OPA Gatekeeper Controller-Manager - OPA Gatekeeper is a policy engine for providing policy based governance for Kubernetes clusters. The controller installs as a [validating admission controller webhook](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#validatingadmissionwebhook) on the cluster and intercepts all admission requests that create, update or delete a resource in the cluster.
- [Audit](https://github.com/open-policy-agent/gatekeeper#audit) - A periodic audit of the cluster resources against the enforced policies. Any existing resource that violates a policy will be recorded as violations.
- [Constraint Template](https://github.com/open-policy-agent/gatekeeper#constraint-templates) - A template is a CRD (`ConstraintTemplate`) that defines the schema and Rego logic of a policy to be applied to the cluster by Gatekeeper's admission controller webhook. This chart installs a few default `ConstraintTemplate` custom resources.
- [Constraint](https://github.com/open-policy-agent/gatekeeper#constraints) - A constraint is a custom resource that defines the scope of resources which a specific constraint template should apply to. The complete policy is defined by a combination of `ConstraintTemplates` (i.e. what the policy is) and `Constraints` (i.e. what resource to apply the policy to).

For more information on how to configure the Helm chart, refer to the Helm README.
