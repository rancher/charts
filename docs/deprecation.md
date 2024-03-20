## Rancher Charts Deprecation Policy

### Introduction

This deprecation policy applies to all Helm charts maintained in this repository. It is designed to inform users about our approach to deprecating and removing charts, ensuring that transitions are smooth and expectations are managed appropriately.

### Objectives

Our deprecation policy aims to:

- Provide clear and consistent guidelines on the lifecycle of Helm charts within our repository.
- Ensure stability for users utilizing our charts.
- Encourage the adoption of the latest features, fixes, and improvements.
- Efficiently manage project resources by focusing on charts that offer significant value to our users.

### Versioning and Releases

We adhere to [Semantic Versioning (SemVer)](https://semver.org/) for our Helm charts, where releases may introduce bug fixes, new features, or improvements. SemVer dictates:

- **Major versions (X.y.z)** introduce breaking changes.
- **Minor versions (x.Y.z)** add functionality in a backward-compatible manner.
- **Patch versions (x.y.Z)** are for backward-compatible bug fixes.

A chart may be deprecated for a number of reasons: upstream chart is no longer available or is not receiving updates, replacement by another chart, a business decision, etc. This repository follows the deprecation policy of Rancher.

### Deprecation Timeline

- **General Availability**: The chart is available in Rancher version X.Y.Z

- **Notice Period**: Deprecation notice provided to users in Rancher X.(Y+1).0. The chart will be supported and maintained through out the supported lifecycle of the minor release.

- **Chart Deprecated**: The chart will be deprecated in Rancher X.(Y+2).0. The chart will be available to support users who need to upgrade from the X.Y.Z release. The chart is only available as-is and will only receive critical security updates.

- **End of Life (EOL)**: the chart EOL will be in Rancher X.(Y+3).0. The chart is removed from Rancher in this release. Users must have migrated away from or disabled this feature before upgrading to this release.

### Migration Assistance

For significant deprecations, migration guides or documentation will be provided to help users transition to newer versions or alternatives.

## Exceptions

Special circumstances, such as critical security vulnerabilities, may necessitate immediate action beyond this policy. Any exceptions will be communicated transparently and promptly.
