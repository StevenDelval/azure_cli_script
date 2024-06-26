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
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE_DATAFACORY
}
# Sélection de la souscription Azure
az account set --subscription $SUBSCRIPTION_ID

# Récupération de la clé de l'account de stockage
ACCOUNT_CONNECTION_STR=$(az storage account show-connection-string --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_NAME --query connectionString -o tsv)
if [ -z "$ACCOUNT_CONNECTION_STR" ]; then
  log_with_date "Erreur lors de la récupération de la connection-string du stockage."
  exit 1
fi

# Création du fichier JSON pour le service lié de stockage
cat <<EOF > ./json/linked_service_storage.json
{
    "type": "AzureBlobStorage",
    "typeProperties": {
      "connectionString": "$ACCOUNT_CONNECTION_STR"           
  }
}
EOF

az datafactory linked-service create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --factory-name "$DATAFACORY_NAME" \
    --linked-service-name "$NAMESERVICESTORAGE" \
    --properties @./json/linked_service_storage.json

# Récupération de la clé de l'account de batch
BATCHACCOUNTKEY=$(az batch account keys list \
    --resource-group $RESOURCE_GROUP_NAME_BATCH \
    --name $BATCHACCOUNTNAME \
    --query "primary" -o tsv)

if [ -z "$BATCHACCOUNTKEY" ]; then
  log_with_date "Erreur lors de la récupération de la clé de l'account de batch."
  exit 1
fi

# Creation du json pour créer le service de lien de batch
cat <<EOF > ./json/linked_service_batch.json
{
    "type": "AzureBatch",
    "typeProperties": {
      "accountName": "$BATCHACCOUNTNAME",
      "batchUri": "$BATCHURI",
      "poolName": "$POOLNAME",
      "accessKey": {
        "type": "SecureString",
        "value": "$BATCHACCOUNTKEY"
      },
      "linkedServiceName": {
        "referenceName": "$NAMESERVICESTORAGE",
        "type": "LinkedServiceReference"
      }
    }
}
EOF

az datafactory linked-service create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --factory-name "$DATAFACORY_NAME" \
    --linked-service-name "$NAMESERVICEBATCH" \
    --properties "@./json/linked_service_batch.json"

