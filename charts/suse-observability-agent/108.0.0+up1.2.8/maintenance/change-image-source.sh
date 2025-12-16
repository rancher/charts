#!/usr/bin/env bash
set -o pipefail

# shellcheck disable=SC2034
GREEN='\033[0;32m'
RED='\033[0;31m'
NO_COLOR='\033[0m'

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function usage() {
  cat <<EOF >&2
Change the registry and repository in the helm chart values file. This is meant as a pre-publishing step when the chart
gets published to an alternative repository.

Usage:
  $0 -g docker_registry -p docker_repository

Arguments:
    -g : Docker registry to change to
    -p : Docker repository to change to
    -h : Show this help text
EOF
}

# Parse options
while getopts ":g:p:h" opt; do
  case ${opt} in
    g)
        docker_registry_to=${OPTARG}
        ;;
    p)
        docker_repo_to=${OPTARG}
        ;;
    h)
      usage
      exit 0
      ;;
    :)
      echo -e "${RED}Option -${OPTARG} requires an argument.${NO_COLOR}" >&2
      usage
      exit 1
      ;;
    *)
      echo -e "${RED}Unimplemented option: -${OPTARG}${NO_COLOR}" >&2
      usage
      exit 1
      ;;
  esac
done

helm_chart_dir=$(realpath "$dir/..")

# Check if all required options are provided
if [[ -z "${docker_registry_to}" ]]; then
  echo -e "${RED}Error: -g option is required.${NO_COLOR}" >&2
  usage
  exit 1
fi

if [[ -z "${docker_repo_to}" ]]; then
  echo -e "${RED}Error: -p option is required.${NO_COLOR}" >&2
  usage
  exit 1
fi

function updateDockerImagesInValues() {
  echo "Reconfiguring container images registry in values.yaml"
  DOCKER_REGISTRY_TO="$docker_registry_to" yq -i -e  '.global.imageRegistry = env(DOCKER_REGISTRY_TO)' "$helm_chart_dir/values.yaml"
  sed -i -r "s|(\s+repository:\s+\"?)stackstate/|\1${docker_repo_to}/|g" "$helm_chart_dir/values.yaml"
}

updateDockerImagesInValues
