#!/bin/bash

source ./secrets_aks.sh
source ./config_aks.sh

if [ -f "${MSR_LICENSE_FILE}" ]; then
    echo "Creating Kubernetes secret for the MSR license"
    kubectl create secret generic licenses --from-file=msr-license=${MSR_LICENSE_FILE}  || exit 1
else
    echo "La variable MSR_LICENSE_FILE est non positionnée ou ne pointe pas vers un fichier existant. Pas de création de secret Kubernetes pour la license MSR."
fi

