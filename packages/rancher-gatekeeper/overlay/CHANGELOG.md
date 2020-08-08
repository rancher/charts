# Changelog
All notable changes from the upstream OPA Gatekeeper chart will be added to this file

## [Package Version 00] - 2020-07-27
### Added
- Enabled the CRD chart generator in `package.yaml`

### Modified
- Updated namespace to `cattle-gatekeeper-system`
- Updated `rancher/istio-kubectl` image to `1.5.8`
- Updated for Helm 3 compatibility
    - Moved crds to `crds` directory
    - Removed `crd-install` hooks and templates from crds

### Removed
- Removed `gatekeeper-system-namespace.yaml` as Rancher handles namespaces for chart installation
- Removed unnecessary `index.yaml` as we package and host our charts
