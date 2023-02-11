#!/bin/bash

source ./config_aks.sh
source ./secrets_aks.sh

echo "Retrieving kubeconfig file for cluster ${CLUSTER_NAME}"
az aks get-credentials --resource-group ${RESOURCE_GROUP} --name ${CLUSTER_NAME} --overwrite-existing  || exit 1