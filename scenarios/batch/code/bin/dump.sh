#!/bin/bash -ex
#
# Dump the database to a file dump.txt
#
CONFIG="../config/azfinsim.config"
if [ -f $CONFIG ]; then
   source $CONFIG
else
   echo "ERROR: Configuration file $CONFIG does not exist. You must first generate a configuration file by running ./deploy.sh"
   exit 1
fi
./dump.py --start-trade 0 --trade-window 1000000 --cache-type redis --cache-name $AZFINSIM_REDISHOST --cache-port $AZFINSIM_REDISPORT --cache-ssl yes --format eyxml --verbose false 
