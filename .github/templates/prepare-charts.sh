#!/bin/bash
# TEMPLATE for one chart. Copy it into the repository of the chart, as
# .github/workflows/scripts/prepare-charts.sh, and adapt the four parts marked
# ADAPT to the chart. It does not work until the chart major is adapted. For the
# charts of a family, use prepare-charts-family.sh.
#
# It prepares the chart of a release for the ship-staged action of rancher/charts:
# it copies the chart to <output dir>/<chart>, sets the appVersion and the image
# tags in the copy to the release tag, and prints the chart version on stdout. The
# action stamps, checks, packages and pushes the copy, so the source of the chart
# stays as it is.
#
# The version of a chart is <chart major>.0.<patch of the tag>+up<version of the
# tag>, such as 110.0.3+up0.16.3 for the tag v0.16.3. Only the chart major is
# yours to adapt.
#
# Usage: prepare-charts.sh <tag> <output dir>
#   e.g. prepare-charts.sh v0.16.3 "$RUNNER_TEMP/charts"
#
# Run it from the root of the repository. In the workflow, after the checkout:
#
#   - name: Prepare the charts
#     id: prepare
#     env:
#       TAG: ${{ github.ref_name }}
#     run: |
#       version=$(./.github/workflows/scripts/prepare-charts.sh "$TAG" "$RUNNER_TEMP/charts")
#       echo "version=$version" >> "$GITHUB_OUTPUT"
#
#   - uses: rancher/charts/.github/actions/ship-staged@staging
#     with:
#       chart-dir: ${{ runner.temp }}/charts/<chart>
#       version: ${{ steps.prepare.outputs.version }}
set -euo pipefail

TAG=${1:?usage: $0 <tag> <output dir>}
OUT_DIR=${2:?usage: $0 <tag> <output dir>}

# ADAPT 1: the folder of the chart to release. The name of the chart is the last
# part of the folder.
CHART=charts/my-chart

# ADAPT 2: the shape of a release tag, and what is taken from it. APP_VERSION is
# the tag without the "v", and PATCH is the patch number.
if ! [[ "$TAG" =~ ^v([0-9]+)\.([0-9]+)\.([0-9]+)(-[0-9A-Za-z.]+)?$ ]]; then
  echo "Error: tag $TAG must look like vX.Y.Z or vX.Y.Z-rc.N" >&2
  exit 1
fi
PATCH="${BASH_REMATCH[3]}"
APP_VERSION="${TAG#v}"

# ADAPT 3: the chart major, the first number of the chart version. It follows
# the Rancher version the release is for, such as 110 for Rancher 2.15. Print it
# on stdout. It can be a fixed number, or read from a file of the repository, such
# as the table of versions in rancher/webhook (VERSION.md).
chart_major() {
  echo "Error: chart_major in $0 is not adapted: print the chart major of the release $TAG" >&2
  return 1
}

# ADAPT 4: what the charts take from the tag. stamp keeps the helm.sh/images
# annotation that Chart.yaml already has, refuses an image tagged "latest", and
# changes neither the appVersion nor the tags in values.yaml. Set them here in the
# copy, for every image of the charts.
set_release() {
  local dir=$1
  sed -i \
    -e "s|^appVersion:.*|appVersion: ${APP_VERSION}|" \
    -e "s|\(image: .*\):latest|\1:${TAG}|" \
    "$dir/Chart.yaml"
  sed -i -e "s|tag: latest|tag: ${TAG}|" "$dir/values.yaml"
}

CHART_MAJOR=$(chart_major)
if ! [[ "$CHART_MAJOR" =~ ^[0-9]+$ ]]; then
  echo "Error: the chart major must be a number (got '$CHART_MAJOR')" >&2
  exit 1
fi
CHART_VERSION="${CHART_MAJOR}.0.${PATCH}+up${APP_VERSION}"

if [ ! -f "$CHART/Chart.yaml" ]; then
  echo "Error: there is no Chart.yaml in $CHART" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"
dir="$OUT_DIR/$(basename "$CHART")"
rm -rf "$dir"
cp -r "$CHART" "$dir"
set_release "$dir"

echo "$CHART_VERSION"
