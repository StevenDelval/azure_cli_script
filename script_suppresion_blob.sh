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

az storage container delete --name $NOM_BLOB_CONTAINER --account-name $STORAGE_NAME

if [ $? -eq 0 ]; then
    log_with_date "Container '$NOM_BLOB_CONTAINER' dans le compte de stockage '$STORAGE_NAME' a été supprimé avec succès."
else
    log_with_date "Problème lors de la suppression du container '$NOM_BLOB_CONTAINER' dans le compte de stockage '$STORAGE_NAME'."
fi