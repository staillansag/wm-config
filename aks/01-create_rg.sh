#!/bin/bash

if [ "${AZ_SANDBOX_MODE}" -eq "true" ]; then
	AKS_RESOURCE_GROUP=$(az group list --query "[0].name" --output tsv)
    echo "Running in an Azure sandox, using default resource group ${AKS_RESOURCE_GROUP} in region ${AZ_LOCATION}"
	echo "##vso[task.setvariable variable=AKS_RESOURCE_GROUP;]${AKS_RESOURCE_GROUP}"
else
	echo "Creating resource group ${AKS_RESOURCE_GROUP} in region ${AZ_LOCATION}"
	az group create --location ${AZ_LOCATION} \
		--name ${AKS_RESOURCE_GROUP}  || exit 1
fi

