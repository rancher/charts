# Changelog
All notable changes from the upstream OPA Gatekeeper chart will be added to this file

## [Package Version 00] - 2020-07-27
### Added

### Modified
- Updated chart version in `Chart.yaml` to follow the upstream's format `v3.1.0-beta.X`

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
