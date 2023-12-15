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

max_attempts=60
interval=5
ip_regex="^([0-9]{1,3}\.){3}[0-9]{1,3}$"
found_ip=false

for ((i=1; i<=max_attempts; i++)); do
    ip=$(kubectl get svc ingress-nginx-controller -n ingress-basic -o json | jq -r '.status.loadBalancer.ingress[0].ip')

    if [[ $ip =~ $ip_regex ]]; then
        echo "IP address $ip has been allocated."
        found_ip=true
        break
    else
        echo "Waiting for IP address allocation... (Attempt $i/$max_attempts)"
        sleep $interval
    fi
done

if [ "$found_ip" = false ]; then
    echo "Timed out waiting for IP address allocation." && exit 1
fi

if [ -n "${GANDI_PAT_TOKEN}" ] && [ -n "${AKS_DOMAIN_NAME}" ]; then
  echo "Updating DNS record ${AKS_CLUSTER_NAME}.sttlab.eu with A record pointing to ${ip}"
  echo "Gandi URL: https://api.gandi.net/v5/livedns/domains/sttlab.eu/records/${AKS_CLUSTER_NAME}/A"
  echo "Gandi payload: " '{"rrset_name": "'${AKS_CLUSTER_NAME}'","rrset_type": "A","rrset_ttl": 300,"rrset_values": ["'${ip}'"]}'
  curl -s -X PUT -H "Content-Type: application/json" \
      -H "Authorization: Bearer ${GANDI_PAT_TOKEN}" \
      -d '{"rrset_name": "'${AKS_CLUSTER_NAME}'","rrset_type": "A","rrset_ttl": 300,"rrset_values": ["'${ip}'"]}' \
      https://api.gandi.net/v5/livedns/domains/${AKS_DOMAIN_NAME}/records/${AKS_CLUSTER_NAME}/A || exit 1
fi


