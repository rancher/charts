# Jenkins SSH slave Docker image

[`jenkins/ssh-slave`](https://hub.docker.com/r/jenkins/ssh-slave/)

A [Jenkins](https://jenkins-ci.org) slave using SSH to establish connection.

See [Jenkins Distributed builds](https://wiki.jenkins-ci.org/display/JENKINS/Distributed+builds) for more info.

## Running

To run a Docker container

```bash
docker run jenkins/ssh-slave "<public key>"
```

You'll then be able to connect this slave using ssh-slaves-plugin as "jenkins" with the matching private key.

### How to use this image with Docker Plugin

To use this image with [Docker Plugin](https://wiki.jenkins-ci.org/display/JENKINS/Docker+Plugin), you need to
pass the public SSH key using environment variable `JENKINS_SLAVE_SSH_PUBKEY` and not as a startup argument.

In _Environment_ field of the Docker Template (advanced section), just add:

    JENKINS_SLAVE_SSH_PUBKEY=<YOUR PUBLIC SSH KEY HERE>

Don't put quotes around the public key. You should be all set.


## Configuration

The following table lists the configurable parameters of the Jenkins SSH Slave chart and their default values.

| Parameter                            | Description                                | Default                                                    |
| ------------------------------------ | ------------------------------------------ | ---------------------------------------------------------- |
| `image.registry`                     | Jenkins SSH Slave image registry           | `docker.io`                                                |
| `image.repository`                   | Jenkins SSH Slave image name               | `jenkinsci/ssh-slave`                                      |
| `image.tag`                          | WordPress image tag                        | `{VERSION}`                                                |
| `image.pullPolicy`                   | Image pull policy                          | `Always` if `imageTag` is `latest`, else `IfNotPresent`    |
| `image.pullSecrets`                  | Specify image pull secrets                 | `nil`                                                      |
| `jenkinsSSHPublicKey`                | Public SSH Key to access this node         | `nil`                                                      |
| `serviceType`                        | Service type (either Nodeport or ClusterIP)| `nil`                                                      |
| `nodePorts.ssh`                      | Nodeport (automatically addined if `nil`   | `nil`                                                      |

> **Protip**: Use ClusterIP only if your Jenkins instance is running on the same cluster as 
> the SSH Slaves. Otherwise use NodePort.
