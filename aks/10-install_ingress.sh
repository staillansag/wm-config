#!/bin/bash

source ./secrets_aks.sh
source ./config_aks.sh

echo "Creating Ingress controller"

NAMESPACE=ingress-basic

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

echo "Configuring ingress with external address ${DNS_LABEL_NAME}.${LOCATION}.cloudapp.azure.com"
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --create-namespace \
  --namespace $NAMESPACE \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-dns-label-name"=${DNS_LABEL_NAME}  || exit 1
