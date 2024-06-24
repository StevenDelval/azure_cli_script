#!/bin/bash

set -o allexport
if [ -f .env ]; then
  source .env
else
  echo "Erreur : fichier .env non trouvé."
  exit 1
fi
set +o allexport

log_with_date() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE_STORAGE
}

az account set --subscription $SUBSCRIPTION_ID

az storage account create \
  --name  $STORAGE_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --location $LOCATION \
  --sku Standard_LRS \
  --kind StorageV2 \
  --allow-blob-public-access false

log_with_date "Storage '$STORAGE_NAME' dans le groupe de ressources '$RESOURCE_GROUP_NAME' créé dans la localisation '$LOCATION'."
