#!/bin/bash
aws eks update-kubeconfig --region eu-west-3 --name $1

if [ $? -ne 0 ]; then
  echo "Contact to the cluster have failed "
  exit 2
fi

podName=$(kubectl get pods -n $2 -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | grep '^api-gateway')
if [ -z "$podName" ] || [[ "$podName" == *"resource(s) were provided, but no name was specified"* ]]; then
  echo "This customers doesn't have any namespace on our cloud"
  exit 0
fi

kubectl delete pod $podName -n $2
