🚨 This is a RELEASE CANDIDATE. Use it only for testing purposes. If you find any bugs, file an [issue](https://github.com/rancher/turtles/issues/new).
<details>
<summary>More details about the release</summary>

:warning: **RELEASE CANDIDATE NOTES** :warning:
## Highlights

* REPLACE ME

## Deprecation Warning

REPLACE ME: A couple sentences describing the deprecation, including links to docs.

* [GitHub issue #REPLACE ME](REPLACE ME)

## Changes since v0.26.0-rc.0
## :chart_with_upwards_trend: Overview
- 4 new commits merged

## :question: Sort these by hand
- Capi: Feat: bump to capi v1.11.5 (#2044)
- Chart: Update upper bound for rancher-version annotation (#2051)
- Security: Chore: add new release branch format to codeql (#2058)
- Security: Chore: bump go to v1.24.13 (#2057)

## Dependencies

### Added
- github.com/envoyproxy/go-control-plane/envoy: [v1.32.4](https://github.com/envoyproxy/go-control-plane/tree/envoy/v1.32.4)
- github.com/envoyproxy/go-control-plane/ratelimit: [v0.1.0](https://github.com/envoyproxy/go-control-plane/tree/ratelimit/v0.1.0)
- github.com/go-jose/go-jose/v4: [v4.0.4](https://github.com/go-jose/go-jose/tree/v4.0.4)
- github.com/golang-jwt/jwt/v5: [v5.2.2](https://github.com/golang-jwt/jwt/tree/v5.2.2)
- github.com/grpc-ecosystem/go-grpc-middleware/providers/prometheus: [v1.0.1](https://github.com/grpc-ecosystem/go-grpc-middleware/tree/providers/prometheus/v1.0.1)
- github.com/grpc-ecosystem/go-grpc-middleware/v2: [v2.3.0](https://github.com/grpc-ecosystem/go-grpc-middleware/tree/v2.3.0)
- github.com/klauspost/compress: [v1.18.0](https://github.com/klauspost/compress/tree/v1.18.0)
- github.com/kylelemons/godebug: [v1.1.0](https://github.com/kylelemons/godebug/tree/v1.1.0)
- github.com/spiffe/go-spiffe/v2: [v2.5.0](https://github.com/spiffe/go-spiffe/tree/v2.5.0)
- github.com/zeebo/errs: [v1.4.0](https://github.com/zeebo/errs/tree/v1.4.0)
- go.etcd.io/raft/v3: v3.6.0
- go.opentelemetry.io/auto/sdk: v1.1.0
- go.uber.org/automaxprocs: v1.6.0
- gopkg.in/go-jose/go-jose.v2: v2.6.3
- sigs.k8s.io/structured-merge-diff/v6: v6.3.0

### Changed
- cel.dev/expr: v0.18.0 → v0.24.0
- dario.cat/mergo: v1.0.1 → v1.0.2
- github.com/GoogleCloudPlatform/opentelemetry-operations-go/detectors/gcp: [v1.25.0 → v1.26.0](https://github.com/GoogleCloudPlatform/opentelemetry-operations-go/compare/detectors/gcp/v1.25.0...detectors/gcp/v1.26.0)
- github.com/ProtonMail/go-crypto: [v1.0.0 → v1.1.6](https://github.com/ProtonMail/go-crypto/compare/v1.0.0...v1.1.6)
- github.com/cncf/xds/go: [b4127c9 → 2f00578](https://github.com/cncf/xds/compare/b4127c9...2f00578)
- github.com/coredns/corefile-migration: [v1.0.27 → v1.0.29](https://github.com/coredns/corefile-migration/compare/v1.0.27...v1.0.29)
- github.com/coreos/go-oidc: [v2.2.1+incompatible → v2.3.0+incompatible](https://github.com/coreos/go-oidc/compare/v2.2.1...v2.3.0)
- github.com/envoyproxy/go-control-plane: [v0.13.1 → v0.13.4](https://github.com/envoyproxy/go-control-plane/compare/v0.13.1...v0.13.4)
- github.com/envoyproxy/protoc-gen-validate: [v1.1.0 → v1.2.1](https://github.com/envoyproxy/protoc-gen-validate/compare/v1.1.0...v1.2.1)
- github.com/fsnotify/fsnotify: [v1.8.0 → v1.9.0](https://github.com/fsnotify/fsnotify/compare/v1.8.0...v1.9.0)
- github.com/fxamacker/cbor/v2: [v2.7.0 → v2.9.0](https://github.com/fxamacker/cbor/compare/v2.7.0...v2.9.0)
- github.com/golang/glog: [v1.2.2 → v1.2.4](https://github.com/golang/glog/compare/v1.2.2...v1.2.4)
- github.com/google/cel-go: [v0.22.0 → v0.26.0](https://github.com/google/cel-go/compare/v0.22.0...v0.26.0)
- github.com/google/gnostic-models: [c7be7c7 → v0.7.0](https://github.com/google/gnostic-models/compare/c7be7c7...v0.7.0)
- github.com/gorilla/websocket: [v1.5.3 → e064f32](https://github.com/gorilla/websocket/compare/v1.5.3...e064f32)
- github.com/grpc-ecosystem/grpc-gateway/v2: [v2.20.0 → v2.26.3](https://github.com/grpc-ecosystem/grpc-gateway/compare/v2.20.0...v2.26.3)
- github.com/jonboulle/clockwork: [v0.4.0 → v0.5.0](https://github.com/jonboulle/clockwork/compare/v0.4.0...v0.5.0)
- github.com/modern-go/reflect2: [v1.0.2 → 35a7c28](https://github.com/modern-go/reflect2/compare/v1.0.2...35a7c28)
- github.com/pmezard/go-difflib: [5d4384e → v1.0.0](https://github.com/pmezard/go-difflib/compare/5d4384e...v1.0.0)
- github.com/prometheus/client_golang: [v1.19.1 → v1.23.0](https://github.com/prometheus/client_golang/compare/v1.19.1...v1.23.0)
- github.com/prometheus/client_model: [v0.6.1 → v0.6.2](https://github.com/prometheus/client_model/compare/v0.6.1...v0.6.2)
- github.com/prometheus/common: [v0.55.0 → v0.65.0](https://github.com/prometheus/common/compare/v0.55.0...v0.65.0)
- github.com/prometheus/procfs: [v0.15.1 → v0.16.1](https://github.com/prometheus/procfs/compare/v0.15.1...v0.16.1)
- github.com/rogpeppe/go-internal: [v1.13.1 → v1.14.1](https://github.com/rogpeppe/go-internal/compare/v1.13.1...v1.14.1)
- github.com/spf13/cobra: [v1.9.1 → v1.10.1](https://github.com/spf13/cobra/compare/v1.9.1...v1.10.1)
- github.com/spf13/viper: [v1.20.0 → v1.20.1](https://github.com/spf13/viper/compare/v1.20.0...v1.20.1)
- github.com/stretchr/objx: [v0.5.0 → v0.5.2](https://github.com/stretchr/objx/compare/v0.5.0...v0.5.2)
- go.etcd.io/bbolt: v1.3.11 → v1.4.2
- go.etcd.io/etcd/api/v3: v3.5.20 → v3.6.4
- go.etcd.io/etcd/client/pkg/v3: v3.5.20 → v3.6.4
- go.etcd.io/etcd/client/v3: v3.5.20 → v3.6.4
- go.etcd.io/etcd/pkg/v3: v3.5.16 → v3.6.4
- go.etcd.io/etcd/server/v3: v3.5.16 → v3.6.4
- go.opentelemetry.io/contrib/detectors/gcp: v1.29.0 → v1.34.0
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
- golang.org/x/oauth2: v0.30.0 → v0.31.0
- golang.org/x/time: v0.8.0 → v0.9.0
- google.golang.org/genproto/googleapis/api: e6fa225 → 5a2f75b
- google.golang.org/genproto/googleapis/rpc: 3abc09e → 200df99
- google.golang.org/grpc: v1.67.3 → v1.72.2
- k8s.io/api: v0.32.7 → v0.34.1
- k8s.io/apiextensions-apiserver: v0.32.7 → v0.34.1
- k8s.io/apimachinery: v0.32.7 → v0.34.1
- k8s.io/apiserver: v0.32.7 → v0.34.1
- k8s.io/client-go: v0.32.7 → v0.34.1
- k8s.io/cluster-bootstrap: v0.32.3 → v0.33.3
- k8s.io/code-generator: v0.32.7 → v0.34.1
- k8s.io/component-base: v0.32.7 → v0.34.1
- k8s.io/gengo/v2: 2b36238 → 85fd79d
- k8s.io/kms: v0.32.7 → v0.34.1
- k8s.io/kube-openapi: 32ad38e → f3f2b99
- k8s.io/utils: 3ea5e8c → 4c0f3b2
- sigs.k8s.io/apiserver-network-proxy/konnectivity-client: v0.31.0 → v0.31.2
- sigs.k8s.io/cluster-api-operator: v0.23.1 → v0.24.1
- sigs.k8s.io/cluster-api: v1.10.6 → v1.11.5
- sigs.k8s.io/controller-runtime: v0.20.4 → v0.22.4
- sigs.k8s.io/json: 9aa6b5e → cfa47c3
- sigs.k8s.io/structured-merge-diff/v4: v4.4.2 → v4.6.0

### Removed
- github.com/antihax/optional: [v1.0.0](https://github.com/antihax/optional/tree/v1.0.0)
- github.com/asaskevich/govalidator: [a9d515a](https://github.com/asaskevich/govalidator/tree/a9d515a)
- github.com/cpuguy83/go-md2man/v2: [v2.0.6](https://github.com/cpuguy83/go-md2man/tree/v2.0.6)
- github.com/go-kit/log: [v0.2.1](https://github.com/go-kit/log/tree/v0.2.1)
- github.com/go-logfmt/logfmt: [v0.5.1](https://github.com/go-logfmt/logfmt/tree/v0.5.1)
- github.com/golang-jwt/jwt/v4: [v4.5.0](https://github.com/golang-jwt/jwt/tree/v4.5.0)
- github.com/grpc-ecosystem/go-grpc-middleware: [v1.3.0](https://github.com/grpc-ecosystem/go-grpc-middleware/tree/v1.3.0)
- github.com/grpc-ecosystem/grpc-gateway: [v1.16.0](https://github.com/grpc-ecosystem/grpc-gateway/tree/v1.16.0)
- github.com/matttproud/golang_protobuf_extensions: [v1.0.1](https://github.com/matttproud/golang_protobuf_extensions/tree/v1.0.1)
- github.com/rogpeppe/fastuuid: [v1.2.0](https://github.com/rogpeppe/fastuuid/tree/v1.2.0)
- github.com/russross/blackfriday/v2: [v2.1.0](https://github.com/russross/blackfriday/tree/v2.1.0)
- go.etcd.io/etcd/client/v2: v2.305.16
- go.etcd.io/etcd/raft/v3: v3.5.16
- gopkg.in/square/go-jose.v2: v2.6.0

</details>
<br/>
_Thanks to all our contributors!_ 😊
