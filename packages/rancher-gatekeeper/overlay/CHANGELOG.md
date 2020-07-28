# Changelog
All notable changes from the upstream OPA Gatekeeper chart will be added to this file

## [Package Version 00] - 2020-07-27
### Added
- Added `validate_crds_installed.yaml` to validate crds are installed before installing racher-gatekeeper
- Added the following crd annotations for `rancher-gatekeeper-crd` chart dependency:
    - `catalog.cattle.io/requires-gvr: configs.config.gatekeeper.sh/v1alpha1`
    - `catalog.cattle.io/auto-install-gvr: configs.config.gatekeeper.sh/v1alpha1`

### Modified
- Updated chart version in `Chart.yaml` to follow the upstream's format `v3.1.0-beta.X`
- Updated namespace to `cattle-gatekeeper-system`
- Updated `rancher/istio-kubectl` image to `1.5.8`

### Removed
- Removed the following files as the `gatekeeper-webhook-service` was removed in our previous version of the chart
    - `gatekeeper-validating-webhook-configuration-validatingwebhookconfiguration.yaml`
    - `gatekeeper-webhook-service-service.yaml`
- Removed `gatekeeper-system-namespace.yaml` as Rancher handles namespaces for chart installation
- Removed the following crds as they will reside in a separate chart
    - `config-customresourcedefinition.yaml`                                          
    - `constraintpodstatus-customresourcedefinition.yaml`                             
    - `constrainttemplate-customresourcedefinition.`                              
    - `constrainttemplatepodstatus-customresourcedefinition.yaml`
- Removed unnecessary `index.yaml` as we package and host our charts
