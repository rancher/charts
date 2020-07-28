# Changelog
All notable changes from the upstream OPA Gatekeeper chart will be added to this file

## [Package Version 00] - 2020-07-27
### Added

### Modified
- Updated chart version in `Chart.yaml` to follow the upstream's format `v3.1.0-beta.X`
- Disabled webhook validation in chart values (`disableValidatingWebhook: true`) since
the webhook service was removed. Ideally, we would like to remove the validation too, 
but setting this flag achieves the same results without cluttering the patch.
- Updated namespace to `cattle-gatekeeper-system`

### Removed
- Removed `gatekeeper-webhook-service-service.yaml` as the `gatekeeper-webhook-service` 
was removed in our previous version of the chart
- Removed `gatekeeper-system-namespace.yaml` as Rancher handles namespaces for chart installation
