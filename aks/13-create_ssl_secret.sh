#!/bin/bash

source ./secrets_aks.sh
source ./config_aks.sh

if [ -f "${TLS_KEY_FILE}" ]; then
    echo "Creating Kubernetes secret for TLS certificate used by Ingress controller"
    kubectl create secret tls aks-tls --key="${TLS_KEY_FILE}" --cert="${TLS_CERT_FILE}"  || exit 1
else
    echo "La variable TLS_KEY_FILE est non positionnée ou ne pointe pas vers un fichier existant. Pas de création de secret Kubernetes pour le certificat TLS."
fi