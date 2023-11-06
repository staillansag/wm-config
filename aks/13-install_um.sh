#!/bin/bash

echo "Installing Universal Messaging"

kubectl create -f umserver/statefulset-dce-umserver.yaml || exit 1

kubectl rollout status statefulset umserver --timeout=5m || exit 1

kubectl create -f umserver/service-dce-umserver.yaml || exit 1
