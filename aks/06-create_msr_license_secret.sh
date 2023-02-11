#!/bin/bash

source ./secrets_aks.sh
source ./config_aks.sh

echo "Creating Kubernetes secret for the MSR license"
kubectl create secret generic licenses --from-file=msr-license=${MSR_LICENSE_FILE}  || exit 1

