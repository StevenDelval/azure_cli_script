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
# Creation service de lien de blob
az datafactory linked-service create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --factory-name "$DATAFACORY_NAME" \
    --linked-service-name "$NAMESERVICESTORAGE" \
    --properties @./json/linked_service_storage.json
if [ $? -ne 0 ]; then
  log_with_date "Erreur lors du service blob."
  exit 1
else
  log_with_date "Le service blob '$NAMESERVICESTORAGE' créé dans le datafactory '$DATAFACORY_NAME'."
fi

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
# Creation service de lien de batch
az datafactory linked-service create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --factory-name "$DATAFACORY_NAME" \
    --linked-service-name "$NAMESERVICEBATCH" \
    --properties "@./json/linked_service_batch.json"
if [ $? -ne 0 ]; then
  log_with_date "Erreur lors du service batch."
  exit 1
else
  log_with_date "Le service batch '$NAMESERVICEBATCH' créé dans le datafactory '$DATAFACORY_NAME'."
fi

# Creation du json pour créer la pipeline
cat <<EOF > ./json/pipeline.json
{
    "activities": [
            {
                "name": "$CUSTOMNAME",
                "type": "Custom",
                "dependsOn": [],
                "policy": {
                    "timeout": "0.12:00:00",
                    "retry": 0,
                    "retryIntervalInSeconds": 30,
                    "secureOutput": false,
                    "secureInput": false
                },
                "userProperties": [],
                "typeProperties": {
                    "command": "$COMMANDECUSTOM",
                    "resourceLinkedService": {
                        "referenceName": "$NAMESERVICESTORAGE",
                        "type": "LinkedServiceReference"
                    },
                    "folderPath": "$NOM_BLOB_CONTAINER",
                    "referenceObjects": {
                        "linkedServices": [],
                        "datasets": []
                    }
                },
                "linkedServiceName": {
                    "referenceName": "$NAMESERVICEBATCH",
                    "type": "LinkedServiceReference"
                }
            }
        ]
}
EOF

# Creation service de la pipeline
az datafactory pipeline create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --factory-name "$DATAFACORY_NAME" \
    --name "$PIPELINENAME" \
    --pipeline "@./json/pipeline.json"
if [ $? -ne 0 ]; then
  log_with_date "Erreur lors de la creation du pipeline."
  exit 1
else
  log_with_date "La pipeline '$PIPELINENAME' créé dans le datafactory '$DATAFACORY_NAME'."
fi

# Creation du json pour créer la trigger
cat <<EOF > ./json/trigger.json
{
    "annotations": [],
    "runtimeState": "Started",
    "pipelines": [
        {
            "pipelineReference": {
                "referenceName": "$PIPELINENAME",
                "type": "PipelineReference"
            }
        }
    ],
    "type": "ScheduleTrigger",
    "typeProperties": {
        "recurrence": {
            "frequency": "Minute",
            "interval": 1,
            "startTime": $STARTTIMETRIGGER,
            "endTime": $ENDTIMETRIGGER,
            "timeZone": "Romance Standard Time"
        }
    }
}
EOF

# Creation de la trigger
az datafactory trigger create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --factory-name "$DATAFACORY_NAME" \
    --name "$TRIGGERNAME" \
    --properties "@./json/trigger.json"
if [ $? -ne 0 ]; then
  log_with_date "Erreur lors de la creation du trigger."
  exit 1
else
  log_with_date "La trigger '$TRIGGERNAME' créé dans le datafactory '$DATAFACORY_NAME'."
fi

az datafactory trigger start \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --factory-name "$DATAFACORY_NAME" \
    --name "$TRIGGERNAME"
    
if [ $? -ne 0 ]; then
  log_with_date "Erreur lors du demarrage du trigger."
  exit 1
else
  log_with_date "La trigger '$TRIGGERNAME' dans le datafactory '$DATAFACORY_NAME' est demarre."
fi