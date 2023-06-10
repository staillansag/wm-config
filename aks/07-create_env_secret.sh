#!/bin/bash

source ./secrets_aks.sh
source ./config_aks.sh

echo "Creating global Kubernetes secrets"
kubectl create secret generic global-secrets \
	 --from-literal=elasticUser=${FLUENT_ELASTICSEARCH_USER} \
	 --from-literal=elasticPassword=${FLUENT_ELASTICSEARCH_PASSWORD}  || exit 1
