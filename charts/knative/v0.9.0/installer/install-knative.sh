#!/bin/sh
set -e

#kubectl create namespace knative-serving
#kubectl create namespace knative-build
#helm install --replace --wait ./knative

# Too many issues with helm, giving up

helm template ./knative -x templates/istio.yaml "$@" | kubectl apply -f - || echo "Errors expected at first run"
# Rerun due to issues with CRD timing, for example "no matches for config.istio.io/, Kind=rule"
helm template ./knative -x templates/istio.yaml "$@" | kubectl apply -f -

helm template ./knative -x templates/knative.yaml "$@" | kubectl apply -f -
