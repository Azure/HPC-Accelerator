#!/bin/bash

source ../config/azfinsim.config

#-- test purposes only - get the keyvault stored secrets created by terraform

AZFINSIM_ACR_KEY=$(az keyvault secret show --name $AZFINSIM_ACR_SECRET_ID --vault-name $AZFINSIM_KV_NAME --query "value" | tr -d '",')
APP_INSIGHTS_INSTRUMENTATION_KEY=$(az keyvault secret show --name $AZFINSIM_APPINSIGHTS_SECRET_ID --vault-name $AZFINSIM_KV_NAME --query "value" | tr -d '",')
AZFINSIM_STORAGE_SAS_TOKEN=$(az keyvault secret show --name $AZFINSIM_STORAGE_SAS_SECRET_ID --vault-name $AZFINSIM_KV_NAME --query "value" | tr -d '",')
AZFINSIM_REDIS_KEY=$(az keyvault secret show --name $AZFINSIM_REDIS_SECRET_ID --vault-name $AZFINSIM_KV_NAME --query "value" | tr -d '",')

echo "ACR Key: $AZFINSIM_ACR_KEY"
echo "AppInsights Key: $APP_INSIGHTS_INSTRUMENTATION_KEY"
echo "Storage SAS: $AZFINSIM_STORAGE_SAS_TOKEN"
echo "Redis Key: $AZFINSIM_REDIS_KEY"

