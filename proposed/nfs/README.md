## Prerequisites

- Kubernetes 1.5+ with Beta APIs enabled
- PV provisioner support in the underlying infrastructure

## Uninstalling the Chart

If you have chart using this storageClass as dynamic provisioner, please backup the data and remove all the relevant chart before uninstall the nfs chart.

Lastly click `Delete` from the Catalog page will removes all the Kubernetes components associated with the nfs chart and deletes the release.


---
Please see [this example](https://github.com/kubernetes-incubator/external-storage/tree/master/nfs)
for more information.
