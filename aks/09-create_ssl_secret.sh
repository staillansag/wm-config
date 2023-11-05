#!/bin/bash

if [ -f "${TLS_PUBLICKEY_FILE_PATH}" ]; then
    echo "Creating Kubernetes secret for TLS certificate used by Ingress controller"
    kubectl create secret tls aks-tls --key="${TLS_PRIVATEKEY_FILE_PATH}" --cert="${TLS_PUBLICKEY_FILE_PATH}"  || exit 1
else
    echo "Fichier clé publique TLS inexistant. Pas de création de secret Kubernetes pour le certificat TLS."
fi