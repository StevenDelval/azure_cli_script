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





# Recupere batch account key
BATCHACCOUNTKEY=$(az batch account keys list \
    --resource-group $RESOURCE_GROUP_NAME_BATCH \
    --name $BATCHACCOUNTNAME \
    --query "primary" -o tsv)

if [ -z "$BATCHACCOUNTKEY" ]; then
  log_with_date "Erreur lors de la récupération de la clé de l'account de batch."
  exit 1
fi

#Creation du json pour cree 
cat <<EOF > linked_service_batch.json
{
    "name": "$NAMESERVICEBATCH",
    "type": "Microsoft.DataFactory/factories/linkedservices",
    "properties": {
        "type": "AzureBatch",
        "typeProperties": {
            "accountName": "$BATCHACCOUNTNAME",
            "batchUri": "$BATCHURI",
            "poolName": "$POOLNAME",
            "linkedServiceAuthType": "AccountKey",
            "accountKey": {
                "type": "SecureString",
                "value": "$BATCHACCOUNTKEY"
            }
        }
    }
}
EOF

# # Creation du ressources groupe 
# az datafactory create --factory-name "$DATAFACORY_NAME" --resource-group "$RESOURCE_GROUP_NAME" --location "$LOCATION"
# if [ $? -ne 0 ]; then
#   log_with_date "Erreur lors du la creation du datafactory."
#   exit 1
# else
#   log_with_date "Datafactory "$DATAFACORY_NAME" pour le groupe de ressources '$RESOURCE_GROUP_NAME' créé dans la localisation '$LOCATION'."
# fi




# # Creation du ressources groupe 
# az datafactory create --factory-name "$DATAFACORY_NAME" --resource-group "$RESOURCE_GROUP_NAME" --location "$LOCATION"
# if [ $? -ne 0 ]; then
#   log_with_date "Erreur lors du la creation du datafactory."
#   exit 1
# else
#   log_with_date "Datafactory "$DATAFACORY_NAME" pour le groupe de ressources '$RESOURCE_GROUP_NAME' créé dans la localisation '$LOCATION'."
# fi

