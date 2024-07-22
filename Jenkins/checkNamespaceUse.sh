#!/bin/bash

namespace=$1
max_retries=12
delay_seconds=300

check_pods() {
    result=$(kubectl get pods -n "$namespace" 2>&1)
    if [[ "$result" == *"No resources found in $namespace namespace."* ]]; then
        return 0
    else
        return 1
    fi
}

retry_count=0
while ! check_pods && [ $retry_count -lt $max_retries ]; do
    echo "Pods are still present in the '$namespace' namespace. Waiting for 5 minutes before checking again..."
    sleep $delay_seconds
    retry_count=$((retry_count + 1))
done

if [ $retry_count -ge $max_retries ]; then
    echo "Pods are still present in the '$namespace' namespace after 1 hour of retries."
    exit 1
else
    echo "No resources found in '$namespace' namespace. Continuing the pipeline..."
    exit 0
fi
