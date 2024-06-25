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

# Creation du compte de stockage
az storage account create \
  --name  $STORAGE_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --location $LOCATION \
  --sku Standard_LRS \
  --kind StorageV2 \
  --allow-blob-public-access false

log_with_date "Storage '$STORAGE_NAME' dans le groupe de ressources '$RESOURCE_GROUP_NAME' créé dans la localisation '$LOCATION'."
