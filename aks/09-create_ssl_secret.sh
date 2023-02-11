#!/bin/bash

source ./secrets_aks.sh
source ./config_aks.sh

echo "Creating Kubernetes secret for TLS certificate used by Ingress controller"
kubectl create secret tls aks-tls --key="${TLS_KEY_FILE}" --cert="${TLS_CERT_FILE}"  || exit 1