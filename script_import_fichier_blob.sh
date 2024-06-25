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

# Nom du fichier à importer
FILE_NAME=$(basename "$FILE_PATH") 

# Sélection de la souscription Azure
az account set --subscription $SUBSCRIPTION_ID

# Récupération de la clé de l'account de stockage
ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_NAME --query '[0].value' --output tsv)
if [ -z "$ACCOUNT_KEY" ]; then
  log_with_date "Erreur lors de la récupération de la clé de l'account de stockage."
  exit 1
fi

# Import du fichier dans le blob
az storage blob upload --container-name $NOM_BLOB_CONTAINER --file $FILE_PATH --name $FILE_NAME --account-name $STORAGE_NAME --account-key $ACCOUNT_KEY
if [ $? -ne 0 ]; then
  log_with_date "Erreur lors du téléversement du fichier."
  exit 1
else
  log_with_date "Ajout du fichier '$FILE_NAME' dans le blob $NOM_BLOB_CONTAINER du stockage $STORAGE_NAME"
fi

