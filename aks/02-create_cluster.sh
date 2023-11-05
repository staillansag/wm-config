#!/bin/bash

echo "Creating AKS cluster ${AKS_CLUSTER_NAME} in resource group ${AKS_RESOURCE_GROUP}"
echo "VM size: ${AKS_VM_SIZE}"
echo "Node count: ${AKS_NODE_COUNT}"
echo "Load balancer SKU: ${AKS_LOAD_BALANCER_SKU}"
az aks create \
	-g ${AKS_RESOURCE_GROUP} \
	-n ${AKS_CLUSTER_NAME} \
	--enable-managed-identity \
	--node-count ${AKS_NODE_COUNT} \
	--enable-addons monitoring \
	--generate-ssh-keys \
	--node-vm-size ${AKS_VM_SIZE} \
	--load-balancer-sku ${AKS_LOAD_BALANCER_SKU}  || exit 1

# To solve the "The subscription is not registered to use namespace 'Microsoft.OperationsManagement'" error, visit:
# https://medium.com/@woeterman_94/how-to-solve-the-subscription-is-not-registered-to-use-namespace-in-azure-36bd2dfde3b0
