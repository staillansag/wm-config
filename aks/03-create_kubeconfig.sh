#!/bin/bash

source ./config.sh
source ./secrets.sh

echo "Retrieving kubeconfig file for cluster ${CLUSTER_NAME}"
az aks get-credentials --resource-group ${RESOURCE_GROUP} --name ${CLUSTER_NAME} --overwrite-existing

