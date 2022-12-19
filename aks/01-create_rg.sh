#!/bin/bash

source ./config.sh
source ./secrets.sh

echo "Creating resource group ${RESOURCE_GROUP} in region ${LOCATION}"
az group create --location ${LOCATION} \
	--name ${RESOURCE_GROUP}
