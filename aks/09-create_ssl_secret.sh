#!/bin/bash

source ./secrets.sh
source ./config.sh

echo "Creating Kubernetes secret for TLS certificate using by Ingress controller"
kubectl create secret tls aks-tls --key="${TLS_KEY_FILE}" --cert="${TLS_CERT_FILE}"

