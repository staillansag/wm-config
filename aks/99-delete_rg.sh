#!/bin/bash

source ./secrets.sh
source ./config.sh

echo "Deleting resource group ${RESOURCE_GROUP}"

az group delete \
--name ${RESOURCE_GROUP} \
--yes

