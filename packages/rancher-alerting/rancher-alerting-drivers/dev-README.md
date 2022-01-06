# rancher-alerting-drivers

To add a new driver:
- develop a new driver as an independent chart under the `packages/` directory in this repo
- add a new directory and dependency.yaml file under the `generated-changes/dependencies/` directory in the current directory
- update the `charts/templates/values.yaml` file with the configuration for the new driver

To develop this chart and drivers, please follow the instructions for Rancher Chart and Package:
- [Rancher Chart](https://github.com/rancher/charts/tree/master#rancher-chart-structure)
- [Rancher Package](https://github.com/rancher/charts/tree/dev-v2.5-source/packages#packages)