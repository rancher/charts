# phpBB

[phpBB](https://www.phpbb.com/) is an Internet forum package written in the PHP scripting language. The name "phpBB" is an abbreviation of PHP Bulletin Board.

## Introduction

This chart bootstraps a [phpBB](https://github.com/bitnami/bitnami-docker-phpbb) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

It also packages the [Bitnami MariaDB chart](https://github.com/kubernetes/charts/tree/master/stable/mariadb) which is required for bootstrapping a MariaDB deployment for the database requirements of the phpBB application.

## Configuration

The following table lists the configurable parameters of the phpBB chart and their default values.

|             Parameter             |              Description              |                         Default                         |
|-----------------------------------|---------------------------------------|---------------------------------------------------------|
| `image.registry`                  | phpBB image registry                  | `docker.io`                                             |
| `image.repository`                | phpBB image name                      | `bitnami/phpbb`                                         |
| `image.tag`                       | phpBB image tag                       | `{VERSION}`                                             |
| `image.pullPolicy`                | Image pull policy                     | `Always` if `imageTag` is `latest`, else `IfNotPresent` |
| `image.pullSecrets`               | Specify image pull secrets            | `nil`                                                   |
| `phpbbUser`                       | User of the application               | `user`                                                  |
| `phpbbPassword`                   | Application password                  | _random 10 character long alphanumeric string_          |
| `phpbbEmail`                      | Admin email                           | `user@example.com`                                      |
| `allowEmptyPassword`              | Allow DB blank passwords              | `yes`                                                   |
| `smtpHost`                        | SMTP host                             | `nil`                                                   |
| `smtpPort`                        | SMTP port                             | `nil`                                                   |
| `smtpUser`                        | SMTP user                             | `nil`                                                   |
| `smtpPassword`                    | SMTP password                         | `nil`                                                   |
| `externalDatabase.host`           | Host of the external database         | `nil`                                                   |
| `externalDatabase.user`           | Existing username in the external db  | `bn_phpbb`                                              |
| `externalDatabase.password`       | Password for the above username       | `nil`                                                   |
| `externalDatabase.database`       | Name of the existing database         | `bitnami_phpbb`                                         |
| `mariadb.enabled`                 | Use or not the MariaDB chart          | `true`                                                  |
| `mariadb.rootUser.password`     | MariaDB admin password                | `nil`                                                   |
| `mariadb.db.name`         | Database name to create               | `bitnami_phpbb`                                         |
| `mariadb.db.user`             | Database user to create               | `bn_phpbb`                                              |
| `mariadb.db.password`         | Password for the database             | _random 10 character long alphanumeric string_          |
| `serviceType`                     | Kubernetes Service type               | `LoadBalancer`                                          |
| `persistence.enabled`             | Enable persistence using PVC          | `true`                                                  |
| `persistence.apache.storageClass` | PVC Storage Class for Apache volume   | `nil` (uses alpha storage class annotation)             |
| `persistence.apache.accessMode`   | PVC Access Mode for Apache volume     | `ReadWriteOnce`                                         |
| `persistence.apache.size`         | PVC Storage Request for Apache volume | `1Gi`                                                   |
| `persistence.phpbb.storageClass`  | PVC Storage Class for phpBB volume    | `nil` (uses alpha storage class annotation)             |
| `persistence.phpbb.accessMode`    | PVC Access Mode for phpBB volume      | `ReadWriteOnce`                                         |
| `persistence.phpbb.size`          | PVC Storage Request for phpBB volume  | `8Gi`                                                   |
| `resources`                       | CPU/Memory resource requests/limits   | Memory: `512Mi`, CPU: `300m`                            |

The above parameters map to the env variables defined in [bitnami/phpbb](http://github.com/bitnami/bitnami-docker-phpbb). For more information please refer to the [bitnami/phpbb](http://github.com/bitnami/bitnami-docker-phpbb) image documentation.

## Persistence

The [Bitnami phpBB](https://github.com/bitnami/bitnami-docker-phpbb) image stores the phpBB data and configurations at the `/bitnami/phpbb` and `/bitnami/apache` paths of the container.

Persistent Volume Claims are used to keep the data across deployments. This is known to work in GCE, AWS, and minikube.
See the [Configuration](#configuration) section to configure the PVC or to disable persistence.
