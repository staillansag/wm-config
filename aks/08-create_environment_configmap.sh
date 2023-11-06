#!/bin/bash

echo "Creating global Kubernetes config map"
kubectl create configmap global-config \
	--from-literal=RDS_DATABASE_NAME=${RDS_DATABASE_NAME} \
	--from-literal=RDS_SERVER_NAME=${RDS_SERVER_NAME} \
	--from-literal=RDS_PORT=${RDS_PORT} \
	--from-literal=RDS_USER_NAME=${RDS_USER_NAME} \
	--from-literal=S3_BUCKET_NAME=${S3_BUCKET_NAME} \
	--from-literal=S3_FOLDER=${S3_FOLDER} \
	--from-literal=S3_URL=${S3_URL} \
	--from-literal=SFTP_SERVER_NAME=${SFTP_SERVER_NAME} \
	--from-literal=SFTP_PORT=${SFTP_PORT} \
	--from-literal=SFTP_FOLDER=${SFTP_FOLDER} \
	--from-literal=SFTP_USER_NAME=${SFTP_USER_NAME} || exit 1