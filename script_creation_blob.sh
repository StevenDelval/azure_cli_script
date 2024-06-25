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

az storage container create --name $NOM_BLOB_CONTAINER --account-name $STORAGE_NAME

log_with_date "Container '$STORAGE_NAME' dans le compte de stockage '$STORAGE_NAME' cree."