🚨 This is a RELEASE CANDIDATE. Use it only for testing purposes. If you find any bugs, file an [issue](https://github.com/rancher/turtles/issues/new).
<details>
<summary>More details about the release</summary>

:warning: **RELEASE CANDIDATE NOTES** :warning:
## Highlights

* REPLACE ME

## Deprecation Warning

REPLACE ME: A couple sentences describing the deprecation, including links to docs.

* [GitHub issue #REPLACE ME](REPLACE ME)

## Changes since v0.25.0-rc.2
## :chart_with_upwards_trend: Overview
- 34 new commits merged

## :seedling: Others
- Build-and-release: Append target branch to backport PR title (#1768)

## :question: Sort these by hand
- Build-and-release: [main] fix: org value not set in release workflow (#1758)
- Build-and-release: Add backport automation GitHub workflow (#1754)
- Build-and-release: Chore(deps): Bump github/codeql-action from 3 to 4 (#1815)
- Build-and-release: Chore(deps): Bump rancher/aws-janitor from 0.2.0 to 0.3.0 (#1743)
- Build-and-release: Ci: Add attestation (#1730)
- Build-and-release: Cleanup release workflow and build action (#1755)
- Build-and-release: Docs: Add document for new release process (#1761)
- Build-and-release: Fix secret path for backport automation (#1757)
- Build-and-release: Fix: update nested imageVersion in values.yaml (#1747)
- Build-and-release: Use bash in release-against-rancher.sh for pushd/popd support (#1760)
- Build-and-release: Use proper path for backport secrets (#1765)
- Certificates: [feat] cert-manager to wrangler conversion (#1794)
- Chart: Bump rancher-version in chart.yaml (#1785)
- Chart: Chore: Drop CAPRKE2 and CAAPF templates from rancher-turtles chart (#1789)
- Chart: Correct Providers release-name (#1813)
- Chart: Fix: Change Turtles namespace to `cattle-turtles-system` (#1818)
- Dependency: Bump kubernetes version to v1.32.x series (#1787)
- Dependency: Chore(deps): Bump github.com/onsi/ginkgo/v2 from 2.25.3 to 2.26.0 in /test in the testing-dependencies group (#1801)
- Dependency: Chore(deps): Bump github.com/onsi/ginkgo/v2 from 2.25.3 to 2.26.0 in the testing-dependencies group (#1802)
- Dependency: Chore(deps): Bump golang.org/x/text from 0.29.0 to 0.30.0 in the other-dependencies group (#1814)
- Dependency: Chore(deps): Bump sigs.k8s.io/kind from 0.29.0 to 0.30.0 in /test in the other-dependencies group across 1 directory (#1751)
- Fleet: Chart: enable optional fetchConfig for fleet provider (#1734)
- Installation: Add cluster indexed label to all CRDs (#1749)
- Installation: Chore cleanup turtles chart provider refs (#1821)
- Installation: Feat: add fetch capi manifest workflow for air gapped (#1805)
- Installation: Feat: remove embedded capi (#1793)
- Installation: Revert "Enable no-cert-manager by default" (#1792)
- Installation: Standratize helm chart values with other system charts (#1769)
- MULTIPLE_AREAS[Installation/Chart]: Enable no-cert-manager by default (#1784)
- Operator: [fix] Remove unnecessary finalizer wrapper from CAPIProvider (#1810)
- Operator: Remove clusterclass-operations from values.yaml (#1800)
- Operator: Remove day2 and clusterclass operations code (#1783)
- Testing: Fix: Drop CAPRKE2 from expected set of default deployments (#1798)

## Dependencies

### Added
- github.com/gkampitakis/ciinfo: [v0.3.2](https://github.com/gkampitakis/ciinfo/tree/v0.3.2)
- github.com/gkampitakis/go-diff: [v1.3.2](https://github.com/gkampitakis/go-diff/tree/v1.3.2)
- github.com/gkampitakis/go-snaps: [v0.5.14](https://github.com/gkampitakis/go-snaps/tree/v0.5.14)
- github.com/goccy/go-yaml: [v1.18.0](https://github.com/goccy/go-yaml/tree/v1.18.0)
- github.com/joshdk/go-junit: [v1.0.0](https://github.com/joshdk/go-junit/tree/v1.0.0)
- github.com/maruel/natural: [v1.1.1](https://github.com/maruel/natural/tree/v1.1.1)
- github.com/mfridman/tparse: [v0.18.0](https://github.com/mfridman/tparse/tree/v0.18.0)
- github.com/tidwall/gjson: [v1.18.0](https://github.com/tidwall/gjson/tree/v1.18.0)
- github.com/tidwall/match: [v1.1.1](https://github.com/tidwall/match/tree/v1.1.1)
- github.com/tidwall/pretty: [v1.2.1](https://github.com/tidwall/pretty/tree/v1.2.1)
- github.com/tidwall/sjson: [v1.2.5](https://github.com/tidwall/sjson/tree/v1.2.5)

### Changed
- github.com/onsi/ginkgo/v2: [v2.25.3 → v2.26.0](https://github.com/onsi/ginkgo/compare/v2.25.3...v2.26.0)
- github.com/rogpeppe/go-internal: [v1.12.0 → v1.13.1](https://github.com/rogpeppe/go-internal/compare/v1.12.0...v1.13.1)
- golang.org/x/crypto: v0.41.0 → v0.42.0
- golang.org/x/mod: v0.27.0 → v0.28.0
- golang.org/x/net: v0.43.0 → v0.44.0
- golang.org/x/sys: v0.35.0 → v0.36.0
- golang.org/x/telemetry: 1a19826 → aef8a43
- golang.org/x/term: v0.34.0 → v0.35.0
- golang.org/x/text: v0.29.0 → v0.30.0
- golang.org/x/tools: v0.36.0 → v0.37.0

### Removed
_Nothing has changed._

</details>
<br/>
_Thanks to all our contributors!_ 😊
