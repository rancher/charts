#!/bin/bash

# Requires yq v4+
ROOT_DIR=../..
ASSETS_DIR=$ROOT_DIR/assets
INDEX_PATH=$ROOT_DIR/index.yaml
UPSTREAM_REMOTE=upstream
UPSTREAM_BRANCH=release-v2.9
OLD_UPSTREAM_BRANCH=release-v2.8

git fetch ${UPSTREAM_REMOTE}

# may need to use parenthesis instead of double quotes in some systems for it to work as an array
# requiredAnnotations="catalog.cattle.io/rancher-version catalog.cattle.io/kube-version catalog.cattle.io/permits-os"
declare -a requiredAnnotations=(catalog.cattle.io/rancher-version catalog.cattle.io/kube-version catalog.cattle.io/permits-os)

for asset in $(find $ASSETS_DIR -mindepth 2 -maxdepth 2 -name "*.tgz" | sort | xargs); do
  if printf '%s\n' "${exclude[@]}" | grep -F -x ${asset} 1>/dev/null; then
    echo "skipping ${asset}"
    continue
  fi

  if [[ $ROOT_DIR ]]; then
    chart=$ROOT_DIR/charts/$(basename ${asset} | sed 's/-\([0-9][-0-9\.a-z\+]*\).tgz/\/\1/' )
  else
    chart=charts/$(basename ${asset} | sed 's/-\([0-9][-0-9\.a-z\+]*\).tgz/\/\1/' )
  fi

  if git show ${UPSTREAM_REMOTE}/${UPSTREAM_BRANCH}:${chart} 1>/dev/null 2>/dev/null; then
    echo "Skipping checking annotation on already released chart ${chart}"
    continue
  fi

  chartname=$(echo ${chart#"$ROOT_DIR/"} | cut -d'/' -f2)
  chartversion=$(basename ${chart})
  exists_in_25=$(yq e ".entries.*.[] | select(.name == \"${chartname}\" and .version == \"${chartversion}\")" <(git show ${UPSTREAM_REMOTE}/${OLD_UPSTREAM_BRANCH}:${INDEX_PATH}))

  if [[ -n ${exists_in_25} ]]; then
    echo "Skipping checking annotation on forward-ported chart ${chart}"
    continue
  fi

  echo "Checking annotations on chart ${chart}"
  chartYaml=${chart}/Chart.yaml
  if ! [[ -f ${chartYaml} ]]; then
    echo "${chartYaml} does not exist"
    break
  fi
  chartName=$(echo ${chart#"$ROOT_DIR/"} | cut -d'/' -f2)
  chartVersion=$(echo ${chart#"$ROOT_DIR/"} | cut -d'/' -f3)
  for key in version appVersion annotations description icon kubeVersion; do
    chartContent=$(yq e ".${key}" ${chartYaml} | sort)
    indexContent=$(yq e ".entries.${chartName}[] | select(.version == \"${chartVersion}\" and .name == \"${chartName}\") | .${key}" ${INDEX_PATH} | sort)

    if [[ ${chartContent} != ${indexContent} ]]; then
      echo "ERROR: Contents of Chart.yaml for key '${key}' differs from index.yaml"
      echo ""
      echo "Expected:\n${chartContent}"
      echo "Found:\n${indexContent}"
      echo ""
    fi
    if [[ ${key} != "annotations" ]]; then
      continue
    fi
    for requiredAnnotation in "${requiredAnnotations[@]}"; do
      if echo ${chartContent} | grep "catalog.cattle.io/hidden" 1>/dev/null; then
        echo "Skipping checking annotation on chart with hidden annotation ${chart}"
        break
      fi
      if ! echo ${chartContent} | grep ${requiredAnnotation} 1>/dev/null; then
        echo "WARN: Chart.yaml missing '${requiredAnnotation}'"
      fi
    done
  done
done
