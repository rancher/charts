# Dynatrace OneAgent Operator

This is the home of the Dynatrace OneAgent Operator's Helm Chart which supports the rollout and lifecycle of [Dynatrace OneAgent](https://www.dynatrace.com/support/help/get-started/introduction/what-is-oneagent/) in Kubernetes and OpenShift clusters.
Rolling out Dynatrace OneAgent via DaemonSet on a cluster is straightforward.
Maintaining its lifecycle places a burden on the operational team.
Dynatrace OneAgent Operator closes this gap by automating the repetitive steps involved in keeping Dynatrace OneAgent at its latest desired version.

## Important Notice

Since this app is based on Helm 3 the CustomResourceDefinition needs to be applied by hand in-before.
Run this command to apply the CRD to your cluster:
```
kubectl apply -f https://raw.githubusercontent.com/Dynatrace/helm-charts/master/dynatrace-oneagent-operator/crds/customresourcedefinition.yaml
```