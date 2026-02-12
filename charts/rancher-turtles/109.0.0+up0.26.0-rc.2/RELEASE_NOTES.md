🚨 This is a RELEASE CANDIDATE. Use it only for testing purposes. If you find any bugs, file an [issue](https://github.com/rancher/turtles/issues/new).
<details>
<summary>More details about the release</summary>

:warning: **RELEASE CANDIDATE NOTES** :warning:
## Highlights

* REPLACE ME

## Deprecation Warning

REPLACE ME: A couple sentences describing the deprecation, including links to docs.

* [GitHub issue #REPLACE ME](REPLACE ME)

## Changes since v0.26.0-rc.1
## :chart_with_upwards_trend: Overview
- 13 new commits merged

## :question: Sort these by hand
- API: Bump capi to v1.12.2 (#2079)
- Build-and-release: Bump rancherlabs/slsactl from 0.1.17 to 0.1.18 (#2067)
- Capi: Bump to capi v1.11.5 (#2044)
- Chart: Update upper bound for rancher-version annotation (#2051)
- Dependency: Bump github.com/go-git/go-git/v5 from 5.16.4 to 5.16.5 in /test (#2077)
- Import: Improve import controller deletion reconcile (#2062)
- Installation: Increase turtles pod memory limits (#2082)
- Providers: Bump caprke2 to v0.23.1 (#2100)
- Providers: Bump capv to v1.15.2 (#2089)
- Security: Add new release branch format to codeql (#2058)
- Security: Bump go to v1.24.13 (#2057)
- Testing: Remove aso waiter (#2081)
- Testing: Remove capi bump test (#2083)

## Dependencies

### Added
- github.com/olekukonko/cat: [50322a0](https://github.com/olekukonko/cat/tree/50322a0)
- github.com/olekukonko/errors: [v1.1.0](https://github.com/olekukonko/errors/tree/v1.1.0)
- github.com/olekukonko/ll: [v0.1.1](https://github.com/olekukonko/ll/tree/v0.1.1)

### Changed
- cloud.google.com/go/compute/metadata: v0.6.0 → v0.3.0
- github.com/emicklei/go-restful/v3: [v3.12.2 → v3.13.0](https://github.com/emicklei/go-restful/compare/v3.12.2...v3.13.0)
- github.com/mattn/go-colorable: [v0.1.13 → v0.1.14](https://github.com/mattn/go-colorable/compare/v0.1.13...v0.1.14)
- github.com/mattn/go-runewidth: [v0.0.14 → v0.0.16](https://github.com/mattn/go-runewidth/compare/v0.0.14...v0.0.16)
- github.com/olekukonko/tablewriter: [v0.0.5 → v1.0.9](https://github.com/olekukonko/tablewriter/compare/v0.0.5...v1.0.9)
- github.com/pelletier/go-toml/v2: [v2.2.3 → v2.2.4](https://github.com/pelletier/go-toml/compare/v2.2.3...v2.2.4)
- github.com/rivo/uniseg: [v0.4.2 → v0.4.7](https://github.com/rivo/uniseg/compare/v0.4.2...v0.4.7)
- github.com/sagikazarmark/locafero: [v0.7.0 → v0.11.0](https://github.com/sagikazarmark/locafero/compare/v0.7.0...v0.11.0)
- github.com/sourcegraph/conc: [v0.3.0 → 5f936ab](https://github.com/sourcegraph/conc/compare/v0.3.0...5f936ab)
- github.com/spf13/afero: [v1.12.0 → v1.15.0](https://github.com/spf13/afero/compare/v1.12.0...v1.15.0)
- github.com/spf13/cast: [v1.7.1 → v1.10.0](https://github.com/spf13/cast/compare/v1.7.1...v1.10.0)
- github.com/spf13/viper: [v1.20.1 → v1.21.0](https://github.com/spf13/viper/compare/v1.20.1...v1.21.0)
- github.com/stretchr/testify: [v1.10.0 → v1.11.1](https://github.com/stretchr/testify/compare/v1.10.0...v1.11.1)
- go.etcd.io/etcd/api/v3: v3.6.4 → v3.6.6
- go.etcd.io/etcd/client/pkg/v3: v3.6.4 → v3.6.6
- go.etcd.io/etcd/client/v3: v3.6.4 → v3.6.6
- go.uber.org/zap: v1.27.0 → v1.27.1
- golang.org/x/oauth2: v0.31.0 → v0.34.0
- google.golang.org/grpc: v1.72.2 → v1.72.3
- k8s.io/api: v0.34.1 → v0.34.3
- k8s.io/apiextensions-apiserver: v0.34.1 → v0.34.3
- k8s.io/apimachinery: v0.34.1 → v0.34.3
- k8s.io/apiserver: v0.34.1 → v0.34.3
- k8s.io/client-go: v0.34.1 → v0.34.3
- k8s.io/cluster-bootstrap: v0.33.3 → v0.34.2
- k8s.io/code-generator: v0.34.1 → v0.34.3
- k8s.io/component-base: v0.34.1 → v0.34.3
- k8s.io/kms: v0.34.1 → v0.34.3
- sigs.k8s.io/cluster-api-operator: v0.24.1 → v0.25.0
- sigs.k8s.io/cluster-api: v1.11.5 → v1.12.2
- sigs.k8s.io/controller-runtime: v0.22.4 → v0.22.5

### Removed
- cloud.google.com/go/auth/oauth2adapt: v0.2.6
- cloud.google.com/go/auth: v0.13.0
- cloud.google.com/go/iam: v1.2.2
- cloud.google.com/go/monitoring: v1.21.2
- cloud.google.com/go/storage: v1.49.0
- cloud.google.com/go: v0.116.0
- github.com/GoogleCloudPlatform/opentelemetry-operations-go/detectors/gcp: [v1.26.0](https://github.com/GoogleCloudPlatform/opentelemetry-operations-go/tree/detectors/gcp/v1.26.0)
- github.com/GoogleCloudPlatform/opentelemetry-operations-go/exporter/metric: [v0.48.1](https://github.com/GoogleCloudPlatform/opentelemetry-operations-go/tree/exporter/metric/v0.48.1)
- github.com/GoogleCloudPlatform/opentelemetry-operations-go/internal/resourcemapping: [v0.48.1](https://github.com/GoogleCloudPlatform/opentelemetry-operations-go/tree/internal/resourcemapping/v0.48.1)
- github.com/census-instrumentation/opencensus-proto: [v0.4.1](https://github.com/census-instrumentation/opencensus-proto/tree/v0.4.1)
- github.com/cncf/xds/go: [2f00578](https://github.com/cncf/xds/tree/2f00578)
- github.com/envoyproxy/go-control-plane/envoy: [v1.32.4](https://github.com/envoyproxy/go-control-plane/tree/envoy/v1.32.4)
- github.com/envoyproxy/go-control-plane/ratelimit: [v0.1.0](https://github.com/envoyproxy/go-control-plane/tree/ratelimit/v0.1.0)
- github.com/envoyproxy/go-control-plane: [v0.13.4](https://github.com/envoyproxy/go-control-plane/tree/v0.13.4)
- github.com/envoyproxy/protoc-gen-validate: [v1.2.1](https://github.com/envoyproxy/protoc-gen-validate/tree/v1.2.1)
- github.com/go-jose/go-jose/v4: [v4.0.4](https://github.com/go-jose/go-jose/tree/v4.0.4)
- github.com/golang/glog: [v1.2.4](https://github.com/golang/glog/tree/v1.2.4)
- github.com/golang/groupcache: [41bb18b](https://github.com/golang/groupcache/tree/41bb18b)
- github.com/google/s2a-go: [v0.1.8](https://github.com/google/s2a-go/tree/v0.1.8)
- github.com/googleapis/enterprise-certificate-proxy: [v0.3.4](https://github.com/googleapis/enterprise-certificate-proxy/tree/v0.3.4)
- github.com/googleapis/gax-go/v2: [v2.14.1](https://github.com/googleapis/gax-go/tree/v2.14.1)
- github.com/kr/fs: [v0.1.0](https://github.com/kr/fs/tree/v0.1.0)
- github.com/pkg/sftp: [v1.13.7](https://github.com/pkg/sftp/tree/v1.13.7)
- github.com/planetscale/vtprotobuf: [0393e58](https://github.com/planetscale/vtprotobuf/tree/0393e58)
- github.com/spiffe/go-spiffe/v2: [v2.5.0](https://github.com/spiffe/go-spiffe/tree/v2.5.0)
- github.com/zeebo/errs: [v1.4.0](https://github.com/zeebo/errs/tree/v1.4.0)
- go.opencensus.io: v0.24.0
- go.opentelemetry.io/contrib/detectors/gcp: v1.34.0
- go.uber.org/atomic: v1.9.0
- go.uber.org/automaxprocs: v1.6.0
- google.golang.org/api: v0.215.0
- google.golang.org/genproto: e639e21
- sigs.k8s.io/structured-merge-diff/v4: v4.6.0

</details>
<br/>
_Thanks to all our contributors!_ 😊
