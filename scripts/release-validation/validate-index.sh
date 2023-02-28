#!/bin/bash

# Requires yq v4+
ROOT_DIR=../..
INDEX_PATH=$ROOT_DIR/index.yaml
ASSETS_PATH=$ROOT_DIR/assets

exclude=()

urls=$(yq e '.entries.*.[].urls' $INDEX_PATH | cut -d' ' -f2 )
# Check if every asset has a corresponding entry in the index.yaml
for asset in $(find $ASSETS_PATH -mindepth 2 -maxdepth 2 -name "*.tgz" | sed "s|^$ROOT_DIR/||" | xargs); do
  if printf '%s\n' "${exclude[@]}" | grep -F -x ${asset} 1>/dev/null; then
    echo "skipping ${asset}"
    continue
  fi
  if echo ${urls} | grep ${asset} 1>/dev/null; then
    echo "found ${asset}"
  else
    echo "MISSING ${asset}"
    break
  fi
done

# Check if every URL in index.yaml has a corresponding assets/ entry
for url in $(echo $urls | xargs); do
  if printf '%s\n' "${exclude[@]}" | grep -F -x ${url} 1>/dev/null; then
    echo "skipping ${url}"
    continue
  fi
  if [[ -f ${url} ]]; then
    echo "found ${url}"
    continue
  else
    echo "MISSING ${url}"
    break
  fi
done
