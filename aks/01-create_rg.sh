#!/bin/bash

source ./config_aks.sh
source ./secrets_aks.sh

echo "Creating resource group ${RESOURCE_GROUP} in region ${LOCATION}"
az group create --location ${LOCATION} \
	--name ${RESOURCE_GROUP}  || exit 1
