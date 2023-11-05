#!/bin/bash

echo "Creating Ingress controller"

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

echo "Configuring ingress with external address ${AKS_CLUSTER_NAME}"ingress".${AZ_LOCATION}.cloudapp.azure.com"
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --create-namespace \
  --namespace ingress-basic \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-dns-label-name"=${AKS_CLUSTER_NAME}"ingress"  || exit 1

kubectl wait --namespace ingress-basic \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s || exit 1