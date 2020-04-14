# Upgrade considerations

New versions of the Kong chart may add significant new functionality or
deprecate/entirely remove old functionality. This document covers how and why
users should update their chart configuration to take advantage of new features
or migrate away from deprecated features.

In general, breaking changes deprecate their old features before removing them
entirely. While support for the old functionality remains, the chart will show
a warning about the outdated configuration when running `helm
install/status/upgrade`.

## Table of contents

- [Upgrade considerations for all versions](#upgrade-considerations-for-all-versions)
- [1.5.0](#150)
- [1.4.0](#140)
- [1.3.0](#130)

## Upgrade considerations for all versions

The chart automates the
[upgrade migration process](https://github.com/Kong/kong/blob/master/UPGRADE.md).
When running `helm upgrade`, the chart spawns an initial job to run `kong
migrations up` and then spawns new Kong pods with the updated version. Once
these pods become ready, they begin processing traffic and old pods are
terminated. Once this is complete, the chart spawns another job to run `kong
migrations finish`.

If you split your Kong deployment across multiple Helm releases (to create
proxy-only and admin-only nodes, for example), you must
[set which migration jobs run based on your upgrade order](https://github.com/Kong/charts/blob/master/charts/kong/README.md#separate-admin-and-proxy-nodes).

While the migrations themselves are automated, the chart does not automatically
ensure that you follow the recommended upgrade path. If you are upgrading from
more than one minor Kong version back, check the [upgrade path
recommendations for Kong open source](https://github.com/Kong/kong/blob/master/UPGRADE.md#3-suggested-upgrade-path)
or [Kong Enterprise](https://docs.konghq.com/enterprise/latest/deployment/migrations/).

Although not required, users should upgrade their chart version and Kong
version indepedently. In the even of any issues, this will help clarify whether
the issue stems from changes in Kubernetes resources or changes in Kong.

Users may encounter an error when upgrading which displays a large block of
text ending with `field is immutable`. This is typically due to a bug with the
`init-migrations` job, which was not removed automatically prior to 1.5.0.
If you encounter this error, deleting any existing `init-migrations` jobs will
clear it.

## 1.5.0

### PodSecurityPolicy defaults to read-only root filesystem

1.5.0 defaults to using a read-only root container filesystem if
`podSecurityPolicy.enabled: true` is set in values.yaml. This improves
security, but is incompatible with Kong Enterprise versions prior to 1.5. If
you use an older version and enable PodSecurityPolicy, you must set
`podSecurityPolicy.spec.readOnlyRootFilesystem: false`.

Kong open-source and Kong for Kubernetes Enterprise are compatible with a
read-only root filesystem on all versions.

### Changes to migration job configuration

Previously, all migration jobs were enabled/disabled through a single
`runMigrations` setting. 1.5.0 splits these into toggles for each of the
individual upgrade migrations:

```
migrations:
  preUpgrade: true
  postUpgrade: true
```

Initial migration jobs are now only run during `helm install` and are deleted
automatically when users first run `helm upgrade`.

Users should replace `runMigrations` with the above block from the latest
values.yaml.

The new format addresses several needs:
* The initial migrations job are only created during the initial install,
  preventing [conflicts on upgrades](https://github.com/Kong/charts/blob/master/charts/kong/FAQs.md#running-helm-upgrade-fails-because-of-old-init-migrations-job).
* The upgrade migrations jobs can be disabled as need for managing
  [multi-release clusters](https://github.com/Kong/charts/blob/master/charts/kong/README.md#separate-admin-and-proxy-nodes).
  This enables management of clusters that have nodes with different roles,
  e.g. nodes that only run the proxy and nodes that only run the admin API.
* Migration jobs now allow specifying annotations, and provide a default set
  of annotations that disable some service mesh sidecars. Because sidecar
  containers do not terminate, they [prevent the jobs from completing](https://github.com/kubernetes/kubernetes/issues/25908).

## 1.4.0

### Changes to default Postgres permissions

The [Postgres sub-chart](https://github.com/bitnami/charts/tree/master/bitnami/postgresql)
used by this chart has modified the way their chart handles file permissions.
This is not an issue for new installations, but prevents Postgres from starting
if its PVC was created with an older version. If affected, your Postgres pod
logs will show:

```
postgresql 19:16:04.03 INFO  ==> ** Starting PostgreSQL **
2020-03-27 19:16:04.053 GMT [1] FATAL:  data directory "/bitnami/postgresql/data" has group or world access
2020-03-27 19:16:04.053 GMT [1] DETAIL:  Permissions should be u=rwx (0700).
```

You can restore the old permission handling behavior by adding two settings to
the `postgresql` block in values.yaml:

```yaml
postgresql:
  enabled: true
  postgresqlDataDir: /bitnami/postgresql/data
  volumePermissions:
    enabled: true
```

For background, see https://github.com/helm/charts/issues/13651

### `strip_path` now defaults to `false` for controller-managed routes

1.4.0 defaults to version 0.8 of the ingress controller, which changes the
default value of the `strip_path` route setting from `true` to `false`. To
understand how this works in practice, compare the upstream path for these
requests when `strip_path` is toggled:

| Ingress path | `strip_path` | Request path | Upstream path |
|--------------|--------------|--------------|---------------|
| /foo/bar     | true         | /foo/bar/baz | /baz          |
| /foo/bar     | false        | /foo/bar/baz | /foo/bar/baz  |

This change brings the controller in line with the Kubernetes Ingress
specification, which expects that controllers will not modify the request
before passing it upstream unless explicitly configured to do so.

To preserve your existing route handling, you should add this annotation to
your ingress resources:

```
konghq.com/strip-path: "true"
```

This is a new annotation that is equivalent to the `route.strip_path` setting
in KongIngress resources. Note that if you have already set this to `false`,
you should leave it as-is and not add an annotation to the ingress.

### Changes to Kong service configuration 

1.4.0 reworks the templates and configuration used to generate Kong
configuration and Kuberenetes resources for Kong's services (the admin API,
proxy, Developer Portal, etc.). For the admin API, this requires breaking
changes to the configuration format in values.yaml. Prior to 1.4.0, the admin
API allowed a single listen only, which could be toggled between HTTPS and
HTTP:

```yaml
admin:
  enabled: false # create Service
  useTLS: true
  servicePort: 8444
  containerPort: 8444
```
In 1.4.0+, the admin API allows enabling or disabling the HTTP and TLS listens
independently. The equivalent of the above configuration is:

```yaml
admin:
  enabled: false # create Service
  http:
    enabled: false # create HTTP listen
    servicePort: 8001
    containerPort: 8001
    parameters: []

  tls:
    enabled: true # create HTTPS listen
    servicePort: 8444
    containerPort: 8444
    parameters:
    - http2
```
All Kong services now support `SERVICE.enabled` parameters: these allow
disabling the creation of a Kubernetes Service resource for that Kong service,
which is useful in configurations where nodes have different roles, e.g. where
some nodes only handle proxy traffic and some only handle admin API traffic. To
disable a Kong service completely, you should also set `SERVICE.http.enabled:
false` and `SERVICE.tls.enabled: false`. Disabling creation of the Service
resource only leaves the Kong service enabled, but only accessible within its
pod. The admin API is configured with only Service creation disabled to allow
the ingress controller to access it without allowing access from other pods.

Services now also include a new `parameters` section that allows setting
additional listen options, e.g. the `reuseport` and `backlog=16384` parameters
from the [default 2.0.0 proxy
listen](https://github.com/Kong/kong/blob/2.0.0/kong.conf.default#L186). For
compatibility with older Kong versions, the chart defaults do not enable most
of the newer parameters, only HTTP/2 support. Users of versions 1.3.0 and newer
can safely add the new parameters.

## 1.3.0

### Removal of dedicated Portal authentication configuration parameters

1.3.0 deprecates the `enterprise.portal.portal_auth` and
`enterprise.portal.session_conf_secret` settings in values.yaml in favor of
placing equivalent configuration under `env`. These settings are less important
in Kong Enterprise 0.36+, as they can both be set per workspace in Kong
Manager.

These settings provide the default settings for Portal instances: when the
"Authentication plugin" and "Session Config" dropdowns at
https://manager.kong.example/WORKSPACE/portal/settings/ are set to "Default",
the settings from `KONG_PORTAL_AUTH` and `KONG_PORTAL_SESSION_CONF` are used.
If these environment variables are not set, the defaults are to use
`basic-auth` and `{}` (which applies the [session plugin default
configuration](https://docs.konghq.com/hub/kong-inc/session/)).

If you set nonstandard defaults and wish to keep using these settings, or use
Kong Enterprise 0.35 (which did not provide a means to set per-workspace
session configuration) you should convert them to environment variables. For
example, if you currently have:

```yaml
portal:
  enabled: true
  portal_auth: basic-auth
  session_conf_secret: portal-session
```
You should remove the `portal_auth` and `session_conf_secret` entries and
replace them with their equivalents under the `env` block:

```yaml
env:
  portal_auth: basic-auth
  portal_session_conf:
    valueFrom:
      secretKeyRef:
        name: portal-session
        key: portal_session_conf
```
