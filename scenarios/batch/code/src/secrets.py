from azure.batch import BatchServiceClient
from azure.common.credentials import ServicePrincipalCredentials
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient

from config import *
import config
import azlog

log = azlog.getLogger(__name__)

def SetupAADAuth():
    credentials = ServicePrincipalCredentials(
       client_id=AZURE_CLIENT_ID,
       secret=AZURE_CLIENT_SECRET,
       tenant=AZURE_TENANT_ID,
       resource="https://batch.core.windows.net/")
    return credentials

def ReadKVSecrets():
    """ Client side only: read secrets from keyvault """
    #SetupAADAuth()
    kvcredential = DefaultAzureCredential()
    kvclient = SecretClient(vault_url=AZFINSIM_KV_URL, credential=kvcredential)

    kvsecret = kvclient.get_secret(AZFINSIM_STORAGE_SAS_SECRET_ID)
    config.AZFINSIM_STORAGE_SAS_TOKEN = kvsecret.value
    log.debug("SAS Key: %s" % config.AZFINSIM_STORAGE_SAS_TOKEN)

    kvsecret = kvclient.get_secret(AZFINSIM_REDIS_SECRET_ID)
    config.AZFINSIM_REDISKEY = kvsecret.value
    log.debug("Redis Key: %s" % config.AZFINSIM_REDISKEY)

    kvsecret = kvclient.get_secret(AZFINSIM_ACR_SECRET_ID)
    config.AZFINSIM_ACR_KEY = kvsecret.value
    log.debug("ACR Key: %s" % config.AZFINSIM_ACR_KEY)

    kvsecret = kvclient.get_secret(AZFINSIM_APPINSIGHTS_SECRET_ID)
    config.APP_INSIGHTS_INSTRUMENTATION_KEY = kvsecret.value
    log.debug("App Insights Key: %s" % config.APP_INSIGHTS_INSTRUMENTATION_KEY)