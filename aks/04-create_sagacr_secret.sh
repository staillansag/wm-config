#!/bin/bash

if [ -z "${SAG_ACR_USERNAME}" ]; then
    echo "Environment variable SAG_ACR_USERNAME not set, skipping creation of Kubernetes secret to connect to SAG container registry"
else
    echo "Creating Kubernetes secret to connect to SAG container registry"
    kubectl create secret docker-registry sagregcred --docker-server=${SAG_ACR_URL} --docker-username=${SAG_ACR_USERNAME} --docker-password=${SAG_ACR_PASSWORD} --docker-email=${SAG_ACR_EMAIL_ADDRESS}  || exit 1
fi