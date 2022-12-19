#!/bin/bash

source ./secrets.sh
source ./config.sh

echo "Connecting to Azure with SP ${AZ_SP_ID}"
az login --service-principal -u ${AZ_SP_ID} -p ${AZ_SP_SECRET} --tenant ${AZ_TENANT_ID}
