# Changelog
All notable changes from the upstream OPA Gatekeeper chart will be added to this file

## [Package Version 00] - 2020-09-10
### Added
- Enabled the CRD chart generator in `package.yaml`

### Modified
- Updated namespace to `cattle-gatekeeper-system`
- Updated for Helm 3 compatibility
    - Moved crds to `crds` directory
    - Removed `crd-install` hooks and templates from crds

### Removed
- Removed `gatekeeper-system-namespace.yaml` as Rancher handles namespaces for chart installation
