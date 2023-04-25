#!/bin/bash
ROOT_DIR=../..
CHART_DIR=$ROOT_DIR/charts
TO_BE_RELEASED=$ROOT_DIR/to-be-released
ALREADY_RELEASED=$ROOT_DIR/already-released
RELEASE_YAML_PATH=$ROOT_DIR/release.yaml

UPSTREAM_REMOTE=upstream
UPSTREAM_BRANCH=release-v2.6

git fetch ${UPSTREAM_REMOTE}
mv $CHART_DIR $TO_BE_RELEASED
git checkout ${UPSTREAM_REMOTE}/${UPSTREAM_BRANCH} -- $CHART_DIR
git reset HEAD 2>&1 1>/dev/null
mv $CHART_DIR $ALREADY_RELEASED
mv $TO_BE_RELEASED $CHART_DIR

for chart in $(ls ${CHART_DIR} | sort -u | xargs); do
    if [[ -d "$ALREADY_RELEASED/${chart}" ]]; then
        echo "Last released version: ${chart} $(ls $ALREADY_RELEASED/${chart} | sort -Vr | head -n 1)"
    else
        echo "Chart has never been released: ${chart}"
    fi
    entries=$(yq e "with_entries(select(.key == \"${chart}\"))" $RELEASE_YAML_PATH)
    if [[ $entries == "{}" ]]; then
        echo "NO ENTRIES in release.yaml"
        echo ""
    else
        echo "Entries in release.yaml:"
        echo "${entries}"
        echo ""
    fi
done

if [[ -d $ALREADY_RELEASED ]]; then
    rm -rf $ALREADY_RELEASED
fi
