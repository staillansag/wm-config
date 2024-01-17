#!/bin/bash

echo "Creating global Kubernetes config map"
kubectl create configmap environment-config \
	--from-literal=RDS_DATABASE_NAME=${RDS_DATABASE_NAME} \
	--from-literal=RDS_SERVER_NAME=${RDS_SERVER_NAME} \
	--from-literal=RDS_PORT=${RDS_PORT} \
	--from-literal=RDS_USER_NAME=${RDS_USER_NAME} \
	--from-literal=S3_BUCKET_NAME=${S3_BUCKET_NAME} \
	--from-literal=S3_FOLDER=${S3_FOLDER} \
	--from-literal=S3_REGION=${S3_REGION} \
	--from-literal=S3_URL=${S3_URL} \
	--from-literal=SFTP_SERVER_NAME=${SFTP_SERVER_NAME} \
	--from-literal=SFTP_PORT=${SFTP_PORT} \
	--from-literal=SFTP_FOLDER=${SFTP_FOLDER} \
	--from-literal=SFTP_USER_NAME=${SFTP_USER_NAME} \
	--from-literal=SFTP_SERVER_HOST_KEY=${SFTP_SERVER_HOST_KEY} \
	--from-literal=SMTP_SERVERNAME=${SMTP_SERVERNAME} \
	--from-literal=SMTP_PORT=${SMTP_PORT} \
	--from-literal=SMTP_AUTH_USERNAME=${SMTP_AUTH_USERNAME} \
	--from-literal=SMTP_TRUSTSTORE_ALIAS=${SMTP_TRUSTSTORE_ALIAS} \
	--from-literal=MSR_TEMP_DIR=${MSR_TEMP_DIR} \
	--from-literal=API_GATEWAY_URL=${API_GATEWAY_URL} || exit 1
