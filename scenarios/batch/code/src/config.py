import os
###############################################################################
## Read environment variables set from the configuration file
###############################################################################
#-- batch service principal
AZURE_CLIENT_ID=os.environ['AZURE_CLIENT_ID']
AZURE_CLIENT_SECRET=os.environ['AZURE_CLIENT_SECRET']
AZURE_TENANT_ID=os.environ['AZURE_TENANT_ID']
AZFINSIM_PRINCIPAL=os.environ['AZFINSIM_PRINCIPAL']
#-- azure batch account details
AZFINSIM_ENDPOINT = os.environ['AZFINSIM_ENDPOINT']
AZFINSIM_AUTOSCALE_POOL = os.environ['AZFINSIM_AUTOSCALE_POOL']
AZFINSIM_REALTIME_POOL = os.environ['AZFINSIM_REALTIME_POOL']
#-- key vault details
AZFINSIM_KV_NAME = os.environ['AZFINSIM_KV_NAME']
AZFINSIM_KV_URL = os.environ['AZFINSIM_KV_URL']
AZFINSIM_STORAGE_SAS_SECRET_ID = os.environ['AZFINSIM_STORAGE_SAS_SECRET_ID']
AZFINSIM_REDIS_SECRET_ID = os.environ['AZFINSIM_REDIS_SECRET_ID']
AZFINSIM_APPINSIGHTS_SECRET_ID = os.environ['AZFINSIM_APPINSIGHTS_SECRET_ID']
AZFINSIM_ACR_SECRET_ID = os.environ['AZFINSIM_ACR_SECRET_ID']
#-- retrieved keyvault global variables (not set in environment)
AZFINSIM_STORAGE_SAS_TOKEN=""
AZFINSIM_REDISKEY=""
AZFINSIM_ACR_KEY=""
APP_INSIGHTS_INSTRUMENTATION_KEY=""
#-- batch storage details
AZFINSIM_STORAGE_ACCOUNT = os.environ['AZFINSIM_STORAGE_ACCOUNT']
AZFINSIM_STORAGE_CONTAINER_URI = os.environ['AZFINSIM_STORAGE_CONTAINER_URI']
#-- redis details
AZFINSIM_REDISPORT = os.environ['AZFINSIM_REDISPORT']
AZFINSIM_REDISSSL = os.environ['AZFINSIM_REDISSSL']
AZFINSIM_REDISHOST = os.environ['AZFINSIM_REDISHOST']
#-- application insights
APP_INSIGHTS_APP_ID = os.environ['APP_INSIGHTS_APP_ID']
#-- container registry details
AZFINSIM_ACR = os.environ['AZFINSIM_ACR']
AZFINSIM_ACR_REPO = os.environ['AZFINSIM_ACR_REPO']
AZFINSIM_ACR_USER = os.environ['AZFINSIM_ACR_USER']
AZFINSIM_ACR_SIM = os.environ['AZFINSIM_ACR_SIM']
AZFINSIM_ACR_IMAGE = os.environ['AZFINSIM_ACR_IMAGE']
###############################################################################