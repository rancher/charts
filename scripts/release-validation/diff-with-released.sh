#!/bin/bash

ROOT_DIR=../..
UPSTREAM_REMOTE=upstream
UPSTREAM_BRANCH=release-v2.6
OLD_CHART_DIR=$ROOT_DIR/charts
NEW_CHART_DIR=$ROOT_DIR/to-be-released

git fetch ${UPSTREAM_REMOTE}
mv $OLD_CHART_DIR $NEW_CHART_DIR
git checkout ${UPSTREAM_REMOTE}/${UPSTREAM_BRANCH} -- $OLD_CHART_DIR

rm -rf diffs_in_latest_version
mkdir -p diffs_in_latest_version

for chart in $(echo $(ls ${OLD_CHART_DIR}) $(ls ${NEW_CHART_DIR}) | tr " " "\n" | sort -u | xargs); do
    mkdir -p diffs_in_latest_version/${chart}
    if ! [[ -d ${OLD_CHART_DIR}/${chart} ]]; then
        touch diffs_in_latest_version/${chart}/new-chart.diff
        continue
    fi
    if ! [[ -d ${NEW_CHART_DIR}/${chart} ]]; then
        touch diffs_in_latest_version/${chart}/removed-chart.diff
        continue
    fi

    latest_chart_version=$(ls ${NEW_CHART_DIR}/${chart} | sort -Vr | head -n 1)
    prior_chart_version=$(ls ${OLD_CHART_DIR}/${chart} | sort -Vr | head -n 1)

    diff -uNr ${OLD_CHART_DIR}/${chart}/${prior_chart_version} ${NEW_CHART_DIR}/${chart}/${latest_chart_version} > diffs_in_latest_version/${chart}/${prior_chart_version}-to-${latest_chart_version}.diff
done

if [[ -d $NEW_CHART_DIR ]]; then
    rm -rf $NEW_CHART_DIR
    git checkout HEAD -- $OLD_CHART_DIR
fi
