#!/bin/bash
aws eks update-kubeconfig --region eu-west-3 --name $1

if [ $? -ne 0 ]; then
  echo "Contact to the cluster have failed "
  exit 2
fi
