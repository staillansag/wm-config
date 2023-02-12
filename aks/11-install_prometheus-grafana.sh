#!/bin/bash

source ./secrets_aks.sh
source ./config_aks.sh

echo "Installing Prometheus and Grafana"

kubectl create -f monitoring/00_Monitoring_namespace.yaml || exit 1

kubectl create -f monitoring/01_Prometheus_clusterRole.yaml || exit 1
kubectl create -f monitoring/02_Prometheus_configMap.yaml || exit 1
kubectl create -f monitoring/03_Prometheus_deployment.yaml || exit 1
kubectl create -f monitoring/04_Prometheus_service.yaml || exit 1 
kubectl create -f monitoring/11_Grafana_configMap.yaml || exit 1
kubectl create -f monitoring/12_Grafana_deployment.yaml || exit 1
kubectl create -f monitoring/13_Grafana_service.yaml || exit 1

sed 's/example\.com/'${DOMAIN_NAME}'/g' ./monitoring/99_Monitoring_ingress.yml | kubectl create -f - || exit 1
