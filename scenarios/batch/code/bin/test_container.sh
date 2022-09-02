#!/bin/bash -e
source ../config/azfinsim.config

#-- short test - standup container and process 5 trades (cache must be populated by generator.py first)

REDISKEY=$(az keyvault secret show --name $AZFINSIM_REDIS_SECRET_ID --vault-name $AZFINSIM_KV_NAME --query "value" | tr -d '",')
APP_INSIGHTS_INSTRUMENTATION_KEY=$(az keyvault secret show --name $AZFINSIM_APPINSIGHTS_SECRET_ID --vault-name $AZFINSIM_KV_NAME --query "value" | tr -d '",')

sudo docker run $AZFINSIM_ACR_IMAGE /azfinsim/azfinsim.py --start-trade 1000 --trade-window 5 --cache-type redis --cache-name $AZFINSIM_REDISHOST --cache-port 6380 --cache-key $REDISKEY --cache-ssl yes --appinsights-key $APP_INSIGHTS_INSTRUMENTATION_KEY --format eyxml --algorithm pvonly --failure 0.000000
