#!/bin/bash

source ./secrets_aks.sh
source ./config_aks.sh

if [ -z "${SAG_DOCKER_USERNAME}" ]; then
    echo "Environment variabme SAG_DOCKER_USERNAME not set, skipping creation of Kubernetes secret to connect to SAG container registry"
else
    echo "Creating Kubernetes secret to connect to SAG container registry"
    kubectl create secret docker-registry sagregcred --docker-server=${SAG_DOCKER_URL} --docker-username=${SAG_DOCKER_USERNAME} --docker-password=${SAG_DOCKER_PASSWORD} --docker-email=${EMAIL_ADDRESS}  || exit 1
fi