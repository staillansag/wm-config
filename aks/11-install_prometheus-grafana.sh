#!/bin/bash

echo "Installing Prometheus and Grafana"

kubectl create -f monitoring/00_Monitoring_namespace.yaml || exit 1

kubectl create secret tls aks-tls --key="${TLS_PRIVATEKEY_FILE_PATH}" --cert="${TLS_PUBLICKEY_FILE_PATH}" -n monitoring  || exit 1

kubectl create -f monitoring/01_Prometheus_clusterRole.yaml || exit 1
kubectl create -f monitoring/02_Prometheus_configMap.yaml || exit 1
kubectl create -f monitoring/03_Prometheus_deployment.yaml || exit 1
kubectl create -f monitoring/04_Prometheus_service.yaml || exit 1 
kubectl create -f monitoring/11_Grafana_configMap.yaml || exit 1
kubectl create -f monitoring/12_Grafana_deployment.yaml || exit 1
kubectl create -f monitoring/13_Grafana_service.yaml || exit 1

if [ -n "${AKS_DOMAIN_NAME}" ]; then
    sed 's/example\.com/'${AKS_DOMAIN_NAME}'/g' ./monitoring/99_Monitoring_ingress.yml | kubectl create -f - || exit 1
fi
