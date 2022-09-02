#! /usr/bin/env python3

# Common arg parser

import argparse

def getargs(progname):

    parser = argparse.ArgumentParser(progname)

    #-- Batch parameters
    parser.add_argument("-p","--pool-id", help="<name of the azure batch pool to submit the job to>")
    parser.add_argument("-j","--job-id", default="AzFinSimJob", help="<jobid prefix string>")
    parser.add_argument("-t","--threads", type=int, help='number of client-side threads to use when submitting to batch')

    #-- Cache parameters
    parser.add_argument("--cache-type", default="none", required=True,
                        choices=['redis','filesystem','none'],
                        help="cache type: redis|filesystem|none"),
    parser.add_argument("--cache-name", required=True, default="None", help="<redis or filesystem hostname/ip (port must be open)>")
    parser.add_argument("--cache-port", default=6380, type=int, help="redis port number: default=6380 [SSL]")
    parser.add_argument("--cache-key", default="None", help="cache access key (pulled from keyvault)")
    parser.add_argument("--cache-ssl", default="yes", choices=['yes','no'], help="use SSL for redis cache access")
    parser.add_argument("--cache-path", default="None", help="Cache Filesystem Path (not needed for redis")

    #-- algorithm/work per thread
    parser.add_argument("--tasks", default=0, type=int, help="tasks to run on the compute pool (batch tasks)")
    parser.add_argument('--harvester', default=False, type=lambda x: (str(x).lower() == 'true'), help="use harvester scheduler: true or false")
    parser.add_argument("-f", "--format", default="varxml", choices=['varxml','eyxml'],help="format of trade data: varxml|eyxml")
    parser.add_argument("-s", "--start-trade", default=0, type=int, help="trade range to process: starting trade number")
    parser.add_argument("-w", "--trade-window", required=True, type=int, help="number of trades to process")
    parser.add_argument("-a", "--algorithm", default="deltavega", choices=['deltavega','pvonly','synthetic'],help="pricing algorithm")

    #-- synthetic workload options
    parser.add_argument("-d", "--delay-start", type=int, default=0, help="delay startup time in seconds")
    parser.add_argument("-m", "--mem-usage", type=int, default=16, help="memory usage for task in MB")
    parser.add_argument("--task-duration", type=int, default=20, help="task duration in milliseconds")
    parser.add_argument("--failure", type=float, default=0.0, help="inject random task failure with this probability")

    #-- logs & metrics
#    parser.add_argument("-l", "--loglevel", type=int, default=20, choices=range(0,60,10),
#                        help="loglevel: 0=NOTSET,10=DEBUG,20=INFO,30=WARN,40=ERROR,50=CRITICAL")
#
    parser.add_argument('--verbose', default=False, type=lambda x: (str(x).lower() == 'true'), help="verbose output: true or false")
    parser.add_argument("--appinsights-key", help="Azure Application Insights Key")

    return parser.parse_args()
    
