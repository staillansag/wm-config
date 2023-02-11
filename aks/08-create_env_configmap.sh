#!/bin/bash

source ./secrets_aks.sh
source ./config_aks.sh

echo "Creating global Kubernetes config map"
kubectl create configmap global-config \
	 --from-literal=elasticUrl=${FLUENT_ELASTICSEARCH_HOST} \
	 --from-literal=elasticPort=${FLUENT_ELASTICSEARCH_PORT} \
	 --from-literal=elasticScheme=${FLUENT_ELASTICSEARCH_SCHEME}  || exit 1
