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
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE_POSTGRES
}
# Sélection de la souscription Azure
az account set --subscription $SUBSCRIPTION_ID

# Creation du Azure Database pour les serveurs flexibles PostgreSQL
az postgres flexible-server create \
  --location $LOCATION \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $POSTGRESNAME \
  --admin-user $POSTGRESUSER \
  --admin-password $POSTGRESPASSWORD \
  --sku-name Standard_B1ms \
  --tier Burstable \
  --public-access $POSTGRESIPACESS \
  --storage-size 32 \
  --version 16 \
  --performance-tier P4 \

if [ $? -ne 0 ]; then
  log_with_date "Erreur lors du la creation du Azure Database PostgreSQL."
  exit 1
else
  log_with_date "Azure Database PostgreSQL "$POSTGRESNAME" pour le groupe de ressources '$RESOURCE_GROUP_NAME' créé dans la localisation '$LOCATION'."
fi
