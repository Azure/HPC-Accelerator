#! /usr/bin/env python3

#-- harvest scheduler that runs on the compute pool nodes

import argparse
import time
import sys
import logging
import os
import psutil

from applicationinsights import TelemetryClient
from applicationinsights.logging import LoggingHandler

from getargs import getargs
import azlog
azlog.color=False

#-- Timeout between polling the harvest #cores api/file
HARVESTPOLLTIMEOUT = 30
#-- Executable to launch per cpu slot
#ENGINE="burn.sh" # (for testing)
ENGINE="/azfinsim/azfinsim.py"
#KVP_MONITOR="/var/lib/hyperv/.kvp_pool_0"
#-- mounted via: sudo docker run -v /var/lib/hyperv:/kvp -it mkharvestazcr.azurecr.io/azfinsim/azfinsimub1804
KVP_MONITOR="/kvp/.kvp_pool_0"

def read_harvest_cores() :
   vcores = psutil.cpu_count(logical=True)
   pcores = psutil.cpu_count(logical=False)
   log.info("Polling Harvester: Physical Cores: %d Logical Cores: %d" % (pcores,vcores))
   kvp=KVP_MONITOR
   try:
       f = open(kvp, "r")
       str=f.read()
       if (len(str) > 0):
           str = str.replace("CurrentCoreCount","")
           str = str.replace('\0','')
           ncores = int(str.split('.')[0])
           log.info("Harvest file %s has current physical core count: %d" % (kvp,ncores))
       else:
           ncores = vcores
           log.warn("Harvest file %s is empty; using static vcore count: %d" % (kvp,ncores))
   except OSError: 
       ncores = vcores
       log.warn("Harvest file %s doesn't exist; using static vcore count: %d" % (kvp,ncores))

   tc.track_metric('HARVESTCORES', ncores)
   tc.flush()
   return ncores
       
def spawn(ncores) :
    env =  {"PATH":"."}
    args = ("null","null")
    log.info("spawning %d processes" % ncores)
    for i in range(ncores):
        pid = os.fork()
        if not pid:
             try:
                 os.execvpe("burn.sh", args, env)
             except OSError as e:
                 log.error("Exec failed: %s\n" % (e.strerror))
                 os._exit(1)
             else:
                 pid = os.waitpid(pid,0)

def spawn_one(start_trade,trade_window,inputargs):
    #path = os.environ['PATH']
    argtup = tuple(inputargs)
    pid = os.fork()
    if not pid:
        #-- child process
        log.info("spawning new process %s: pid %d: start_trade=%d, ntrades=%d" % (ENGINE,os.getpid(),start_trade,trade_window))
        #logging.info(argtup)
        try:
            os.execve(ENGINE, argtup, os.environ.copy())
        except OSError as e:
            log.error("Exec failed: %s\n" % (e.strerror))
            os._exit(1)
    #else:
        #pid = os.waitpid(pid,0)

def replace_args(start_trade,trade_window,inputargs):
    result = []
    skip=False
    for i in range(len(inputargs)):
      if (skip==True):
          skip=False
          continue
      if (inputargs[i]=='start_trade'):
          result.append('start_trade')
          result.append(str(start_trade))
          skip=True
      elif (inputargs[i]=='trade_window'):
          result.append('trade_window')
          result.append(str(trade_window))
          skip=True
      else:
          result.append(inputargs[i])
          skip=False
    return(result)

#-- register the absolute start time
#launch=time.time_ns() #-- python3.8 only
launch=time.time()

log = azlog.getLogger(__name__)

if __name__ == "__main__":

    #-- grab cli args: will be passed through to child processes
    args = getargs("harvester")

    #-- reformat args into a list of strings for execvpe
    inputargs = []
    inputargs.append(ENGINE) #-- first arg to execvpe() should be progname
    for arg in vars(args):
        #print(arg, getattr(args,arg))
        val = str(getattr(args,arg))
        arg=arg.replace("_","-")
        inputargs.append(str("--" + arg)) #-- re-add the stripped "--" prefix
        inputargs.append(val)
    #print(inputargs)

    #-- setup azure application insights handle for telemetry
    tc = TelemetryClient("%s" % args.appinsights_key)

    # set up logging - STDOUT & Azure AppInsights EventLog
    #handler = LoggingHandler(args.appinsights_key)
    #logging.basicConfig(
    #    format="%(asctime)s harvester: %(name)s %(threadName)-10.10s %(levelname)-5.5s %(message)s",
    #    handlers=[
	   #     LoggingHandler(args.appinsights_key), #-- send to AZURE
	   #     logging.StreamHandler(stream=sys.stdout) #-- send to STDOUT
    #    ],level=args.loglevel)

    #-- log start time
    log.info("TRADE %10d: LAUNCH    : %d" % (args.start_trade,launch))
    tc.track_metric('STARTTIME', launch)
    tc.flush()

    #-- get initial harvest core count
    slots = read_harvest_cores()
    log.info("%d x Cores available." % slots)

    #-- calculate number of trades per process/batch/cpu
    max_batch_size = 10 
    total_trades = args.trade_window
    lastbatch = total_trades % max_batch_size
    nbatchesfl = total_trades / max_batch_size
    nbatches = int(nbatchesfl)
    offset = args.start_trade
    log.info("%d trades to process in this task (%.2f batches of %d)" % (total_trades,nbatchesfl,max_batch_size))

    #-- Main loop: monitor harvest api/file & dispatch processes to available cores
    batchesdone=0
    trades_processed=0
    while (batchesdone <= nbatches):
        procs = psutil.Process().children()
        gone, alive = psutil.wait_procs(procs,timeout=1,callback=None)
        nprocs = len(alive)
        freeslots = slots - nprocs
        log.info("%d processes running on %d total slots: %d slots available." % (nprocs,slots,freeslots))
        if (nprocs < slots): 
            for i in range(freeslots):
                if (batchesdone == nbatches): batch_size = lastbatch
                else: batch_size = max_batch_size
                inputargs = replace_args(offset,batch_size,inputargs) # substitute the command line args
                spawn_one(offset,batch_size,inputargs)
                trades_processed += batch_size
                offset += batch_size
                batchesdone+=1
                if (batch_size == lastbatch):
                    break
        time.sleep(HARVESTPOLLTIMEOUT)
        #-- re-read the harvest file - check if #slots has changed
        slots = read_harvest_cores()

    log.info("%d trades processed. No trades left to process; relinquishing cores" % trades_processed)

    # flush all un-sent telemetry items
    tc.flush()
    #logging.shutdown()

    #-- when all work done, exit and allow orchestration to recover node. 
    exit(0)