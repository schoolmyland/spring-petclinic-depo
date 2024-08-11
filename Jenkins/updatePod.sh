#!/bin/bash

aws eks update-kubeconfig --region eu-west-3 --name $1
cp ~/.kube/config .kube/config


if [ $? -ne 0 ]; then
  echo "Contact to the cluster have fail"
  exit 2
fi

nameSpaces=($(kubectl get ns -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | grep '^petclinic-'))
for nameSpace in "${nameSpaces[@]}"; do
  podNames=($(kubectl get pods -n $nameSpace -o jsonpath='{.items[*].metadata.name}' --kubeconfig .kube/config | tr ' ' '\n' | grep "^$2"))
  for podName in "${podNames[@]}"; do
    if [ -n "$podName" ]; then
      echo "Deleting pod $podName in namespace $nameSpace"
      kubectl delete pod $podName -n $nameSpace --kubeconfig .kube/config
    else
      echo "No pod found matching $2 in namespace $nameSpace"
    fi
  done
done
