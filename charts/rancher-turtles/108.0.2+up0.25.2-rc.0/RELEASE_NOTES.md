🚨 This is a RELEASE CANDIDATE. Use it only for testing purposes. If you find any bugs, file an [issue](https://github.com/rancher/turtles/issues/new).
<details>
<summary>More details about the release</summary>

:warning: **RELEASE CANDIDATE NOTES** :warning:
## Highlights

* REPLACE ME

## Deprecation Warning

REPLACE ME: A couple sentences describing the deprecation, including links to docs.

* [GitHub issue #REPLACE ME](REPLACE ME)

## Changes since v0.25.1-rc.1
## :chart_with_upwards_trend: Overview
- 116 new commits merged
- 1 bug fixed 🐛

## :bug: Bug Fixes
- Build-and-release: Fix: wrong github token value in core capi workflow (#1829)

## :seedling: Others
- Build-and-release: Append target branch to backport PR title (#1768)

:book: Additionally, there have been 5 contributions to our documentation and book. (#1865, #1870, #1873, #1887, #1937) 

## :question: Sort these by hand
- API: Fix: Use CAPIProvider's name to select resources (#1918)
- Build-and-release: [main] fix: org value not set in release workflow (#1758)
- Build-and-release: Add backport automation GitHub workflow (#1754)
- Build-and-release: Chore(deps): Bump actions/checkout from 5 to 6 (#1910)
- Build-and-release: Chore(deps): Bump actions/checkout from 5.0.1 to 6.0.1 (#1925)
- Build-and-release: Chore(deps): Bump actions/setup-go from 6.0.0 to 6.1.0 (#1909)
- Build-and-release: Chore(deps): Bump actions/upload-artifact from 4 to 5 (#1839)
- Build-and-release: Chore(deps): Bump actions/upload-artifact from 5 to 6 (#1940)
- Build-and-release: Chore(deps): Bump docker/setup-qemu-action from 3.6.0 to 3.7.0 (#1878)
- Build-and-release: Chore(deps): Bump github/codeql-action from 3 to 4 (#1815)
- Build-and-release: Chore(deps): Bump golangci/golangci-lint-action from 8 to 9 (#1876)
- Build-and-release: Chore(deps): Bump rancher/aws-janitor from 0.2.0 to 0.3.0 (#1743)
- Build-and-release: Chore(deps): Bump rancherlabs/slsactl from 0.0.15 to 0.0.16 (#1833)
- Build-and-release: Chore(deps): Bump rancherlabs/slsactl from 0.0.16 to 0.0.18 (#1840)
- Build-and-release: Chore(deps): Bump rancherlabs/slsactl from 0.0.18 to 0.1.1 (#1856)
- Build-and-release: Chore(deps): Bump rancherlabs/slsactl from 0.1.1 to 0.1.2 (#1875)
- Build-and-release: Chore(deps): Bump rancherlabs/slsactl from 0.1.11 to 0.1.12 (#1962)
- Build-and-release: Chore(deps): Bump rancherlabs/slsactl from 0.1.2 to 0.1.6 (#1911)
- Build-and-release: Chore(deps): Bump rancherlabs/slsactl from 0.1.6 to 0.1.9 (#1921)
- Build-and-release: Chore(deps): Bump sigstore/cosign-installer from 3.10.0 to 4.0.0 (#1834)
- Build-and-release: Chore: bump slsactl to v0.1.11 (#1932)
- Build-and-release: Ci: Add attestation (#1730)
- Build-and-release: Cleanup release workflow and build action (#1755)
- Build-and-release: Clearly separate legacy release workflow from current one (#1938)
- Build-and-release: Docs: Add document for new release process (#1761)
- Build-and-release: Docs: Add step for releasing providers chart (#1951)
- Build-and-release: Docs: Adjust release steps (#1898)
- Build-and-release: Fix secret path for backport automation (#1757)
- Build-and-release: Fix: Bump Go version to 1.24.9 (#1838)
- Build-and-release: Fix: Include tag when invoking `slsactl download` (#1914)
- Build-and-release: Fix: legacy release workflow running on >=v0.25 (#1916)
- Build-and-release: Fix: permissions to create release from workflow (#1936)
- Build-and-release: Fix: update nested imageVersion in values.yaml (#1747)
- Build-and-release: Use bash in release-against-rancher.sh for pushd/popd support (#1760)
- Build-and-release: Use proper path for backport secrets (#1765)
- Caprke2: Providers: update CAPRKE2 to v0.21.1 (#1869)
- Certificates: [feat] cert-manager to wrangler conversion (#1794)
- Chart: Bump rancher-version in chart.yaml (#1785)
- Chart: Chore: Drop CAPRKE2 and CAAPF templates from rancher-turtles chart (#1789)
- Chart: Correct Providers release-name (#1813)
- Chart: Fix: Change `capi-system` namespace to `cattle-capi-system` (#1837)
- Chart: Fix: Change Turtles namespace to `cattle-turtles-system` (#1818)
- Chart: Fix: Set `securityContext` field to Turtles controller and hooks manifests (#1850)
- Chart: Remove Extension mentions from chart (#1871)
- Chart: Switch deprecated rancher/kubectl image to rancher/kuberlr-kubectl (#1895)
- CI: Bump e2e to k8s 1.34 (#1872)
- CI: Bump Rancher to 2.13.0-rc1 and enable debug logging (#1896)
- CI: CI fixes for vsphere (#1952)
- CI: Enable debug verbosity on e2e providers (#1891)
- CI: Feat: Install Turtles as system chart in dev-env (#1836)
- CI: Fix artifacts collection at the end of e2e tests (#1888)
- CI: Fix gitea ingress template (#1860)
- CI: Fix Rancher channel on dev-env script (#1899)
- CI: Install Turtles as system chart in all test suites (#1933)
- CI: Prevent flaky imported annotation removal (#1967)
- CI: Undeprecate DeployRancher method for stable Turtles deployments (#1966)
- CI: Use docker image for chart-testing cli (#1883)
- CI: Use Rancher v2.13 for e2e (#1843)
- CI: Wait for rancher-webhook before installing providers (#1846)
- CI: Wait for rancher-webhook when testing charts (#1853)
- Dependency: Bump CAPI operator patch version (#1905)
- Dependency: Bump kubernetes version to v1.32.x series (#1787)
- Dependency: Chore(deps): Bump github.com/onsi/ginkgo/v2 from 2.25.3 to 2.26.0 in /test in the testing-dependencies group (#1801)
- Dependency: Chore(deps): Bump github.com/onsi/ginkgo/v2 from 2.25.3 to 2.26.0 in the testing-dependencies group (#1802)
- Dependency: Chore(deps): Bump github.com/onsi/ginkgo/v2 from 2.26.0 to 2.27.1 in /test in the testing-dependencies group (#1842)
- Dependency: Chore(deps): Bump github.com/onsi/ginkgo/v2 from 2.26.0 to 2.27.1 in the testing-dependencies group (#1841)
- Dependency: Chore(deps): Bump github.com/onsi/ginkgo/v2 from 2.27.1 to 2.27.2 in the testing-dependencies group (#1857)
- Dependency: Chore(deps): Bump golang.org/x/crypto from 0.42.0 to 0.45.0 (#1902)
- Dependency: Chore(deps): Bump golang.org/x/crypto from 0.42.0 to 0.45.0 in /test (#1901)
- Dependency: Chore(deps): Bump golang.org/x/text from 0.29.0 to 0.30.0 in the other-dependencies group (#1814)
- Dependency: Chore(deps): Bump golang.org/x/text from 0.31.0 to 0.32.0 in the other-dependencies group (#1942)
- Dependency: Chore(deps): Bump sigs.k8s.io/kind from 0.29.0 to 0.30.0 in /test in the other-dependencies group across 1 directory (#1751)
- Dependency: Chore(deps): Bump the testing-dependencies group in /test with 2 updates (#1943)
- Dependency: Chore(deps): Bump the testing-dependencies group with 2 updates (#1941)
- Dependency: Chore: bump go-git and kind (#1977)
- Dependency: Fix: updatecli paths to community/prime clusterctl config files (#1889)
- Fleet: Chart: enable optional fetchConfig for fleet provider (#1734)
- Fleet: Chore: bump caapf to 0.12.0 (#1913)
- Import: Chore: Remove unsupported out of cluster feature (#1964)
- Import: Chore: rename import controller (#1973)
- Import: Fix: duplicate externally managed annotation value (#1886)
- Installation: Add cluster indexed label to all CRDs (#1749)
- Installation: Chore cleanup turtles chart provider refs (#1821)
- Installation: Chore: cleanup unused chart values `turtlesUI` and `rancherInstalled` (#1971)
- Installation: Feat: add fetch capi manifest workflow for air gapped (#1805)
- Installation: Feat: remove embedded capi (#1793)
- Installation: Remove ngrok operator for dev-env (#1906)
- Installation: Revert "Enable no-cert-manager by default" (#1792)
- Installation: Standratize helm chart values with other system charts (#1769)
- Kubeadm: Fix: Add kubeadm providers to image overrides list (#1946)
- MISSING_AREA: Add check for externalFleet annotation (#1868)
- MULTIPLE_AREAS[Build-and-release/Airgapped]: Fix: Prefix image repository with image registry for provider images (#1912)
- MULTIPLE_AREAS[Installation/Chart]: Enable no-cert-manager by default (#1784)
- MULTIPLE_AREAS[Testing/Capz]: Ci: bump k8s to 1.34 for Azure tests (#1863)
- Operator: [fix] Remove unnecessary finalizer wrapper from CAPIProvider (#1810)
- Operator: Remove clusterclass-operations from values.yaml (#1800)
- Operator: Remove day2 and clusterclass operations code (#1783)
- Providers: Fix: Add missing version annotations (#1984)
- Providers: Fix: Fix secret reference to Rancher cloud credential (#1982)
- Security: Bump Go to 1.24.11 to fix CVEs (#1988)
- Testing: Add gitea helpers back to e2e setup (#1851)
- Testing: E2E: Improvements to chart-upgrade suite tests (#1917)
- Testing: E2E: refactor Turtles chart-upgrade tests for system chart controller migration (#1881)
- Testing: Feat: add no-cert-manager e2e coverage (#1924)
- Testing: Fix unit test flake (#1897)
- Testing: Fix: Drop CAPRKE2 from expected set of default deployments (#1798)
- Testing: Switch from Turtles to embedded CAPI (#1953)
- Testing: Test: core capi bump on turtles upgrade (#1965)
- Ui: Feat: Allow customizing the rancher cluster description (#1969)

## Dependencies

### Added
_Nothing has changed._

### Changed
- github.com/onsi/ginkgo/v2: [v2.27.2 → v2.27.3](https://github.com/onsi/ginkgo/compare/v2.27.2...v2.27.3)
- github.com/onsi/gomega: [v1.38.2 → v1.38.3](https://github.com/onsi/gomega/compare/v1.38.2...v1.38.3)
- golang.org/x/mod: v0.29.0 → v0.30.0
- golang.org/x/sync: v0.18.0 → v0.19.0
- golang.org/x/telemetry: 078029d → bc8e575
- golang.org/x/text: v0.31.0 → v0.32.0
- golang.org/x/tools: v0.38.0 → v0.39.0

### Removed
_Nothing has changed._

</details>
<br/>
_Thanks to all our contributors!_ 😊
