#!/bin/bash

source ./secrets_aks.sh
source ./config_aks.sh

echo "Connecting to Azure with SP ${AZ_SP_ID}"
az login --service-principal -u ${AZ_SP_ID} -p ${AZ_SP_SECRET} --tenant ${AZ_TENANT_ID}  || exit 1
