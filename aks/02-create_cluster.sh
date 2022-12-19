#!/bin/bash

source ./config.sh
source ./secrets.sh

echo "Creating AKS cluster ${CLUSTER_NAME} in resource group ${RESOURCE_GROUP}"
echo "VM size: ${VM_SIZE}"
echo "Node count: ${NODE_COUNT}"
echo "Load balancer SKU: ${LOAD_BALANCER_SKU}"
az aks create \
	-g ${RESOURCE_GROUP} \
	-n ${CLUSTER_NAME} \
	--enable-managed-identity \
	--node-count ${NODE_COUNT} \
	--enable-addons monitoring \
	--generate-ssh-keys \
	--node-vm-size ${VM_SIZE} \
	--load-balancer-sku ${LOAD_BALANCER_SKU}

# To solve the "The subscription is not registered to use namespace 'Microsoft.OperationsManagement'" error, visit:
# https://medium.com/@woeterman_94/how-to-solve-the-subscription-is-not-registered-to-use-namespace-in-azure-36bd2dfde3b0
