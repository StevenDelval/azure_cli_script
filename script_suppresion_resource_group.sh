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

az group delete --name "$RESOURCE_GROUP_NAME" --yes --no-wait | tee -a $LOG_FILE


log_with_date "Groupe de ressources '$RESOURCE_GROUP_NAME' est en cours de suppression sous la souscription '$SUBSCRIPTION_ID'."