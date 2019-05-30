# WordPress

[WordPress](https://wordpress.org/) is one of the most versatile open source content management systems on the market. A publishing platform for building blogs and websites.

This chart bootstraps a [WordPress](https://github.com/bitnami/bitnami-docker-wordpress) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager. The chart also packages the [Bitnami MariaDB chart](https://github.com/kubernetes/charts/tree/master/stable/mariadb) to provide the backend database for the WordPress application.

Notes: MariaDB has been configured as a StatefulSet, and it will provision PersistentVolume dynamically using VolumeClaimTemplate. Users can use the existing Persistent Volume by creating PVC with name i.e. `data-wordpress-mariadb-0`
