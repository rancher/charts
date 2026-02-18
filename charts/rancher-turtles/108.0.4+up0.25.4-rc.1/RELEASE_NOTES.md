🚨 This is a RELEASE CANDIDATE. Use it only for testing purposes. If you find any bugs, file an [issue](https://github.com/rancher/turtles/issues/new).
<details>
<summary>More details about the release</summary>

:warning: **RELEASE CANDIDATE NOTES** :warning:
## Highlights

* REPLACE ME

## Deprecation Warning

REPLACE ME: A couple sentences describing the deprecation, including links to docs.

* [GitHub issue #REPLACE ME](REPLACE ME)

## Changes since v0.25.4-rc.0
## :chart_with_upwards_trend: Overview
- 164 new commits merged
- 1 bug fixed 🐛

## :bug: Bug Fixes
- Build-and-release: Fix: wrong github token value in core capi workflow (#1829)

## :seedling: Others
- Build-and-release: Append target branch to backport PR title (#1768)

:book: Additionally, there have been 6 contributions to our documentation and book. (#1865, #1870, #1873, #1887, #1937, #2108) 

## :question: Sort these by hand
- Airgapped: Fix: Add missing ASO provider image in values.yaml (#2020)
- Airgapped: Fix: Add provider images in values.yaml (#2019)
- Airgapped: Fix: use systemDefaultRegistry for chart shell image (#2034)
- API: Bump capi to v1.12.2 (#2079)
- API: Fix: Use CAPIProvider's name to select resources (#1918)
- Build-and-release: [main] fix: org value not set in release workflow (#1758)
- Build-and-release: Add backport automation GitHub workflow (#1754)
- Build-and-release: Chore(deps): Bump actions/checkout from 5 to 6 (#1910)
- Build-and-release: Chore(deps): Bump actions/checkout from 5.0.1 to 6.0.1 (#1925)
- Build-and-release: Chore(deps): Bump actions/checkout from 6.0.1 to 6.0.2 (#2023)
- Build-and-release: Chore(deps): Bump actions/setup-go from 6.0.0 to 6.1.0 (#1909)
- Build-and-release: Chore(deps): Bump actions/setup-go from 6.1.0 to 6.2.0 (#2006)
- Build-and-release: Chore(deps): Bump actions/upload-artifact from 4 to 5 (#1839)
- Build-and-release: Chore(deps): Bump actions/upload-artifact from 5 to 6 (#1940)
- Build-and-release: Chore(deps): Bump aquasecurity/trivy-action from 0.33.1 to 0.34.0 (#2117)
- Build-and-release: Chore(deps): Bump docker/setup-qemu-action from 3.6.0 to 3.7.0 (#1878)
- Build-and-release: Chore(deps): Bump github/codeql-action from 3 to 4 (#1815)
- Build-and-release: Chore(deps): Bump golangci/golangci-lint-action from 8 to 9 (#1876)
- Build-and-release: Chore(deps): Bump rancher/aws-janitor from 0.2.0 to 0.3.0 (#1743)
- Build-and-release: Chore(deps): Bump rancherlabs/slsactl from 0.0.15 to 0.0.16 (#1833)
- Build-and-release: Chore(deps): Bump rancherlabs/slsactl from 0.0.16 to 0.0.18 (#1840)
- Build-and-release: Chore(deps): Bump rancherlabs/slsactl from 0.0.18 to 0.1.1 (#1856)
- Build-and-release: Chore(deps): Bump rancherlabs/slsactl from 0.1.1 to 0.1.2 (#1875)
- Build-and-release: Chore(deps): Bump rancherlabs/slsactl from 0.1.11 to 0.1.12 (#1962)
- Build-and-release: Chore(deps): Bump rancherlabs/slsactl from 0.1.12 to 0.1.14 (#1993)
- Build-and-release: Chore(deps): Bump rancherlabs/slsactl from 0.1.14 to 0.1.15 (#2005)
- Build-and-release: Chore(deps): Bump rancherlabs/slsactl from 0.1.15 to 0.1.17 (#2024)
- Build-and-release: Chore(deps): Bump rancherlabs/slsactl from 0.1.17 to 0.1.18 (#2067)
- Build-and-release: Chore(deps): Bump rancherlabs/slsactl from 0.1.18 to 0.1.19 (#2116)
- Build-and-release: Chore(deps): Bump rancherlabs/slsactl from 0.1.2 to 0.1.6 (#1911)
- Build-and-release: Chore(deps): Bump rancherlabs/slsactl from 0.1.6 to 0.1.9 (#1921)
- Build-and-release: Chore(deps): Bump sigstore/cosign-installer from 3.10.0 to 4.0.0 (#1834)
- Build-and-release: Chore: bump slsactl to v0.1.11 (#1932)
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
- Build-and-release: Remove verbose file listing from git commit (#2049)
- Build-and-release: Use bash in release-against-rancher.sh for pushd/popd support (#1760)
- Build-and-release: Use proper path for backport secrets (#1765)
- Capi: Feat: bump to capi v1.11.5 (#2044)
- Caprke2: Providers: update CAPRKE2 to v0.21.1 (#1869)
- Certificates: [feat] cert-manager to wrangler conversion (#1794)
- Chart: Bump rancher-version in chart.yaml (#1785)
- Chart: Chore: Drop CAPRKE2 and CAAPF templates from rancher-turtles chart (#1789)
- Chart: Chore: update kubernetes versions in charts (#2105)
- Chart: Correct Providers release-name (#1813)
- Chart: Fix: Change `capi-system` namespace to `cattle-capi-system` (#1837)
- Chart: Fix: Change Turtles namespace to `cattle-turtles-system` (#1818)
- Chart: Fix: Make turtles a Rancher managed chart (i.e. not user upgradeable) (#2107)
- Chart: Fix: Set `securityContext` field to Turtles controller and hooks manifests (#1850)
- Chart: Remove Extension mentions from chart (#1871)
- Chart: Switch deprecated rancher/kubectl image to rancher/kuberlr-kubectl (#1895)
- Chart: Update upper bound for rancher-version annotation (#2051)
- CI: Bump e2e Rancher to v2.14.0-alpha3 (#2098)
- CI: Bump e2e to k8s 1.34 (#1872)
- CI: Bump Rancher to 2.13.0-rc1 and enable debug logging (#1896)
- CI: Chore: use Nodeports for dev-env ngrok tunnels (#2030)
- CI: CI fixes for vsphere (#1952)
- CI: Enable debug verbosity on e2e providers (#1891)
- CI: Feat: Install Turtles as system chart in dev-env (#1836)
- CI: Fix artifacts collection at the end of e2e tests (#1888)
- CI: Fix gitea ingress template (#1860)
- CI: Fix Rancher channel on dev-env script (#1899)
- CI: Fix: use 'gitea' namespace on test framework (#2047)
- CI: Install Turtles as system chart in all test suites (#1933)
- CI: Prevent flaky imported annotation removal (#1967)
- CI: Remove v0.0.1-capi image load (#2112)
- CI: Undeprecate DeployRancher method for stable Turtles deployments (#1966)
- CI: Use docker image for chart-testing cli (#1883)
- CI: Use Rancher v2.13 for e2e (#1843)
- CI: Wait for rancher-webhook before installing providers (#1846)
- CI: Wait for rancher-webhook when testing charts (#1853)
- Dependency: Bump CAPI operator patch version (#1905)
- Dependency: Bump kubernetes version to v1.32.x series (#1787)
- Dependency: Chore(deps): Bump github.com/go-git/go-git/v5 from 5.16.4 to 5.16.5 in /test (#2077)
- Dependency: Chore(deps): Bump github.com/onsi/ginkgo/v2 from 2.25.3 to 2.26.0 in /test in the testing-dependencies group (#1801)
- Dependency: Chore(deps): Bump github.com/onsi/ginkgo/v2 from 2.25.3 to 2.26.0 in the testing-dependencies group (#1802)
- Dependency: Chore(deps): Bump github.com/onsi/ginkgo/v2 from 2.26.0 to 2.27.1 in /test in the testing-dependencies group (#1842)
- Dependency: Chore(deps): Bump github.com/onsi/ginkgo/v2 from 2.26.0 to 2.27.1 in the testing-dependencies group (#1841)
- Dependency: Chore(deps): Bump github.com/onsi/ginkgo/v2 from 2.27.1 to 2.27.2 in the testing-dependencies group (#1857)
- Dependency: Chore(deps): Bump github.com/onsi/ginkgo/v2 from 2.27.4 to 2.27.5 in /test in the testing-dependencies group (#2007)
- Dependency: Chore(deps): Bump github.com/onsi/ginkgo/v2 from 2.27.4 to 2.27.5 in the testing-dependencies group (#2004)
- Dependency: Chore(deps): Bump golang.org/x/crypto from 0.42.0 to 0.45.0 (#1902)
- Dependency: Chore(deps): Bump golang.org/x/crypto from 0.42.0 to 0.45.0 in /test (#1901)
- Dependency: Chore(deps): Bump golang.org/x/text from 0.29.0 to 0.30.0 in the other-dependencies group (#1814)
- Dependency: Chore(deps): Bump golang.org/x/text from 0.31.0 to 0.32.0 in the other-dependencies group (#1942)
- Dependency: Chore(deps): Bump golang.org/x/text from 0.32.0 to 0.33.0 in the other-dependencies group (#1995)
- Dependency: Chore(deps): Bump golang.org/x/text from 0.33.0 to 0.34.0 in the other-dependencies group (#2115)
- Dependency: Chore(deps): Bump sigs.k8s.io/kind from 0.29.0 to 0.30.0 in /test in the other-dependencies group across 1 directory (#1751)
- Dependency: Chore(deps): Bump the other-dependencies group in /test with 2 updates (#2118)
- Dependency: Chore(deps): Bump the testing-dependencies group in /test with 2 updates (#1943)
- Dependency: Chore(deps): Bump the testing-dependencies group in /test with 2 updates (#1996)
- Dependency: Chore(deps): Bump the testing-dependencies group in /test with 2 updates (#2037)
- Dependency: Chore(deps): Bump the testing-dependencies group with 2 updates (#1941)
- Dependency: Chore(deps): Bump the testing-dependencies group with 2 updates (#1994)
- Dependency: Chore(deps): Bump the testing-dependencies group with 2 updates (#2038)
- Dependency: Chore: bump go-git and kind (#1977)
- Dependency: Fix: updatecli paths to community/prime clusterctl config files (#1889)
- Fleet: Chart: enable optional fetchConfig for fleet provider (#1734)
- Fleet: Chore: bump caapf to 0.12.0 (#1913)
- Import: [feat] Disable Rancher k8s version management for CAPI imported Clusters (#2011)
- Import: Chore: Remove migration to `clusters.management.cattle.io` (#1991)
- Import: Chore: Remove unsupported out of cluster feature (#1964)
- Import: Chore: rename import controller (#1973)
- Import: Fix: duplicate externally managed annotation value (#1886)
- Import: Fix: improve import controller deletion reconcile (#2062)
- Installation: Add cluster indexed label to all CRDs (#1749)
- Installation: Chore cleanup turtles chart provider refs (#1821)
- Installation: Chore: cleanup unused chart values `turtlesUI` and `rancherInstalled` (#1971)
- Installation: Feat: add fetch capi manifest workflow for air gapped (#1805)
- Installation: Feat: remove embedded capi (#1793)
- Installation: Increase turtles pod memory limits (#2082)
- Installation: Make delete hooks do a full cleanup (#2027)
- Installation: Remove ngrok operator for dev-env (#1906)
- Installation: Revert "Enable no-cert-manager by default" (#1792)
- Installation: Standratize helm chart values with other system charts (#1769)
- Kubeadm: Fix: Add kubeadm providers to image overrides list (#1946)
- MISSING_AREA: Add check for externalFleet annotation (#1868)
- MULTIPLE_AREAS[Build-and-release/Airgapped]: Fix: Prefix image repository with image registry for provider images (#1912)
- MULTIPLE_AREAS[Build-and-release/Release]: Ci: Add attestation (#1730)
- MULTIPLE_AREAS[Installation/Chart]: Enable no-cert-manager by default (#1784)
- MULTIPLE_AREAS[Testing/Capz]: Ci: bump k8s to 1.34 for Azure tests (#1863)
- Operator: [fix] Remove unnecessary finalizer wrapper from CAPIProvider (#1810)
- Operator: Fix: ignore cert-manager CRDs not found (#2128)
- Operator: Fix: reconcile wrangler cleanup earlier (#2110)
- Operator: Remove clusterclass-operations from values.yaml (#1800)
- Operator: Remove day2 and clusterclass operations code (#1783)
- Providers: Chore: bump caprke2 to v0.23.1 (#2100)
- Providers: Chore: bump capv to v1.15.2 (#2089)
- Providers: Fix: Add missing version annotations (#1984)
- Providers: Fix: Fix secret reference to Rancher cloud credential (#1982)
- Security: Add FOSSA scanning workflow (#2001)
- Security: Bump Go to 1.24.11 to fix CVEs (#1988)
- Security: Chore: add new release branch format to codeql (#2058)
- Security: Chore: bump go to v1.24.13 (#2057)
- Security: Fix: Bump Go version to address CVEs (#2042)
- Testing: Add gitea helpers back to e2e setup (#1851)
- Testing: E2E: Improvements to chart-upgrade suite tests (#1917)
- Testing: E2E: refactor Turtles chart-upgrade tests for system chart controller migration (#1881)
- Testing: Feat: add no-cert-manager e2e coverage (#1924)
- Testing: Fix unit test flake (#1897)
- Testing: Fix: Drop CAPRKE2 from expected set of default deployments (#1798)
- Testing: Switch from Turtles to embedded CAPI (#1953)
- Testing: Test: core capi bump on turtles upgrade (#1965)
- Testing: Test: remove aso waiter (#2081)
- Testing: Test: remove capi bump test (#2083)
- Ui: Feat: Allow customizing the rancher cluster description (#1969)
- Vsphere: CI: get IP for vsphere runner dynamically (#2000)

## Dependencies

### Added
- github.com/golang-jwt/jwt/v5: [v5.2.2](https://github.com/golang-jwt/jwt/tree/v5.2.2)
- github.com/grpc-ecosystem/go-grpc-middleware/providers/prometheus: [v1.0.1](https://github.com/grpc-ecosystem/go-grpc-middleware/tree/providers/prometheus/v1.0.1)
- github.com/grpc-ecosystem/go-grpc-middleware/v2: [v2.3.0](https://github.com/grpc-ecosystem/go-grpc-middleware/tree/v2.3.0)
- github.com/klauspost/compress: [v1.18.0](https://github.com/klauspost/compress/tree/v1.18.0)
- github.com/kylelemons/godebug: [v1.1.0](https://github.com/kylelemons/godebug/tree/v1.1.0)
- github.com/olekukonko/cat: [50322a0](https://github.com/olekukonko/cat/tree/50322a0)
- github.com/olekukonko/errors: [v1.1.0](https://github.com/olekukonko/errors/tree/v1.1.0)
- github.com/olekukonko/ll: [v0.1.1](https://github.com/olekukonko/ll/tree/v0.1.1)
- go.etcd.io/raft/v3: v3.6.0
- go.opentelemetry.io/auto/sdk: v1.1.0
- gopkg.in/go-jose/go-jose.v2: v2.6.3
- sigs.k8s.io/structured-merge-diff/v6: v6.3.0

### Changed
- cel.dev/expr: v0.18.0 → v0.24.0
- cloud.google.com/go/compute/metadata: v0.6.0 → v0.3.0
- dario.cat/mergo: v1.0.1 → v1.0.2
- github.com/ProtonMail/go-crypto: [v1.0.0 → v1.1.6](https://github.com/ProtonMail/go-crypto/compare/v1.0.0...v1.1.6)
- github.com/coredns/corefile-migration: [v1.0.27 → v1.0.29](https://github.com/coredns/corefile-migration/compare/v1.0.27...v1.0.29)
- github.com/coreos/go-oidc: [v2.2.1+incompatible → v2.3.0+incompatible](https://github.com/coreos/go-oidc/compare/v2.2.1...v2.3.0)
- github.com/emicklei/go-restful/v3: [v3.12.2 → v3.13.0](https://github.com/emicklei/go-restful/compare/v3.12.2...v3.13.0)
- github.com/fsnotify/fsnotify: [v1.8.0 → v1.9.0](https://github.com/fsnotify/fsnotify/compare/v1.8.0...v1.9.0)
- github.com/fxamacker/cbor/v2: [v2.7.0 → v2.9.0](https://github.com/fxamacker/cbor/compare/v2.7.0...v2.9.0)
- github.com/google/cel-go: [v0.22.0 → v0.26.0](https://github.com/google/cel-go/compare/v0.22.0...v0.26.0)
- github.com/google/gnostic-models: [c7be7c7 → v0.7.0](https://github.com/google/gnostic-models/compare/c7be7c7...v0.7.0)
- github.com/google/pprof: [f64d9cf → 294ebfa](https://github.com/google/pprof/compare/f64d9cf...294ebfa)
- github.com/gorilla/websocket: [v1.5.3 → e064f32](https://github.com/gorilla/websocket/compare/v1.5.3...e064f32)
- github.com/grpc-ecosystem/grpc-gateway/v2: [v2.20.0 → v2.26.3](https://github.com/grpc-ecosystem/grpc-gateway/compare/v2.20.0...v2.26.3)
- github.com/jonboulle/clockwork: [v0.4.0 → v0.5.0](https://github.com/jonboulle/clockwork/compare/v0.4.0...v0.5.0)
- github.com/mattn/go-colorable: [v0.1.13 → v0.1.14](https://github.com/mattn/go-colorable/compare/v0.1.13...v0.1.14)
- github.com/mattn/go-runewidth: [v0.0.14 → v0.0.16](https://github.com/mattn/go-runewidth/compare/v0.0.14...v0.0.16)
- github.com/modern-go/reflect2: [v1.0.2 → 35a7c28](https://github.com/modern-go/reflect2/compare/v1.0.2...35a7c28)
- github.com/olekukonko/tablewriter: [v0.0.5 → v1.0.9](https://github.com/olekukonko/tablewriter/compare/v0.0.5...v1.0.9)
- github.com/onsi/ginkgo/v2: [v2.27.3 → v2.28.1](https://github.com/onsi/ginkgo/compare/v2.27.3...v2.28.1)
- github.com/onsi/gomega: [v1.38.3 → v1.39.1](https://github.com/onsi/gomega/compare/v1.38.3...v1.39.1)
- github.com/pelletier/go-toml/v2: [v2.2.3 → v2.2.4](https://github.com/pelletier/go-toml/compare/v2.2.3...v2.2.4)
- github.com/pmezard/go-difflib: [5d4384e → v1.0.0](https://github.com/pmezard/go-difflib/compare/5d4384e...v1.0.0)
- github.com/prometheus/client_golang: [v1.19.1 → v1.23.0](https://github.com/prometheus/client_golang/compare/v1.19.1...v1.23.0)
- github.com/prometheus/client_model: [v0.6.1 → v0.6.2](https://github.com/prometheus/client_model/compare/v0.6.1...v0.6.2)
- github.com/prometheus/common: [v0.55.0 → v0.65.0](https://github.com/prometheus/common/compare/v0.55.0...v0.65.0)
- github.com/prometheus/procfs: [v0.15.1 → v0.16.1](https://github.com/prometheus/procfs/compare/v0.15.1...v0.16.1)
- github.com/rivo/uniseg: [v0.4.2 → v0.4.7](https://github.com/rivo/uniseg/compare/v0.4.2...v0.4.7)
- github.com/rogpeppe/go-internal: [v1.13.1 → v1.14.1](https://github.com/rogpeppe/go-internal/compare/v1.13.1...v1.14.1)
- github.com/sagikazarmark/locafero: [v0.7.0 → v0.11.0](https://github.com/sagikazarmark/locafero/compare/v0.7.0...v0.11.0)
- github.com/sourcegraph/conc: [v0.3.0 → 5f936ab](https://github.com/sourcegraph/conc/compare/v0.3.0...5f936ab)
- github.com/spf13/afero: [v1.12.0 → v1.15.0](https://github.com/spf13/afero/compare/v1.12.0...v1.15.0)
- github.com/spf13/cast: [v1.7.1 → v1.10.0](https://github.com/spf13/cast/compare/v1.7.1...v1.10.0)
- github.com/spf13/cobra: [v1.9.1 → v1.10.1](https://github.com/spf13/cobra/compare/v1.9.1...v1.10.1)
- github.com/spf13/viper: [v1.20.0 → v1.21.0](https://github.com/spf13/viper/compare/v1.20.0...v1.21.0)
- github.com/stretchr/objx: [v0.5.0 → v0.5.2](https://github.com/stretchr/objx/compare/v0.5.0...v0.5.2)
- github.com/stretchr/testify: [v1.10.0 → v1.11.1](https://github.com/stretchr/testify/compare/v1.10.0...v1.11.1)
- go.etcd.io/bbolt: v1.3.11 → v1.4.2
- go.etcd.io/etcd/api/v3: v3.5.20 → v3.6.6
- go.etcd.io/etcd/client/pkg/v3: v3.5.20 → v3.6.6
- go.etcd.io/etcd/client/v3: v3.5.20 → v3.6.6
- go.etcd.io/etcd/pkg/v3: v3.5.16 → v3.6.4
- go.etcd.io/etcd/server/v3: v3.5.16 → v3.6.4
- go.opentelemetry.io/contrib/instrumentation/google.golang.org/grpc/otelgrpc: v0.54.0 → v0.60.0
- go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp: v0.54.0 → v0.60.0
- go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc: v1.27.0 → v1.34.0
- go.opentelemetry.io/otel/exporters/otlp/otlptrace: v1.28.0 → v1.34.0
- go.opentelemetry.io/otel/metric: v1.29.0 → v1.36.0
- go.opentelemetry.io/otel/sdk/metric: v1.29.0 → v1.35.0
- go.opentelemetry.io/otel/sdk: v1.29.0 → v1.36.0
- go.opentelemetry.io/otel/trace: v1.29.0 → v1.36.0
- go.opentelemetry.io/otel: v1.29.0 → v1.36.0
- go.opentelemetry.io/proto/otlp: v1.3.1 → v1.5.0
- go.uber.org/zap: v1.27.0 → v1.27.1
- golang.org/x/crypto: v0.45.0 → v0.47.0
- golang.org/x/mod: v0.30.0 → v0.32.0
- golang.org/x/net: v0.47.0 → v0.49.0
- golang.org/x/oauth2: v0.30.0 → v0.34.0
- golang.org/x/sys: v0.38.0 → v0.40.0
- golang.org/x/telemetry: bc8e575 → bd525da
- golang.org/x/term: v0.37.0 → v0.39.0
- golang.org/x/text: v0.32.0 → v0.34.0
- golang.org/x/time: v0.8.0 → v0.9.0
- golang.org/x/tools: v0.39.0 → v0.41.0
- google.golang.org/genproto/googleapis/api: e6fa225 → 5a2f75b
- google.golang.org/genproto/googleapis/rpc: 3abc09e → 200df99
- google.golang.org/grpc: v1.67.3 → v1.72.3
- k8s.io/api: v0.32.7 → v0.34.3
- k8s.io/apiextensions-apiserver: v0.32.7 → v0.34.3
- k8s.io/apimachinery: v0.32.7 → v0.34.3
- k8s.io/apiserver: v0.32.7 → v0.34.3
- k8s.io/client-go: v0.32.7 → v0.34.3
- k8s.io/cluster-bootstrap: v0.32.3 → v0.34.2
- k8s.io/code-generator: v0.32.7 → v0.34.3
- k8s.io/component-base: v0.32.7 → v0.34.3
- k8s.io/gengo/v2: 2b36238 → 85fd79d
- k8s.io/kms: v0.32.7 → v0.34.3
- k8s.io/kube-openapi: 32ad38e → f3f2b99
- k8s.io/utils: 3ea5e8c → 4c0f3b2
- sigs.k8s.io/apiserver-network-proxy/konnectivity-client: v0.31.0 → v0.31.2
- sigs.k8s.io/cluster-api-operator: v0.23.1 → v0.25.0
- sigs.k8s.io/cluster-api: v1.10.6 → v1.12.2
- sigs.k8s.io/controller-runtime: v0.20.4 → v0.22.5
- sigs.k8s.io/json: 9aa6b5e → cfa47c3

### Removed
- cloud.google.com/go/auth/oauth2adapt: v0.2.6
- cloud.google.com/go/auth: v0.13.0
- cloud.google.com/go/iam: v1.2.2
- cloud.google.com/go/monitoring: v1.21.2
- cloud.google.com/go/storage: v1.49.0
- cloud.google.com/go: v0.116.0
- github.com/GoogleCloudPlatform/opentelemetry-operations-go/detectors/gcp: [v1.25.0](https://github.com/GoogleCloudPlatform/opentelemetry-operations-go/tree/detectors/gcp/v1.25.0)
- github.com/GoogleCloudPlatform/opentelemetry-operations-go/exporter/metric: [v0.48.1](https://github.com/GoogleCloudPlatform/opentelemetry-operations-go/tree/exporter/metric/v0.48.1)
- github.com/GoogleCloudPlatform/opentelemetry-operations-go/internal/resourcemapping: [v0.48.1](https://github.com/GoogleCloudPlatform/opentelemetry-operations-go/tree/internal/resourcemapping/v0.48.1)
- github.com/antihax/optional: [v1.0.0](https://github.com/antihax/optional/tree/v1.0.0)
- github.com/asaskevich/govalidator: [a9d515a](https://github.com/asaskevich/govalidator/tree/a9d515a)
- github.com/census-instrumentation/opencensus-proto: [v0.4.1](https://github.com/census-instrumentation/opencensus-proto/tree/v0.4.1)
- github.com/cncf/xds/go: [b4127c9](https://github.com/cncf/xds/tree/b4127c9)
- github.com/cpuguy83/go-md2man/v2: [v2.0.6](https://github.com/cpuguy83/go-md2man/tree/v2.0.6)
- github.com/envoyproxy/go-control-plane: [v0.13.1](https://github.com/envoyproxy/go-control-plane/tree/v0.13.1)
- github.com/envoyproxy/protoc-gen-validate: [v1.1.0](https://github.com/envoyproxy/protoc-gen-validate/tree/v1.1.0)
- github.com/go-kit/log: [v0.2.1](https://github.com/go-kit/log/tree/v0.2.1)
- github.com/go-logfmt/logfmt: [v0.5.1](https://github.com/go-logfmt/logfmt/tree/v0.5.1)
- github.com/golang-jwt/jwt/v4: [v4.5.0](https://github.com/golang-jwt/jwt/tree/v4.5.0)
- github.com/golang/glog: [v1.2.2](https://github.com/golang/glog/tree/v1.2.2)
- github.com/golang/groupcache: [41bb18b](https://github.com/golang/groupcache/tree/41bb18b)
- github.com/google/s2a-go: [v0.1.8](https://github.com/google/s2a-go/tree/v0.1.8)
- github.com/googleapis/enterprise-certificate-proxy: [v0.3.4](https://github.com/googleapis/enterprise-certificate-proxy/tree/v0.3.4)
- github.com/googleapis/gax-go/v2: [v2.14.1](https://github.com/googleapis/gax-go/tree/v2.14.1)
- github.com/grpc-ecosystem/go-grpc-middleware: [v1.3.0](https://github.com/grpc-ecosystem/go-grpc-middleware/tree/v1.3.0)
- github.com/grpc-ecosystem/grpc-gateway: [v1.16.0](https://github.com/grpc-ecosystem/grpc-gateway/tree/v1.16.0)
- github.com/kr/fs: [v0.1.0](https://github.com/kr/fs/tree/v0.1.0)
- github.com/matttproud/golang_protobuf_extensions: [v1.0.1](https://github.com/matttproud/golang_protobuf_extensions/tree/v1.0.1)
- github.com/pkg/sftp: [v1.13.7](https://github.com/pkg/sftp/tree/v1.13.7)
- github.com/planetscale/vtprotobuf: [0393e58](https://github.com/planetscale/vtprotobuf/tree/0393e58)
- github.com/rogpeppe/fastuuid: [v1.2.0](https://github.com/rogpeppe/fastuuid/tree/v1.2.0)
- github.com/russross/blackfriday/v2: [v2.1.0](https://github.com/russross/blackfriday/tree/v2.1.0)
- go.etcd.io/etcd/client/v2: v2.305.16
- go.etcd.io/etcd/raft/v3: v3.5.16
- go.opencensus.io: v0.24.0
- go.opentelemetry.io/contrib/detectors/gcp: v1.29.0
- go.uber.org/atomic: v1.9.0
- go.uber.org/automaxprocs: v1.6.0
- google.golang.org/api: v0.215.0
- google.golang.org/genproto: e639e21
- gopkg.in/square/go-jose.v2: v2.6.0
- sigs.k8s.io/structured-merge-diff/v4: v4.4.2

</details>
<br/>
_Thanks to all our contributors!_ 😊
