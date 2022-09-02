#-- Add secrets to keyvault 
resource "azurerm_key_vault_secret" "redis" {
  name         = format("AzFinSimRedisKey-%s", random_string.suffix.result)
  value        = azurerm_redis_cache.azfinsim.primary_access_key
  key_vault_id = azurerm_key_vault.azfinsim.id
}
resource "azurerm_key_vault_secret" "storage" {
  name         = format("AzFinSimStorageSas-%s", random_string.suffix.result)
  value        = data.azurerm_storage_account_blob_container_sas.azfinsim.sas
  key_vault_id = azurerm_key_vault.azfinsim.id
}
resource "azurerm_key_vault_secret" "azcr" {
  name         = format("AzFinSimACRKey-%s", random_string.suffix.result)
  value        = azurerm_container_registry.azfinsim.admin_password
  key_vault_id = azurerm_key_vault.azfinsim.id
}
resource "azurerm_key_vault_secret" "appinsights" {
  name         = format("AzFinSimAppInsightsKey-%s", random_string.suffix.result)
  value        = azurerm_application_insights.azfinsim.instrumentation_key
  key_vault_id = azurerm_key_vault.azfinsim.id
}
