#!/bin/bash
NAMESPACE="developpement"

PODS=$(kubectl get pods -n $NAMESPACE --no-headers -o custom-columns=":metadata.name,:status.phase,:status.containerStatuses[*].restartCount,:status.conditions[?(@.type=='Ready')].status,:status.containerStatuses[*].state.waiting.reason,:status.containerStatuses[*].state.terminated.reason")

RUNNING=$(echo "$PODS" | awk '$2 != "Running"')
RESTARTS=$(echo "$PODS" | awk '$3 != 0')
NOT_READY=$(echo "$PODS" | awk '$4 != "True"')

CHECK=true

if [ -n "$RUNNING" ]; then
    echo "$RUNNING" | awk '{print "Pod "$1" is in status "$2" with reason "($5?$5:$6)}'
    CHECK=false
fi
if [ -n "$RESTARTS" ]; then
    echo "$RESTARTS" | awk '{print "Pod "$1" has "$3" restarts!"}'
    RESTART_PODS=$(echo "$RESTARTS" | awk '{print $1}')
    for POD in $RESTART_PODS; do
        logFile="/opt/jenkins/logs/"$POD"-$(date +"%Y-%m-%d-%H-%M").log"
        echo "Logs for pod $POD :"
        kubectl logs $POD -n $NAMESPACE --previous > $logFile
        cat $logFile | grep 'Caused'
        echo "Full log in $logFile"
    done
    CHECK=false
fi
if [ -n "$NOT_READY" ]; then
    echo "$NOT_READY" | awk '{print "Pod "$1" is not ready."}'
    NOT_READY_PODS=$(echo "$NOT_READY" | awk '$3 == 0 {print $1}')
    for POD in $NOT_READY_PODS; do
        echo "Events for pod $POD:"
        kubectl describe pod $POD -n $NAMESPACE | awk '/Events:/,/^$/' | sed 's/^/  /'
    done
    CHECK=false
fi

if [ "$CHECK" = true ]; then
    echo "Check pods result : All pods are running."
else
    exit 1
fi
