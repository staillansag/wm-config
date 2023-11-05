#!/bin/bash

echo "Deleting resource group ${AKS_RESOURCE_GROUP}"

az group delete \
--name ${AKS_RESOURCE_GROUP} \
--yes  || exit 1