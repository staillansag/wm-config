#!/bin/bash

echo "Creating environment Kubernetes secrets"

if [ -z "${SAG_MSR_ADMIN_PASSWORD}" ]; then
    echo "SAG_MSR_ADMIN_PASSWORD is empty, using the default MSR password"
	SAG_MSR_ADMIN_PASSWORD=manage
fi

kubectl create secret generic environment-secret \
	--from-literal=ADMIN_PASSWORD=${SAG_MSR_ADMIN_PASSWORD} \
	--from-literal=DB_PASSWORD=${RDS_PASSWORD} \
	--from-literal=S3_ACCESS_KEY=${S3_ACCESS_KEY} \
	--from-literal=S3_SECRET_KEY=${S3_ACCESS_SECRET} \
	--from-literal=SFTP_USER_PASSWORD=${SFTP_PASSWORD} || exit 1

