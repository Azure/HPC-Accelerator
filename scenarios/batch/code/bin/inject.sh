#!/bin/bash -e
#
# Mass inject the trades.gz dataset 
#
CONFIG="../config/azfinsim.config"
if [ -f $CONFIG ]; then
   source $CONFIG
else
   echo "ERROR: Configuration file $CONFIG does not exist. You must first generate a configuration file by running ./deploy.sh"
   echo "(The redis cache needs to be created before you can inject the trade data)"
   exit 1
fi

#-- get the redis password
AZFINSIM_REDIS_KEY=$(az keyvault secret show --name $AZFINSIM_REDIS_SECRET_ID --vault-name $AZFINSIM_KV_NAME --query "value" | tr -d '",')

#-- inject 
echo "Injecting 1 million trades into cache $AZFINSIM_REDISHOST:6379"
time zcat ../data/trades.gz | redis-cli -h $AZFINSIM_REDISHOST -p 6379 -a $AZFINSIM_REDIS_KEY --pipe
