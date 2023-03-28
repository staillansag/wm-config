#!/bin/bash

source ./secrets_aks.sh
source ./config_aks.sh

echo "Creating global Kubernetes secrets"
kubectl create secret generic global-secrets \
	 --from-literal=elasticUser=${FLUENT_ELASTICSEARCH_USER} \
	 --from-literal=elasticPassword=${FLUENT_ELASTICSEARCH_PASSWORD}  || exit 1

echo "Creating environment specific Kubernetes secrets"
kubectl create secret generic environment-secrets \
	 --from-literal=databaseUser=${DB_USER} \
	 --from-literal=databasePassword=${DB_PASSWORD} \
         --from-literal=wmioIntegrationUser=${IO_INT_USER} \
         --from-literal=wmioIntegrationPassword=${IO_INT_PASSWORD} \
         --from-literal=apiGatewayUser=${API_GATEWAY_USER} \
         --from-literal=apiGatewayPassword=${API_GATEWAY_PASSWORD}