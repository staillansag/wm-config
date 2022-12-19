#!/bin/bash

source ./secrets.sh
source ./config.sh

echo "Creating Kubernetes secret to connect to ACR ${AZ_ACR_URL}"
kubectl create secret docker-registry acrregcred --docker-server="${AZ_ACR_URL}" --docker-username="${AZ_SP_ID}" --docker-password="${AZ_SP_SECRET}" --docker-email="${EMAIL_ADDRESS}"
