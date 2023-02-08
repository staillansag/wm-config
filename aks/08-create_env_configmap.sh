#!/bin/bash

source ./secrets.sh
source ./config.sh

echo "Creating environment specific Kubernetes config map"
kubectl create configmap environment-config \
	 --from-literal=apiGatewayUrl=${API_GATEWAY_URL} \
	 --from-literal=wmioIntegrationUrl=${WMIO_INT_URL} \
	 --from-literal=wmioIntegrationPlaygroundUrl=${WMIO_INT_PLAYGROUNG_URL} \
	 --from-literal=kafkaServerList=${KAFKA_SERVER_LIST} \
         --from-literal=domainName=${DOMAIN_NAME} \
         --from-literal=databaseServerName=${DB_SERVERNAME} \
         --from-literal=databaseServerPort=${DB_PORT} \
         --from-literal=databaseName=${DB_NAME}
