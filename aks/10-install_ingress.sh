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

ingressIp=$(kubectl get svc ingress-nginx-controller -n ingress-basic -o json | jq -r '.status.loadBalancer.ingress[0].ip')
echo "Ingress IP: ${ingressIp}"

echo "Updating DNS record ${AKS_CLUSTER_NAME}.sttlab.eu with A record pointing to ${ingressIp}"
curl -X PUT -H "Content-Type: application/json" \
     -H "Authorization: Bearer ${GANDI_PAT_TOKEN}" \
     -d '{"rrset_name": "${AKS_CLUSTER_NAME}","rrset_type": "A","rrset_ttl": 300,"rrset_values": ["${ingressIp}"]}' \
     https://api.gandi.net/v5/livedns/domains/sttlab.eu/records/${AKS_CLUSTER_NAME}/A || exit 1