#!/bin/bash

Pwd_Grafana_admin=$1
value='./value.yaml'
config='./config.txt'
map='./configmap.yaml'

Services=("vets" "visits" "customers")


if [ -z "$Pwd_Grafana_admin" ]; then
    echo "Pwd_Grafana_admin is empty and no parameters set"
    exit 2
fi

if [ -z "$Bdd_Grafana_pwd" ] || [ -z "$Bdd_Grafana_user" ] || [ -z "$Bdd_Grafana_host" ] || [ -z "$Bdd_Grafana_name" ]; then
    echo "One of the BDD variable is missing to the env, export Bdd_Grafana_pwd, Bdd_Grafana_user, Bdd_Grafana_host or Bdd_Grafana_name !"
    exit 2
fi

nameSpaces=($(kubectl get ns -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | grep '^petclinic-'))

for nameSpace in "${nameSpaces[@]}"; do
  echo "" >> $config
  echo "      - job_name: petclinic-$nameSpace-api-gateway" >> $config
  echo "        metrics_path: /actuator/prometheus" >> $config
  echo "        static_configs:" >> $config
  echo "          - targets: ['api-gateway.$nameSpace.svc.cluster.local.:80']" >> $config
  for Service in "${Services[@]}"; do
    echo "" >> $config
    echo "      - job_name: $nameSpace-$Service-service" >> $config
    echo "        metrics_path: /actuator/prometheus" >> $config
    echo "        static_configs:" >> $config
    echo "          - targets: ['$Service-service.$nameSpace.svc.cluster.local.:8080']" >> $config
  done
done

helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring 
helm show values prometheus-community/kube-prometheus-stack -n monitoring > $value

#Parse the value file to set the target and the nodeSelector
sed -i "s/prom-operator/$Pwd_Grafana_admin/g" $value
lineNum=$(grep -n "additionalScrapeConfigs: \[\]" $value | cut -d: -f1)
sed -i "${lineNum}s/ \[\]//" $value
sed -i "$((lineNum+1))r $config" $value
search="      nodeSelector: {}"
replace="      nodeSelector:\n          nodetype: monitoring"
sed -i.bak "s|$search|$replace|" "$value"

helm upgrade prometheus prometheus-community/kube-prometheus-stack -n monitoring --values=$value 
#Set up the bdd into the configmap 
cp ./configmap-base.yaml ./$map
sed -i "s/BDD-HOSTNAME/$Bdd_Grafana_host/g" $map
sed -i "s/BDD-NAME/$Bdd_Grafana_name/g" $map
sed -i "s/BDD-USER/$Bdd_Grafana_user/g" $map
sed -i "s/BDD-PWD/$Bdd_Grafana_pwd/g" $map

sed -i "s/SMTP-HOST/$Smtp_Grafana_host/g" $map
sed -i "s/SMTP-MAIL/$Smtp_Grafana_mail/g" $map
sed -i "s/SMTP-MDP/$Smtp_Grafana_pwd/g" $map

kubectl apply -f ./$map 

rm $map
rm $value
rm $config

podName=$(kubectl get pods -n monitoring -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | grep '^prometheus-grafana-')
kubectl delete pod $podName -n monitoring  
kubectl apply -f ./front.yaml

