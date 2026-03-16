🚨 This is a RELEASE CANDIDATE. Use it only for testing purposes. If you find any bugs, file an [issue](https://github.com/rancher/turtles/issues/new).
<details>
<summary>More details about the release</summary>

:warning: **RELEASE CANDIDATE NOTES** :warning:
## Highlights

* REPLACE ME

## Deprecation Warning

REPLACE ME: A couple sentences describing the deprecation, including links to docs.

* [GitHub issue #REPLACE ME](REPLACE ME)

## Changes since v0.26.0-rc.6
## :chart_with_upwards_trend: Overview
- 63 new commits merged

:book: Additionally, there has been 1 contribution to our documentation and book. (#2108) 

## :question: Sort these by hand
- API: Bump capi to v1.12.2 (#2079)
- Build-and-release: Auto-derive target branches from turtles release branch (#2153)
- Build-and-release: Bump actions/create-github-app-token from 2 to 3 (#2216)
- Build-and-release: Bump actions/setup-go from 6.2.0 to 6.3.0 (#2170)
- Build-and-release: Bump actions/upload-artifact from 6 to 7 (#2169)
- Build-and-release: Bump aquasecurity/trivy-action from 0.33.1 to 0.34.0 (#2117)
- Build-and-release: Bump aquasecurity/trivy-action from 0.34.0 to 0.34.1 (#2148)
- Build-and-release: Bump aquasecurity/trivy-action from 0.34.1 to 0.35.0 (#2188)
- Build-and-release: Bump docker/login-action from 3 to 4 (#2185)
- Build-and-release: Bump docker/setup-qemu-action from 3.7.0 to 4.0.0 (#2186)
- Build-and-release: Bump rancherlabs/slsactl from 0.1.17 to 0.1.18 (#2067)
- Build-and-release: Bump rancherlabs/slsactl from 0.1.18 to 0.1.19 (#2116)
- Build-and-release: Bump rancherlabs/slsactl from 0.1.19 to 0.1.21 (#2171)
- Build-and-release: Bump sigstore/cosign-installer from 4.0.0 to 4.1.0 (#2218)
- Build-and-release: Verify chart asset is always present after release upload step (#2141)
- Capa: Remove hostNetwork usage from AWS CSI chart (#2178)
- Capi: Bump to capi v1.11.5 (#2044)
- Capv: Update and fix vSphere CSI driver deployment (#2164)
- Chart: Make turtles a Rancher managed chart (i.e. not user upgradeable) (#2107)
- Chart: Update kubernetes versions in charts (#2105)
- Chart: Update upper bound for rancher-version annotation (#2051)
- CI: Bump e2e Rancher to v2.14.0-alpha3 (#2098)
- CI: Bump Rancher to v2.14.0-alpha9 (#2194)
- CI: Cleanup Rancher validation code (#2155)
- CI: Ignore artifact collection errors (#2165)
- CI: Remove v0.0.1-capi image load (#2112)
- CI: Use load balancer configmap from examples for Docker/RKE2 tests (#2182)
- ClusterClass/Capg: Use ClusterClass in e2e for GKE provisioning (#2177)
- Dependency: Bump github.com/caarlos0/env/v11 from 11.3.1 to 11.4.0 in /test in the other-dependencies group across 1 directory (#2150)
- Dependency: Bump github.com/cloudflare/circl from 1.6.1 to 1.6.3 (#2161)
- Dependency: Bump github.com/go-git/go-git/v5 from 5.16.4 to 5.16.5 in /test (#2077)
- Dependency: Bump github.com/go-git/go-git/v5 from 5.16.5 to 5.17.0 in /test in the other-dependencies group (#2172)
- Dependency: Bump go to 1.25.8 (#2195)
- Dependency: Bump go.opentelemetry.io/otel/sdk from 1.36.0 to 1.40.0 (#2168)
- Dependency: Bump golang.org/x/text from 0.33.0 to 0.34.0 in the other-dependencies group (#2115)
- Dependency: Bump the other-dependencies group in /test with 2 updates (#2118)
- Fleet/Providers: Bump CAAPF to v0.14.1 (#2196)
- Fleet: Override default fleet-agent metrics and health bind addresses (#2173)
- Import: Improve import controller deletion reconcile (#2062)
- Installation: Increase turtles pod memory limits (#2082)
- Operator: Bump cluster-api-operator to 0.26.0 (#2197)
- Operator: Ignore cert-manager CRDs not found (#2128)
- Operator: Reconcile wrangler cleanup earlier (#2110)
- Providers/Security: Bump caprke2 to v0.24.1 (#2208)
- Providers: Bump capa to v2.10.1 (#2151)
- Providers: Bump capg to v1.11.1 (#2201)
- Providers: Bump caprke2 to v0.23.1 (#2100)
- Providers: Bump caprke2 to v0.23.2 (#2163)
- Providers: Bump capv to v1.15.2 (#2089)
- Providers: Switch to aso crds for aks provisioning (#2166)
- Release: Move provider charts version setting as pre-requisites in the doc (#2139)
- Security: Add new release branch format to codeql (#2058)
- Security: Bump go to v1.24.13 (#2057)
- Testing: Align capi operator test version (#2220)
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
- github.com/cenkalti/backoff/v5: [v5.0.3](https://github.com/cenkalti/backoff/tree/v5.0.3)
- github.com/google/go-github/v82: [v82.0.0](https://github.com/google/go-github/tree/v82.0.0)

### Changed
- cel.dev/expr: v0.24.0 → v0.25.1
- github.com/cloudflare/circl: [v1.6.1 → v1.6.3](https://github.com/cloudflare/circl/compare/v1.6.1...v1.6.3)
- github.com/coredns/corefile-migration: [v1.0.29 → v1.0.30](https://github.com/coredns/corefile-migration/compare/v1.0.29...v1.0.30)
- github.com/google/go-querystring: [v1.1.0 → v1.2.0](https://github.com/google/go-querystring/compare/v1.1.0...v1.2.0)
- github.com/grpc-ecosystem/grpc-gateway/v2: [v2.26.3 → v2.28.0](https://github.com/grpc-ecosystem/grpc-gateway/compare/v2.26.3...v2.28.0)
- github.com/rogpeppe/go-internal: [v1.14.1 → v1.13.1](https://github.com/rogpeppe/go-internal/compare/v1.14.1...v1.13.1)
- github.com/spf13/cobra: [v1.10.1 → v1.10.2](https://github.com/spf13/cobra/compare/v1.10.1...v1.10.2)
- go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc: v1.34.0 → v1.41.0
- go.opentelemetry.io/otel/exporters/otlp/otlptrace: v1.34.0 → v1.41.0
- go.opentelemetry.io/otel/metric: v1.40.0 → v1.41.0
- go.opentelemetry.io/otel/sdk/metric: v1.40.0 → v1.35.0
- go.opentelemetry.io/otel/sdk: v1.40.0 → v1.41.0
- go.opentelemetry.io/otel/trace: v1.40.0 → v1.41.0
- go.opentelemetry.io/otel: v1.40.0 → v1.41.0
- go.opentelemetry.io/proto/otlp: v1.5.0 → v1.9.0
- golang.org/x/crypto: v0.47.0 → v0.48.0
- golang.org/x/net: v0.49.0 → v0.51.0
- golang.org/x/oauth2: v0.34.0 → v0.35.0
- golang.org/x/sys: v0.40.0 → v0.41.0
- golang.org/x/term: v0.39.0 → v0.40.0
- golang.org/x/text: v0.33.0 → v0.34.0
- google.golang.org/genproto/googleapis/api: 5a2f75b → 4cfbd41
- google.golang.org/genproto/googleapis/rpc: 200df99 → 4cfbd41
- google.golang.org/grpc: v1.72.3 → v1.79.1
- google.golang.org/protobuf: v1.36.7 → v1.36.11
- k8s.io/api: v0.34.3 → v0.34.5
- k8s.io/apiextensions-apiserver: v0.34.3 → v0.34.5
- k8s.io/apimachinery: v0.34.3 → v0.34.5
- k8s.io/apiserver: v0.34.3 → v0.34.5
- k8s.io/client-go: v0.34.3 → v0.34.5
- k8s.io/code-generator: v0.34.3 → v0.34.5
- k8s.io/component-base: v0.34.3 → v0.34.5
- k8s.io/kms: v0.34.3 → v0.34.5
- sigs.k8s.io/cluster-api-operator: v0.25.0 → v0.26.0
- sigs.k8s.io/cluster-api: v1.12.2 → v1.12.3

### Removed
- github.com/google/go-github/v52: [v52.0.0](https://github.com/google/go-github/tree/v52.0.0)

</details>
<br/>
_Thanks to all our contributors!_ 😊
