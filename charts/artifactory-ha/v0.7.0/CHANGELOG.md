# JFrog Artifactory-ha Chart Changelog
All changes to this chart will be documented in this file.

## [0.7.0] - Oct 28, 2018
* Update postgresql chart to version 0.9.5 to be able and use `postgresConfig` options

## [0.6.9] - Oct 23, 2018
* Fix providing external secret for database credentials

## [0.6.8] - Oct 22, 2018
* Allow user to configure externalTrafficPolicy for Loadbalancer

## [0.6.7] - Oct 22, 2018
* Updated ingress annotation support (with examples) to support docker registry v2

## [0.6.6] - Oct 21, 2018
* Updated Artifactory version to 6.5.2

## [0.6.5] - Oct 19, 2018
* Allow providing pre-existing secret containing master key
* Allow arbitrary annotations on primary and member node pods
* Enforce size limits when using local storage with `emptyDir`
* Allow `soft` or `hard` specification of member node anti-affinity
* Allow providing pre-existing secrets containing external database credentials
* Fix `s3` binary store provider to properly use the `cache-fs` provider
* Allow arbitrary properties when using the `s3` binary store provider

## [0.6.4] - Oct 18, 2018
* Updated Artifactory version to 6.5.1

## [0.6.3] - Oct 17, 2018
* Add Apache 2.0 license

## [0.6.2] - Oct 14, 2018
* Make S3 endpoint configurable (was hardcoded with `s3.amazonaws.com`)

## [0.6.1] - Oct 11, 2018
* Allows ingress default `backend` to be enabled or disabled (defaults to enabled)

## [0.6.0] - Oct 11, 2018
* Updated Artifactory version to 6.5.0

## [0.5.3] - Oct 9, 2018
* Quote ingress hosts to support wildcard names

## [0.5.2] - Oct 2, 2018
* Add `helm repo add jfrog https://charts.jfrog.io` to README

## [0.5.1] - Oct 2, 2018
* Set Artifactory to 6.4.1

## [0.5.0] - Sep 27, 2018
* Set Artifactory to 6.4.0

## [0.4.7] - Sep 26, 2018
* Add ci/test-values.yaml

## [0.4.6] - Sep 25, 2018
* Add PodDisruptionBudget for member nodes, defaulting to minAvailable of 1

## [0.4.4] - Sep 2, 2018
* Updated Artifactory version to 6.3.2

## [0.4.0] - Aug 22, 2018
* Added support to run as non root
* Updated Artifactory version to 6.2.0

## [0.3.0] - Aug 22, 2018
* Enabled RBAC Support
* Added support for PostStartCommand (To download Database JDBC connector)
* Increased postgresql max_connections
* Added support for `nginx.conf` ConfigMap
* Updated Artifactory version to 6.1.0  
