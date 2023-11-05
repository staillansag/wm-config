#!/bin/bash

echo "Installing FluentD"

kubectl create -f monitoring/21_fluend_rbac.yml || exit 1
kubectl create -f monitoring/22_fluentd_daemonSet.yml || exit 1
