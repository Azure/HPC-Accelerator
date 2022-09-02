#!/bin/bash -e
#
# Generate the synthetic input trades serially
#
CONFIG="../config/azfinsim.config"
if [ -f $CONFIG ]; then
   source $CONFIG
else
   echo "ERROR: Configuration file $CONFIG does not exist. You must first generate a configuration file by running ./deploy.sh"
   echo "(The redis cache needs to be created before you can inject the trade data)"
   exit 1
fi
../src/generator.py --start-trade 0 --trade-window 1000000 --cache-type redis --cache-name $AZFINSIM_REDISHOST --cache-port $AZFINSIM_REDISPORT --cache-ssl yes --format eyxml --verbose false 
