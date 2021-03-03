#!/bin/bash
export KUBECONFIG=$1
for node in $(kubectl get nodes | awk '{print $1}' | tail -n +2)
do
	kubectl taint node $node node.cloudprovider.kubernetes.io/uninitialized=true:NoSchedule
done
