🚨 This is a RELEASE CANDIDATE. Use it only for testing purposes. If you find any bugs, file an [issue](https://github.com/rancher/turtles/issues/new).
<details>
<summary>More details about the release</summary>

:warning: **RELEASE CANDIDATE NOTES** :warning:
## Highlights

* REPLACE ME

## Deprecation Warning

REPLACE ME: A couple sentences describing the deprecation, including links to docs.

* [GitHub issue #REPLACE ME](REPLACE ME)

## Changes since v0.26.0-rc.5
## :chart_with_upwards_trend: Overview
- 49 new commits merged

:book: Additionally, there has been 1 contribution to our documentation and book. (#2108) 

## :question: Sort these by hand
- API: Bump capi to v1.12.2 (#2079)
- Build-and-release: Auto-derive target branches from turtles release branch (#2153)
- Build-and-release: Bump actions/setup-go from 6.2.0 to 6.3.0 (#2170)
- Build-and-release: Bump actions/upload-artifact from 6 to 7 (#2169)
- Build-and-release: Bump aquasecurity/trivy-action from 0.33.1 to 0.34.0 (#2117)
- Build-and-release: Bump aquasecurity/trivy-action from 0.34.0 to 0.34.1 (#2148)
- Build-and-release: Bump rancherlabs/slsactl from 0.1.17 to 0.1.18 (#2067)
- Build-and-release: Bump rancherlabs/slsactl from 0.1.18 to 0.1.19 (#2116)
- Build-and-release: Bump rancherlabs/slsactl from 0.1.19 to 0.1.21 (#2171)
- Build-and-release: Verify chart asset is always present after release upload step (#2141)
- Capa: Remove hostNetwork usage from AWS CSI chart (#2178)
- Capi: Bump to capi v1.11.5 (#2044)
- Capv: Update and fix vSphere CSI driver deployment (#2164)
- Chart: Make turtles a Rancher managed chart (i.e. not user upgradeable) (#2107)
- Chart: Update kubernetes versions in charts (#2105)
- Chart: Update upper bound for rancher-version annotation (#2051)
- CI: Bump e2e Rancher to v2.14.0-alpha3 (#2098)
- CI: Cleanup Rancher validation code (#2155)
- CI: Ignore artifact collection errors (#2165)
- CI: Remove v0.0.1-capi image load (#2112)
- Dependency: Bump github.com/caarlos0/env/v11 from 11.3.1 to 11.4.0 in /test in the other-dependencies group across 1 directory (#2150)
- Dependency: Bump github.com/cloudflare/circl from 1.6.1 to 1.6.3 (#2161)
- Dependency: Bump github.com/go-git/go-git/v5 from 5.16.4 to 5.16.5 in /test (#2077)
- Dependency: Bump github.com/go-git/go-git/v5 from 5.16.5 to 5.17.0 in /test in the other-dependencies group (#2172)
- Dependency: Bump go.opentelemetry.io/otel/sdk from 1.36.0 to 1.40.0 (#2168)
- Dependency: Bump golang.org/x/text from 0.33.0 to 0.34.0 in the other-dependencies group (#2115)
- Dependency: Bump the other-dependencies group in /test with 2 updates (#2118)
- Fleet: Override default fleet-agent metrics and health bind addresses (#2173)
- Import: Improve import controller deletion reconcile (#2062)
- Installation: Increase turtles pod memory limits (#2082)
- Operator: Ignore cert-manager CRDs not found (#2128)
- Operator: Reconcile wrangler cleanup earlier (#2110)
- Providers: Bump capa to v2.10.1 (#2151)
- Providers: Bump caprke2 to v0.23.1 (#2100)
- Providers: Bump caprke2 to v0.23.2 (#2163)
- Providers: Bump capv to v1.15.2 (#2089)
- Providers: Switch to aso crds for aks provisioning (#2166)
- Release: Move provider charts version setting as pre-requisites in the doc (#2139)
- Security: Add new release branch format to codeql (#2058)
- Security: Bump go to v1.24.13 (#2057)
- Testing: Conditionally install providers (#2157)
- Testing: Moving providers secrets creation to after installation of the providers chart (#2147)
- Testing: Remove aso waiter (#2081)
- Testing: Remove capi bump test (#2083)
- Testing: Remove provider migration (#2127)
- Testing: Remove switch from Turtles to embedded CAPI tests (#2136)
- Testing: Update e2e tests to use Traefik instead of Nginx (#2134)
- Testing: Update k8s version in testing cluster templates (#2090)

## Dependencies

### Added
_Nothing has changed._

### Changed
- github.com/cloudflare/circl: [v1.6.1 → v1.6.3](https://github.com/cloudflare/circl/compare/v1.6.1...v1.6.3)
- go.opentelemetry.io/auto/sdk: v1.1.0 → v1.2.1
- go.opentelemetry.io/otel/metric: v1.36.0 → v1.40.0
- go.opentelemetry.io/otel/sdk/metric: v1.35.0 → v1.40.0
- go.opentelemetry.io/otel/sdk: v1.36.0 → v1.40.0
- go.opentelemetry.io/otel/trace: v1.36.0 → v1.40.0
- go.opentelemetry.io/otel: v1.36.0 → v1.40.0
- golang.org/x/text: v0.33.0 → v0.34.0

### Removed
_Nothing has changed._

</details>
<br/>
_Thanks to all our contributors!_ 😊
