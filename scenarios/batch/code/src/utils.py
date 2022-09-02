import redis 
#import hazelcast
import logging
import random

import azlog

log = azlog.getLogger(__name__)

def SetupCacheConn(type,ip,port,key,ssl):
    if (type=="redis"): 
        if (ssl=="yes"): 
            r=SetupRedisSSLConn(ip,port,key)
        else: 
            r=SetupRedisConn(ip,port,key)
    else:
        print("working on it. not yet supported...")
    return r

def SetupRedisConn(ip,port,key):
    r = redis.Redis(
    host=ip,
    port=port,
    password=key)
    return r

def SetupRedisSSLConn(ip,port,key):
    r = redis.StrictRedis(
    host=ip,
    port=port,
    password=key,
    ssl_cert_reqs=u'none', #-- or specify location of certs
    ssl=True)
    return r

def GetTrade(r,keyname):
    xmlstring = r.get(keyname)
    return xmlstring

'''  cachetype = redis, nfs etc.
     io = "input" or "output"
     r = redis handle
     format = eyxml or varxml
     tradenum = trade number
     xmlstring = the trade xml data
'''
def PutTrade(cache_type,io,r,format,tradenum,xmlstring):
    if (format == "eyxml"):
        prefix = "ey"
    elif (format == "varxml"):
        prefix = "var"
    else:
        log.error("invalid format: %s" % format)
        return(1)

    if (io == "input"):
        keyname = "%s%007d.xml" % (prefix, tradenum)
    elif (io == "output"):
        keyname = "%s%007d_result.xml" % (prefix, tradenum)
    else: 
        log.error("File format: %s; input/output only supported. " % format)
        return(1)

    if (cache_type=="redis"):
        r.set(keyname,xmlstring)

    log.debug("Trade %d: written as: %s:\n%s" % (tradenum,keyname,xmlstring))

    return r

def InjectRandomFail(failure):
    if random.uniform(0.0, 1.0) < failure:
       logging.error("RANDOM ERROR INJECTION: TASK EXIT WITH ERROR")
       return(1)

def DoFakeCompute(xmlstring,delay_time,task_duration,mem_usage):
    import numpy as np
    import time
    import random
    # allocate the memory
    array_size = (mem_usage, 131072)
    data = np.ones(array_size, dtype=np.float64)
    # do startup delay
    time.sleep(delay_time)

    # now do fake computation
    task_duration_s = task_duration / 1000.0 #- convert from ms to s
    end_time = time.time() + task_duration_s
    while time.time() < end_time:
        data *= 12345.67890
        data[:] = 1.0
