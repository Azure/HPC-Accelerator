#! /usr/bin/env python3
#
# Run a Job on a Batch Pool
#
# NB: azure.batch >8.0.0, azure.keyvault > 4.0.0 required
#
import argparse
import datetime
import logging
import sys
import time
from multiprocessing.pool import ThreadPool

import azure.batch._batch_service_client as batch
import azure.batch.batch_auth as batchauth
import azure.batch.models as batchmodels
from azure.batch import BatchServiceClient
from azure.common.credentials import ServicePrincipalCredentials
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
from applicationinsights.logging import LoggingHandler

from getargs import getargs
from config import *
import config
import secrets
import azlog 

#logging.basicConfig(level=logging.INFO, format='%(asctime)s:%(levelname)s:%(message)s')
#log = logging.getLogger(__name__)

log = azlog.getLogger(__name__)

if __name__ == '__main__':

    #-- grab cli args
    args = getargs("submit")

    #-- pull keys/passwords from the keyvault
    secrets.ReadKVSecrets()

    # set up logging - STDOUT
    #handler = LoggingHandler(APP_INSIGHTS_INSTRUMENTATION_KEY)
    #logging.basicConfig(
    #format="%(asctime)s azfinsim: %(name)s %(threadName)-10.10s %(levelname)-5.5s %(message)s",
    #handlers=[
    #      LoggingHandler(APP_INSIGHTS_INSTRUMENTATION_KEY), #-- send to AZURE
    #      logging.StreamHandler(stream=sys.stdout) #-- send to STDOUT
    #],level=args.loglevel)
    #logging.info("%s" % args)

    credentials = secrets.SetupAADAuth()
    batch_client = batch.BatchServiceClient(credentials, batch_url=AZFINSIM_ENDPOINT)

    job_id = args.job_id + "-" + time.strftime("%Y%m%d-%H%M%S")
    pool_id = args.pool_id

    log.info("Starting job %s in pool %s", job_id, pool_id)

    job = batchmodels.JobAddParameter(
        id=job_id,
        pool_info=batchmodels.PoolInformation(pool_id=pool_id)
    )
    batch_client.job.add(job)
    #batch_service_client.job.add(job)

    #-- harvester runs on the VM; azfinsim in a container. 
    if (args.harvester):
        OPTIONS ="-v /var/lib/hyperv:/kvp"
        ENGINE="/azfinsim/harvester.py"
    else:
        OPTIONS = ""
        #container_run_options='--rm --workdir /')
        ENGINE="/azfinsim/azfinsim.py"

    task_container_settings = batch.models.TaskContainerSettings(image_name=AZFINSIM_ACR_IMAGE,container_run_options=OPTIONS)

    output_container_sas_url = AZFINSIM_STORAGE_CONTAINER_URI + config.AZFINSIM_STORAGE_SAS_TOKEN
    #log.info("output container: %s", output_container_sas_url)
    #build up the task array of azfinsim commands
    tasks = {}
    start_trade = args.start_trade
    tradespertask = args.trade_window / args.tasks
    for idx in range(0,args.tasks):
        taskname = "task_{:06d}".format(idx)
        command = ('/bin/sh -c "%s \
--start-trade %d --trade-window %d --tasks %d --task-duration %d \
--cache-type %s --cache-name %s --cache-port %s --cache-key %s --cache-ssl %s \
--appinsights-key %s --format %s --algorithm %s --failure %f"') \
        % (ENGINE,start_trade,tradespertask,args.tasks,args.task_duration,args.cache_type,args.cache_name,args.cache_port,config.AZFINSIM_REDISKEY,args.cache_ssl,config.APP_INSIGHTS_INSTRUMENTATION_KEY,args.format,args.algorithm,args.failure)
        start_trade += tradespertask

        destination_path = f"{pool_id}/{job_id}/{taskname}"
        tasks[taskname] = batchmodels.TaskAddParameter(
            id=taskname, command_line=command,
            container_settings=task_container_settings,
            output_files=[batchmodels.OutputFile(
                          file_pattern="../std*.txt",
                          destination=batchmodels.OutputFileDestination(
                              container=batchmodels.OutputFileBlobContainerDestination(
                                  container_url=output_container_sas_url,
                                  path=destination_path
                              )
                          ),
                          upload_options=batchmodels.OutputFileUploadOptions(
                              upload_condition=batchmodels.OutputFileUploadCondition.task_completion
                          )
            )]
        )
        log.info("Task %s, Command %s" % (taskname,command))

    max_batch_size = 100
    numthreads = args.threads
    tasks_to_submit = list(tasks.keys())
    nfailed = 0
    retries = 0
    server_errors = list()
    server_error_messages = set()
    client_errors = list()
    client_error_messages = set()
    successes = []

    def add_tasks(i):
        res = batch_client.task.add_collection(job_id, [ tasks[taskid] for taskid in tasks_to_submit[i:i+max_batch_size] ])
        counter = 0
        for t in res.value:
            if t.status == batchmodels.TaskAddStatus.success:
                 counter += 1
            elif t.status == batchmodels.TaskAddStatus.client_error:
                 client_errors.append(t.task_id)
                 client_error_messages.add(t.error.message.value.split('\n')[0])
            elif t.status == batchmodels.TaskAddStatus.server_error:
                 server_errors.append(t.task_id)
                 server_error_messages.add(t.error.message.value.split('\n')[0])
        successes.append(counter)
        return 1

    ntasks = len(tasks)
    thread_pool = ThreadPool(numthreads)
    log.info('Starting the thread pool (%d threads)', numthreads)
    submit_start = time.time()
    while True:
        thread_pool.map(add_tasks, range(0, len(tasks_to_submit), max_batch_size))
        if len(server_errors) > 0:
            log.info("Number of server errors = %d", len(server_errors))
            for err in server_error_messages:
                log.info("    (%s)", err)
            if len(server_errors) < 100:
                log.info("Server errors: %s", ','.join(server_errors))
        if len(client_errors) > 0:
            log.info("Number of client errors = %d", len(client_errors))
            for err in client_error_messages:
                log.info("    (%s)", err)
            if len(client_errors) < 100:
                log.info("Client errors: %s", ','.join(client_errors))
        if len(server_errors) == 0 or retries >= 5:
             break
        retries += 1
        nfailed += len(server_errors) + len(client_errors)
        tasks_to_submit = list(server_errors)
        server_errors = list()
        server_error_messages = set()
        client_errors = list()
        client_error_messages = set()
        log.info('Resubmitting %d tasks', len(tasks_to_submit))

    success_counts = {}
    for n in successes:
        v = success_counts.get(n, 0)
        success_counts[n] = v + 1
    log.info("Histogram of number of successful tasks submitted:")
    log.info("%s", ','.join([ str(x) for x in range(0,101) ]))
    log.info("%s", ','.join([ str(success_counts.get(x, 0)) for x in range(0,101) ]))

    # this is not equal to ntasks if batch reports a success when it isn't actually added
    tot_tasks = sum(successes)
    submit_time = time.time() - submit_start
    taskspersec = tot_tasks/submit_time
    log.info('Thread pool complete: %s tasks in %s seconds (%s tasks per second, %d task failures)', tot_tasks, submit_time, taskspersec, nfailed)

    log.info('Finished adding tasks. Setting job to auto terminate once all tasks complete.')
    batch_client.job.update(
        job_id=job_id,
        job_update_parameter=batchmodels.JobUpdateParameter(
            pool_info=batchmodels.PoolInformation(pool_id=pool_id),
            on_all_tasks_complete=batchmodels.OnAllTasksComplete.terminate_job
        )
    )
