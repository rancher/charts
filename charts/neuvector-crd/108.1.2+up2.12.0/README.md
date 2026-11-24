# NeuVector Helm Chart

Helm chart for NeuVector container security's CRD services. NeuVector's CRD (Custom Resource Definition) capture and declare application security policies early in the pipeline, then defined policies can be deployed together with the container applications.

Because the CRD policies can be deployed before NeuVector's core product, this separate helm chart is created. For the backward compatibility reason, crd.yaml is not removed in the 'core' chart. If you use this 'crd' chart, please set `crdwebhook.enabled` to false in the 'core' chart.
 
## Configuration

The following table lists the configurable parameters of the NeuVector chart and their default values.

Parameter | Description | Default | Notes
--------- | ----------- | ------- | -----
`openshift` | If deploying in OpenShift, set this to true | `false` |
`crdwebhook.type` | crd webhook type | `ClusterIP` |
