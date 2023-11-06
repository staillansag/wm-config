#!/bin/bash

echo "Installing Postgres"

az postgres server create --name ${AZPG_SERVER_NAME} \
  --resource-group ${AKS_RESOURCE_GROUP} \
  --location ${AZ_LOCATION} \
  --admin-user ${AZPG_USER_NAME} \
  --admin-password ${AZPG_PASSWORD} \
  --sku-name ${AZPG_SKU_NAME} \
  --version ${AZPG_VERSION} \
  --storage-size ${AZPG_STORAGE_SIZE} || exit 1

az postgres server firewall-rule create --resource-group ${AKS_RESOURCE_GROUP} \
  --server-name ${AZPG_SERVER_NAME} \
  --name AllowAllIps \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 255.255.255.255 || exit 1

az postgres db create --resource-group ${AKS_RESOURCE_GROUP} \
  --server-name ${AZPG_SERVER_NAME} \
  --name ${AZPG_DATABASE_NAME} || exit 1

timeout=300
interval=5

echo "Waiting for PostgreSQL..."

endTime=$(( $(date +%s) + timeout ))

export PGPASSWORD=${AZPG_PASSWORD}
while ! psql "host=${AZPG_SERVER_NAME}.postgres.database.azure.com port=5432 user=sagdemo@sagdemo dbname=sagdemo sslmode=require" -c '\q' 2>/dev/null; do
    sleep $interval
    now=$(date +%s)
    if [[ $now -gt $endTime ]]; then
        echo "Erreur: Timeout atteint sans que PostgreSQL ne soit prêt."
        exit 1
    fi
done
