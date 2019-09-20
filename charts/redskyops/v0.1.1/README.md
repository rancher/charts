# Red Sky Ops

## Chart Repository

The Red Sky Ops chart repository can be configured in Helm as follows:

```sh
helm repo add redsky https://redskyops.dev/charts/
helm repo update
```

## Installing the Chart

The Red Sky Ops manager can be installed using the Helm command:

```sh
helm install --namespace redsky-system --name redsky redsky/redskyops
```

The recommended namespace (`redsky-system`) and release name (`redsky`) are consistent with an install performed using the `redskyctl` tool (see the [install guide](https://redskyops.dev/docs/install/) for more information).

## Configuration

The following configuration options are available:

| Parameter            | Description                                      |
| -------------------- | ------------------------------------------------ |
| `redskyImage`        | Docker image name                                |
| `redskyTag`          | Docker image tag                                 |
| `address`            | Fully qualified URL of the remote server         |
| `oauth2ClientID`     | OAuth2 client identifier                         |
| `oauth2ClientSecret` | OAuth2 client secret                             |
| `oauth2TokenURL`     | Override default OAuth2 token URL                |
| `rbac.create`        | Specify whether RBAC resources should be created |
