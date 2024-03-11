#!/bin/bash
echo "Connecting to Azure tenant ${AZ_TENANT_ID} with SP ${AZ_SP_ID}"
az login --service-principal -u ${AZ_SP_ID} -p ${AZ_SP_SECRET} --tenant ${AZ_TENANT_ID}  || exit 1