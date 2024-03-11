#!/bin/bash
if [ "${AZ_SANDBOX_MODE}" = "true" ]; then
    echo "Running in sandox mode, using ACG tenant ${AZ_ACG_TENANT_ID} in region ${AZ_ACG_LOCATION}"
    az login --service-principal -u ${AZ_ACG_SP_ID} -p ${AZ_ACG_SP_SECRET} --tenant ${AZ_ACG_TENANT_ID}  || exit 1
else
    echo "Connecting to Azure tenant ${AZ_TENANT_ID} with SP ${AZ_SP_ID}"
    az login --service-principal -u ${AZ_SP_ID} -p ${AZ_SP_SECRET} --tenant ${AZ_TENANT_ID}  || exit 1
fi