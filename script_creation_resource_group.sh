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
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE_RG
}

az account set --subscription $SUBSCRIPTION_ID

az group create --name "$RESOURCE_GROUP_NAME" --location "$LOCATION"

log_with_date "Groupe de ressources '$RESOURCE_GROUP_NAME' créé dans la localisation '$LOCATION'."