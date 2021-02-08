## Released Assets

This folder contains Helm chart archives for `releaseCandidateVersions` of Helm charts contained within Packages whose `packageVersion` have already been released at charts.rancher.io.

On cutting a release, a Release Captain should run the corresponding `make release` command on this repository to move already released assets into this directory and update the index.yaml with the new chart locations.