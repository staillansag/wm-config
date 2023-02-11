#!/bin/bash

source ./secrets_aks.sh
source ./config_aks.sh

if [ -z "${AZ_ACR_URL}" ]; then
    echo "Environment variabme AZ_ACR_URL not set, skipping creation of Kubernetes secret to connect to ACR"
else
    echo "Creating Kubernetes secret to connect to ACR ${AZ_ACR_URL}"
    kubectl create secret docker-registry acrregcred --docker-server="${AZ_ACR_URL}" --docker-username="${AZ_SP_ID}" --docker-password="${AZ_SP_SECRET}" --docker-email="${EMAIL_ADDRESS}"  || exit 1
fi