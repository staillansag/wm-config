#!/bin/bash

source ./secrets_aks.sh
source ./config_aks.sh

echo "Creating global Kubernetes config map"
kubectl create configmap global-config \
	 --from-literal=elasticUrl=${FLUENT_ELASTICSEARCH_HOST} \
	 --from-literal=elasticPort=${FLUENT_ELASTICSEARCH_PORT} \
	 --from-literal=elasticScheme=${FLUENT_ELASTICSEARCH_SCHEME}  || exit 1

echo "Creating environment specific Kubernetes config map"
kubectl create configmap environment-config \
	 --from-literal=apiGatewayUrl=${API_GATEWAY_URL} \
	 --from-literal=wmioIntegrationUrl=${WMIO_INT_URL} \
         --from-literal=domainName=${DOMAIN_NAME} \
         --from-literal=databaseServerName=${DB_SERVERNAME} \
         --from-literal=databaseServerPort=${DB_PORT} \
         --from-literal=databaseName=${DB_NAME}