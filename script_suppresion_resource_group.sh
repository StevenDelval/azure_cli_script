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
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE_RG
}

# Sélection de la souscription Azure
az account set --subscription $SUBSCRIPTION_ID

# Suppression du ressources groupe 
az group delete --name "$RESOURCE_GROUP_NAME" --yes --no-wait 


log_with_date "Groupe de ressources '$RESOURCE_GROUP_NAME' est en cours de suppression sous la souscription '$SUBSCRIPTION_ID'."