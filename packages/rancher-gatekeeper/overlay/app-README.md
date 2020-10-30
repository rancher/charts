# Rancher OPA Gatekeeper

This chart is based off of the upstream [OPA Gatekeeper](https://open-policy-agent.github.io/gatekeeper/charts/gatekeeper-3.1.1.tgz) chart. It supports the following functionality to enable OPA Gatekeeper within your cluster:

## Workloads
* `OPA Gatekeeper Controller-Manager` - OPA Gatekeeper is a Policy-Engine for providing policy based governance for Kubernetes clusters. The Controller installs as a [Validating Admission Controller Webhook](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#validatingadmissionwebhook) of your cluster and intercepts all admission requests that create, update or delete a resource in the cluster. Gatekeeper Controller also performs a periodic audit of your cluster resources against the enforced policies. Any existing resource that violates a policy will be recorded under Violations on the Rancher Gatekeeper App's homepage.

## CRDs & CRs
* `ConstraintTemplates` - A `ConstraintTemplate`  is a CRD. The Constraint templates(aka Templates) are Kubernetes custom resources that define the schema and Rego logic of an OPA policy to be applied to your cluster by Gatekeeper's admission control webhook. This Rancher chart will install few `ConstraintTemplates` custom resources which can be used to create some constraints.
* `Constraints` - A `Constraint` is also a CRD that defines the scope of objects to which a specific `ConstraintTemplate` should apply to. The complete policy is defined by a `ConstraintTemplate` and the `Constraint` together. Using a `Constraint` user can specify namespaces/Kinds/apiGroups of resources to include/exclude from the policy.
