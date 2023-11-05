#!/bin/bash

echo "Retrieving kubeconfig file for cluster ${AKS_CLUSTER_NAME}"
az aks get-credentials --resource-group ${AKS_RESOURCE_GROUP} --name ${AKS_CLUSTER_NAME} --overwrite-existing  || exit 1