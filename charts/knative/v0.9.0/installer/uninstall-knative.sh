#!/bin/sh

helm template ./knative -x templates/knative.yaml | kubectl delete -f -
# Really?
#helm template ./knative -x templates/istio.yaml | kubectl delete -f -
