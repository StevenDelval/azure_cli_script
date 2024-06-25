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

# Suppression du Containeur Blob
az storage container delete --name $NOM_BLOB_CONTAINER --account-name $STORAGE_NAME

if [ $? -eq 0 ]; then
    log_with_date "Container '$NOM_BLOB_CONTAINER' dans le compte de stockage '$STORAGE_NAME' a été supprimé avec succès."
else
    log_with_date "Problème lors de la suppression du container '$NOM_BLOB_CONTAINER' dans le compte de stockage '$STORAGE_NAME'."
fi