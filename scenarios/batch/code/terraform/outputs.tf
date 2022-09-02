# Comment out or mark "sensitive" any content you don't want visible in output

#-- subscription & service principal
output "subscription_id" {
  value =  data.azurerm_client_config.current.subscription_id
  sensitive = false
}
output "tenant_id" {
  value =  data.azurerm_client_config.current.tenant_id
  sensitive = false
}
output "application_id" {
  value = azuread_application.azfinsim.application_id
  sensitive = false
}
output "sp_name" {
  value = "azfinsim" # azuread_application.azfinsim.name
  sensitive = false
}
output "sp_password" {
  value = azuread_service_principal_password.azfinsim.value 
  sensitive = true
}

#-- keyvault
output "keyvault_uri" {
  value     = azurerm_key_vault.azfinsim.vault_uri
  sensitive = false
}
output "keyvault_name" {
  value     = azurerm_key_vault.azfinsim.name
  sensitive = false
}
output "keyvault_id" {
  value     = azurerm_key_vault.azfinsim.id
  sensitive = false
}
#-- storage 
output "primary_blob_endpoint" {
  value     = azurerm_storage_account.azfinsim.primary_blob_endpoint
  sensitive = false
}
output "primary_blob_connection_string" {
  value     = azurerm_storage_account.azfinsim.primary_connection_string
  sensitive = true
}
output "storage_account_name" {
  value     = azurerm_storage_account.azfinsim.name
  sensitive = false
}
output "container_name" {
  value     = azurerm_storage_container.azfinsim.name
  sensitive = false
}
#-- container sas key
output "sas_url_query_string" {
  value               = data.azurerm_storage_account_blob_container_sas.azfinsim.sas
  sensitive            = true
}

#-- container registry
output "azcr_username" {
  value     = azurerm_container_registry.azfinsim.admin_username
  sensitive = false
}
output "azcr_server" {
  value     = azurerm_container_registry.azfinsim.login_server
  sensitive = false
}

#-- redis 
output "redis_hostname" {
  value     = azurerm_redis_cache.azfinsim.hostname
  sensitive = false
}
output "redis_ssl_port" {
  value     = azurerm_redis_cache.azfinsim.ssl_port
  sensitive = false
}

#-- application insights creds 
output "appinsights_instrumentation_key" {
  value         = azurerm_application_insights.azfinsim.instrumentation_key
  sensitive     = true
}
output "appinsights_app_id" {
  value         = azurerm_application_insights.azfinsim.app_id
  sensitive     = false
}

#-- symbolic names for keyvault secret retrieval
output "acr_secret_name" {
  value         = azurerm_key_vault_secret.azcr.name
  sensitive     = false
}
output "storage_sas_secret_name" {
  value         = azurerm_key_vault_secret.storage.name
  sensitive     = false
}
output "redis_secret_name" {
  value         = azurerm_key_vault_secret.redis.name
  sensitive     = false
}
output "appinsights_secret_name" {
  value         = azurerm_key_vault_secret.appinsights.name
  sensitive     = false
}

#-- batch
output "batch_account_endpoint" {
  value     = azurerm_batch_account.azfinsim.account_endpoint
  sensitive = false
}
#output "realtimestatic_pool_id" {
#  value     = azurerm_batch_pool.realtimestatic.id
#  sensitive = false
#}
#output "autoscale_pool_id" {
#  value     = azurerm_batch_pool.autoscale.id
#  sensitive = false
#}
output "autoscale_pool_name" {
    value     = azurerm_batch_pool.autoscale.name
    sensitive = false
}
output "realtimestatic_pool_name" {
    value     = azurerm_batch_pool.realtimestatic.name
    sensitive = false
}