#!/bin/bash

echo "Creating resource group ${AKS_RESOURCE_GROUP} in region ${AZ_LOCATION}"
az group create --location ${AZ_LOCATION} \
	--name ${AKS_RESOURCE_GROUP}  || exit 1
