# Prometheus Federator

This chart is deploys a Helm Project Operator (based on the [rancher/helm-project-operator](https://github.com/rancher/helm-project-operator)), an operator that manages deploying Helm charts each containing a Project Monitoring Stack, where each stack contains:
- [Prometheus](https://prometheus.io/) (managed externally by [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator))
- [Alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/) (managed externally by [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator))
- [Grafana](https://github.com/helm/charts/tree/master/stable/grafana) (deployed via an embedded Helm chart)
- Default PrometheusRules and Grafana dashboards based on the collection of community-curated resources from [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus/)
- Default ServiceMonitors that watch the deployed resources

> **Important Note: Prometheus Federator is designed to be deployed alongside an existing Prometheus Operator deployment in a cluster that has already installed the Prometheus Operator CRDs.**

By default, the chart is configured and intended to be deployed alongside [rancher-monitoring](https://rancher.com/docs/rancher/v2.6/en/monitoring-alerting/), which deploys Prometheus Operator alongside a Cluster Prometheus that each Project Monitoring Stack is configured to federate namespace-scoped metrics from by default.
 
## Pre-Installation: Using Prometheus Federator with Rancher and rancher-monitoring

If you are running your cluster on [Rancher](https://rancher.com/) and already have [rancher-monitoring](https://rancher.com/docs/rancher/v2.6/en/monitoring-alerting/) deployed onto your cluster, Prometheus Federator's default configuration should already be configured to work with your existing Cluster Monitoring Stack; however, here are some notes on how we recommend you configure rancher-monitoring to optimize the security and usability of Prometheus Federator in your cluster:

### Ensure the cattle-monitoring-system namespace is placed into the System Project (or a similarly locked down Project that has access to other Projects in the cluster)

Prometheus Operator's security model expects that the namespace it is deployed into (`cattle-monitoring-system`) has limited access for anyone except Cluster Admins to avoid privilege escalation via execing into Pods (such as the Jobs executing Helm operations). In addition, deploying Prometheus Federator and all Project Prometheus stacks into the System Project ensures that the each Project Prometheus is able to reach out to scrape workloads across all Projects (even if Network Policies are defined via Project Network Isolation) but has limited access for Project Owners, Project Members, and other users to be able to access data they shouldn't have access to (i.e. being allowed to exec into pods, set up the ability to scrape namespaces outside of a given Project, etc.).

### Configure rancher-monitoring to only watch for resources created by the Helm chart itself

Since each Project Monitoring Stack will watch the other namespaces and collect additional custom workload metrics or dashboards already, it's recommended to configure the following settings on all selectors to ensure that the Cluster Prometheus Stack only monitors resources created by the Helm Chart itself:

```
matchLabels:
  release: "rancher-monitoring"
```

The following selector fields are recommended to have this value:
- `.Values.alertmanager.alertmanagerSpec.alertmanagerConfigSelector`
- `.Values.prometheus.prometheusSpec.serviceMonitorSelector`
- `.Values.prometheus.prometheusSpec.podMonitorSelector`
- `.Values.prometheus.prometheusSpec.ruleSelector`
- `.Values.prometheus.prometheusSpec.probeSelector`

Once this setting is turned on, you can always create ServiceMonitors or PodMonitors that are picked up by the Cluster Prometheus by adding the label `release: "rancher-monitoring"` to them (in which case they will be ignored by Project Monitoring Stacks automatically by default, even if the namespace in which those ServiceMonitors or PodMonitors reside in are not system namespaces).

> Note: If you don't want to allow users to be able to create ServiceMonitors and PodMonitors that aggregate into the Cluster Prometheus in Project namespaces, you can additionally set the namespaceSelectors on the chart to only target system namespaces (which must contain `cattle-monitoring-system` and `cattle-dashboards`, where resources are deployed into by default by rancher-monitoring; you will also need to monitor the `default` namespace to get apiserver metrics or create a custom ServiceMonitor to scrape apiserver metrics from the Service residing in the default namespace) to limit your Cluster Prometheus from picking up other Prometheus Operator CRs; in that case, it would be recommended to turn `.Values.prometheus.prometheusSpec.ignoreNamespaceSelectors=true` to allow you to define ServiceMonitors that can monitor non-system namespaces from within a system namespace.

In addition, if you modified the default `.Values.grafana.sidecar.*.searchNamespace` values on the Grafana Helm subchart for Monitoring V2, it is also recommended to remove the overrides or ensure that your defaults are scoped to only system namespaces for the following values:
- `.Values.grafana.sidecar.dashboards.searchNamespace` (default `cattle-dashboards`)
- `.Values.grafana.sidecar.datasources.searchNamespace` (default `null`, which means it uses the release namespace `cattle-monitoring-system`)
- `.Values.grafana.sidecar.plugins.searchNamespace` (default `null`, which means it uses the release namespace `cattle-monitoring-system`)
- `.Values.grafana.sidecar.notifiers.searchNamespace` (default `null`, which means it uses the release namespace `cattle-monitoring-system`)

### Increase the CPU / memory limits of the Cluster Prometheus

Depending on a cluster's setup, it's generally recommended to give a large amount of dedicated memory to the Cluster Prometheus to avoid restarts due to out-of-memory errors (OOMKilled), usually caused by churn created in the cluster that causes a large number of high cardinality metrics to be generated and ingested by Prometheus within one block of time; this is one of the reasons why the default Rancher Monitoring stack expects around 4GB of RAM to be able to operate in a normal-sized cluster. However, when introducing Project Monitoring Stacks that are all sending `/federate` requests to the same Cluster Prometheus and are reliant on the Cluster Prometheus being "up" to federate that system data on their namespaces, it's even more important that the Cluster Prometheus has an ample amount of CPU / memory assigned to it to prevent an outage that can cause data gaps across all Project Prometheis in the cluster.

> Note: There are no specific recommendations on how much memory the Cluster Prometheus should be configured with since it depends entirely on the user's setup (namely the likelihood of encountering a high churn rate and the scale of metrics that could be generated at that time); it generally varies per setup.

## How does the operator work?

1. On deploying this chart, users can create ProjectHelmCharts CRs with `spec.helmApiVersion` set to `monitoring.cattle.io/v1alpha1` (also known as "Project Monitors" in the Rancher UI) in a **Project Registration Namespace (`cattle-project-<id>`)**. 
2. On seeing each ProjectHelmChartCR, the operator will automatically deploy a Project Prometheus stack on the Project Owner's behalf in the **Project Release Namespace (`cattle-project-<id>-monitoring`)** based on a HelmChart CR and a HelmRelease CR automatically created by the ProjectHelmChart controller in the **Operator / System Namespace**. 
3. RBAC will automatically be assigned in the Project Release Namespace to allow users to view the Prometheus, Alertmanager, and Grafana UIs of the Project Monitoring Stack deployed; this will be based on RBAC defined on the Project Registration Namespace against the [default Kubernetes user-facing roles](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles) (see below for more information about configuring RBAC).

### What is a Project?

In Prometheus Federator, a Project is a group of namespaces that can be identified by a `metav1.LabelSelector`; by default, the label used to identify projects is `field.cattle.io/projectId`, the label used to identify namespaces that are contained within a given [Rancher](https://rancher.com/) Project.

### Configuring the Helm release created by a ProjectHelmChart

The `spec.values` of this ProjectHelmChart resources will correspond to the `values.yaml` override to be supplied to the underlying Helm chart deployed by the operator on the user's behalf; to see the underlying chart's `values.yaml` spec, either:
- View to the chart's definition located at [`rancher/prometheus-federator` under `charts/rancher-project-monitoring`](https://github.com/rancher/prometheus-federator/blob/main/charts/rancher-project-monitoring) (where the chart version will be tied to the version of this operator)
- Look for the ConfigMap named `monitoring.cattle.io.v1alpha1` that is automatically created in each Project Registration Namespace, which will contain both the `values.yaml` and `questions.yaml` that was used to configure the chart (which was embedded directly into the `prometheus-federator` binary).

### Namespaces

As a Project Operator based on [rancher/helm-project-operator](https://github.com/rancher/helm-project-operator), Prometheus Federator has three different classifications of namespaces that the operator looks out for:
1. **Operator / System Namespace**: this is the namespace that the operator is deployed into (e.g. `cattle-monitoring-system`). This namespace will contain all HelmCharts and HelmReleases for all ProjectHelmCharts watched by this operator. **Only Cluster Admins should have access to this namespace.**
2. **Project Registration Namespace (`cattle-project-<id>`)**: this is the set of namespaces that the operator watches for ProjectHelmCharts within. The RoleBindings and ClusterRoleBindings that apply to this namespace will also be the source of truth for the auto-assigned RBAC created in the Project Release Namespace (see more details below). **Project Owners (admin), Project Members (edit), and Read-Only Members (view) should have access to this namespace**.
> Note: Project Registration Namespaces will be auto-generated by the operator and imported into the Project it is tied to if `.Values.global.cattle.projectLabel` is provided (which is set to `field.cattle.io/projectId` by default); this indicates that a Project Registration Namespace should be created by the operator if at least one namespace is observed with that label. The operator will not let these namespaces be deleted unless either all namespaces with that label are gone (e.g. this is the last namespace in that project, in which case the namespace will be marked with the label `"helm.cattle.io/helm-project-operator-orphaned": "true"`, which signals that it can be deleted) or it is no longer watching that project (because the project ID was provided under `.Values.helmProjectOperator.otherSystemProjectLabelValues`, which serves as a denylist for Projects). These namespaces will also never be auto-deleted to avoid destroying user data; it is recommended that users clean up these namespaces manually if desired on creating or deleting a project
> Note: if `.Values.global.cattle.projectLabel` is not provided, the Operator / System Namespace will also be the Project Registration Namespace
3. **Project Release Namespace (`cattle-project-<id>-monitoring`)**: this is the set of namespaces that the operator deploys Project Monitoring Stacks within on behalf of a ProjectHelmChart; the operator will also automatically assign RBAC to Roles created in this namespace by the Project Monitoring Stack based on bindings found in the Project Registration Namespace. **Only Cluster Admins should have access to this namespace; Project Owners (admin), Project Members (edit), and Read-Only Members (view) will be assigned limited access to this namespace by the deployed Helm Chart and Prometheus Federator.**
> Note: Project Release Namespaces are automatically deployed and imported into the project whose ID is specified under `.Values.helmProjectOperator.projectReleaseNamespaces.labelValue` (which defaults to the value of `.Values.global.cattle.systemProjectId` if not specified) whenever a ProjectHelmChart is specified in a Project Registration Namespace
> Note: Project Release Namespaces follow the same orphaning conventions as Project Registration Namespaces (see note above)
> Note: if `.Values.projectReleaseNamespaces.enabled` is false, the Project Release Namespace will be the same as the Project Registration Namespace

### Helm Resources (HelmChart, HelmRelease)

On deploying a ProjectHelmChart, the Prometheus Federator will automatically create and manage two child custom resources that manage the underlying Helm resources in turn:
- A HelmChart CR (managed via an embedded [k3s-io/helm-contoller](https://github.com/k3s-io/helm-controller) in the operator): this custom resource automatically creates a Job in the same namespace that triggers a `helm install`, `helm upgrade`, or `helm uninstall` depending on the change applied to the HelmChart CR; this CR is automatically updated on changes to the ProjectHelmChart (e.g. modifying the values.yaml) or changes to the underlying Project definition (e.g. adding or removing namespaces from a project). 
> **Important Note: If a ProjectHelmChart is not deploying or updating the underlying Project Monitoring Stack for some reason, the Job created by this resource in the Operator / System namespace should be the first place you check to see if there's something wrong with the Helm operation; however, this is generally only accessible by a Cluster Admin.**
- A HelmRelease CR (managed via an embedded [rancher/helm-locker](https://github.com/rancher/helm-locker) in the operator): this custom resource automatically locks a deployed Helm release in place and automatically overwrites updates to underlying resources unless the change happens via a Helm operation (`helm install`, `helm upgrade`, or `helm uninstall` performed by the HelmChart CR).
> Note: HelmRelease CRs emit Kubernetes Events that detect when an underlying Helm release is being modified and locks it back to place; to view these events, you can use `kubectl describe helmrelease <helm-release-name> -n <operator/system-namespace>`; you can also view the logs on this operator to see when changes are detected and which resources were attempted to be modified

Both of these resources are created for all Helm charts in the Operator / System namespaces to avoid escalation of privileges to underprivileged users.

### RBAC

As described in the section on namespaces above, Prometheus Federator expects that Project Owners, Project Members, and other users in the cluster with Project-level permissions (e.g. permissions in a certain set of namespaces identified by a single label selector) have minimal permissions in any namespaces except the Project Registration Namespace (which is imported into the project by default) and those that already comprise their projects. Therefore, in order to allow Project Owners to assign specific chart permissions to other users in their Project namespaces, the Helm Project Operator will automatically watch the following bindings:
- ClusterRoleBindings
- RoleBindings in the Project Release Namespace

On observing a change to one of those types of bindings, the Helm Project Operator will check whether the `roleRef` that the the binding points to matches a ClusterRole with the name provided under `helmProjectOperator.releaseRoleBindings.clusterRoleRefs.admin`, `helmProjectOperator.releaseRoleBindings.clusterRoleRefs.edit`, or `helmProjectOperator.releaseRoleBindings.clusterRoleRefs.view`; by default, these roleRefs correspond will correspond to `admin`, `edit`, and `view` respectively, which are the [default Kubernetes user-facing roles](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles).

> Note: for Rancher RBAC users, these [default Kubernetes user-facing roles](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles) directly correlate to the `Project Owner`, `Project Member`, and `Read-Only` default Project Role Templates.

If the `roleRef` matches, the Helm Project Operator will filter the `subjects` of the binding for all Users and Groups and use that to automatically construct a RoleBinding for each Role in the Project Release Namespace with the same name as the role and the following labels:
- `helm.cattle.io/project-helm-chart-role: {{ .Release.Name }}`
- `helm.cattle.io/project-helm-chart-role-aggregate-from: <admin|edit|view>`

By default, the `rancher-project-monitoring` (the underlying chart deployed by Prometheus Federator) creates three default Roles per Project Release Namespace that provide `admin`, `edit`, and `view` users to permissions to view the Prometheus, Alertmanager, and Grafana UIs of the Project Monitoring Stack to provide least privilege; however, if a Cluster Admin would like to assign additional permissions to certain users, they can either directly assign RoleBindings in the Project Release Namespace to certain users or created Roles with the above two labels on them to allow Project Owners to control assigning those RBAC roles to users in their Project Registration namespaces.

### Advanced Helm Project Operator Configuration

|Value|Configuration|
|---|---------------------------|
|`helmProjectOperator.valuesOverride`| Allows an Operator to override values that are set on each ProjectHelmChart deployment on an operator-level; user-provided options (specified on the `spec.values` of the ProjectHelmChart) are automatically overridden if operator-level values are provided. For an exmaple, see how the default value overrides `federate.targets` (note: when overriding list values like `federate.targets`, user-provided list values will **not** be concatenated) |
|`helmProjectOperator.projectReleaseNamespaces.labelValues`| The value of the Project that all Project Release Namespaces should be auto-imported into (via label and annotation). Not recommended to be overridden on a Rancher setup. |
|`helmProjectOperator.otherSystemProjectLabelValues`| Other namespaces that the operator should treat as a system namespace that should not be monitored. By default, all namespaces that match `global.cattle.systemProjectId` will not be matched. `cattle-monitoring-system`, `cattle-dashboards`, and `kube-system` are explicitly marked as system namespaces as well, regardless of label or annotation. |
|`helmProjectOperator.releaseRoleBindings.aggregate`| Whether to automatically create RBAC resources in Project Release namespaces
|`helmProjectOperator.releaseRoleBindings.clusterRoleRefs.<admin\|edit\|view>`| ClusterRoles to reference to discover subjects to create RoleBindings for in the Project Release Namespace for all corresponding Project Release Roles. See RBAC above for more information |
|`helmProjectOperator.hardenedNamespaces.enabled`| Whether to automatically patch the default ServiceAccount with `automountServiceAccountToken: false` and create a default NetworkPolicy in all managed namespaces in the cluster; the default values ensure that the creation of the namespace does not break a CIS 1.16 hardened scan |
|`helmProjectOperator.hardenedNamespaces.configuration`| The configuration to be supplied to the default ServiceAccount or auto-generated NetworkPolicy on managing a namespace |
|`helmProjectOperator.helmController.enabled`| Whether to enable an embedded k3s-io/helm-controller instance within the Helm Project Operator. Should be disabled for RKE2/K3s clusters before v1.23.14 / v1.24.8 / v1.25.4 since RKE2/K3s clusters already run Helm Controller at a cluster-wide level to manage internal Kubernetes components |
|`helmProjectOperator.helmLocker.enabled`| Whether to enable an embedded rancher/helm-locker instance within the Helm Project Operator. |
