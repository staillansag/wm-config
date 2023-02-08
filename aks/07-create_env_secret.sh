#!/bin/bash

source ./secrets.sh
source ./config.sh

echo "Creating environment specific Kubernetes secrets"
kubectl create secret generic environment-secrets \
	 --from-literal=databaseUser=${DB_USER} \
	 --from-literal=databasePassword=${DB_PASSWORD} \
         --from-literal=wmioIntegrationUser=${IO_INT_USER} \
         --from-literal=wmioIntegrationPlaygroundUser=${IO_INT_PLAYGROUND_USER} \
         --from-literal=wmioIntegrationPassword=${IO_INT_PASSWORD} \
         --from-literal=wmioIntegrationPlaygroundPassword=${IO_INT_PLAYGROUND_PASSWORD} \
         --from-literal=apiGatewayUser=${API_GATEWAY_USER} \
         --from-literal=apiGatewayPassword=${API_GATEWAY_PASSWORD}
