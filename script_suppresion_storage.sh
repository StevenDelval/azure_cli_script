#!/bin/bash

# Activer l'exportation des variables d'environnement
set -o allexport
if [ -f .env ]; then
  source .env
else
  echo "Erreur : fichier .env non trouvé."
  exit 1
fi
set +o allexport

# Fonction pour enregistrer les logs avec la date
log_with_date() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE_STORAGE
}

# Sélection de la souscription Azure
az account set --subscription $SUBSCRIPTION_ID

# Suppression du compte de stockage
az storage account delete \
  --name  $STORAGE_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --yes


log_with_date "Storage '$STORAGE_NAME' est en cours de suppression sous la souscription '$SUBSCRIPTION_ID'."