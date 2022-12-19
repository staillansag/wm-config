#!/bin/bash

source ./secrets.sh
source ./config.sh

echo "Creating Kubernetes secret to connect to SAG ACR"
kubectl create secret docker-registry sagregcred --docker-server=${SAG_DOCKER_URL} --docker-username=${SAG_DOCKER_USERNAME} --docker-password=${SAG_DOCKER_PASSWORD} --docker-email=${EMAIL_ADDRESS}
