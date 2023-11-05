#!/bin/bash

if [ -f "$(MSR_LICENSE_FILE_PATH)" && -f "$(UM_LICENSE_FILE_PATH)" ]; then
    echo "Creating Kubernetes secret for the product licenses"
    kubectl create secret generic licenses \
        --from-file=msr-license=${MSR_LICENSE_FILE_PATH} \
        --from-file=um-license=${UM_LICENSE_FILE_PATH}  || exit 1
else
    echo "At least one of the product licenses is missing in the secure files"
fi

