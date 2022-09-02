#!/bin/bash -e
#
# submit batch job
#
CONFIG="../config/azfinsim.config"
if [ -f $CONFIG ]; then
   source $CONFIG
else
   echo "ERROR: Configuration file $CONFIG does not exist. You must first generate a configuration file by running ./deploy.sh"
   echo "(The batch pool, container registry & redis cache need to be created before you can run a job)"
   exit 1
fi

#-- select pool 
POOL=$AZFINSIM_AUTOSCALE_POOL
#POOL=$AZFINSIM_REALTIME_POOL

#-- trades to process
TRADES=1000000

#-- tasks (TRADES/TASKS = number of trades to run per task/core, so 1000000/10000 = 100 trades per task running on each core) 
TASKS=10000

# DEMO RUN PV Only 1K Trades, 10K Monte Carlos : ~7 seconds/trade
../src/submit.py --job-id "PV_MonteCarlo10K" --pool-id $POOL --start-trade 0 --trade-window $TRADES --tasks $TASKS --threads 100 --cache-type redis --cache-name $AZFINSIM_REDISHOST --cache-port $AZFINSIM_REDISPORT --cache-ssl yes --format eyxml --algorithm pvonly --failure 0.0

# Delta Vega : ~0.5 seconds per trade
../src/submit.py --job-id "DeltaVega" --pool-id $POOL --start-trade 0 --trade-window $TRADES --tasks $TASKS --threads 100 --cache-type redis --cache-name $AZFINSIM_REDISHOST --cache-port $AZFINSIM_REDISPORT --cache-ssl yes --format eyxml --algorithm deltavega --failure 0.0


# SYNTHETIC run - 50 milliseconds per trade
../src/submit.py --job-id "Sythetic50ms" --pool-id $POOL --start-trade 0 --trade-window $TRADES --tasks $TASKS --threads 100 --cache-type redis --cache-name $AZFINSIM_REDISHOST --cache-port $AZFINSIM_REDISPORT --cache-ssl yes --format eyxml --algorithm synthetic --task-duration 50 --mem-usage 16 --failure 0.0

# Run via the Harvester "Scheduler"
#../src/submit.py --harvester true --start-trade 0 --trade-window 1000 --tasks 25 --threads 100 --task-duration 50 --cache-type redis --cache-name $REDISHOST --cache-port $REDISPORT --cache-ssl yes --format eyxml --algorithm pvonly --failure 0.0
