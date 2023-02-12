#!/bin/bash

source ./secrets_aks.sh
source ./config_aks.sh

echo "Creating Ingress controller"

NAMESPACE=ingress-basic

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

echo "Configuring ingress with external address ${CLUSTER_NAME}"ingress".${LOCATION}.cloudapp.azure.com"
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --create-namespace \
  --namespace $NAMESPACE \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-dns-label-name"=${CLUSTER_NAME}"ingress"  || exit 1

kubectl wait --namespace $NAMESPACE \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s || exit 1