#!/bin/bash

source ./secrets_aks.sh
source ./config_aks.sh

echo "Deleting resource group ${RESOURCE_GROUP}"

az group delete \
--name ${RESOURCE_GROUP} \
--yes  || exit 1