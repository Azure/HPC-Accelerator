#-- Keyvault - name must be unique due to soft delete retaining the vault 
resource "azurerm_key_vault" "azfinsim" {
  name                                = format("%svault-%s", var.prefix, random_string.suffix.result)
  resource_group_name                 = azurerm_resource_group.azfinsim.name
  location                            = azurerm_resource_group.azfinsim.location
  tenant_id                           = data.azurerm_client_config.current.tenant_id
  sku_name                            = "standard"
  enabled_for_deployment              = true
  enabled_for_template_deployment     = true
  #-- no longer required, enabled by default
  #soft_delete_enabled                 = true
  soft_delete_retention_days          = 7
  purge_protection_enabled            = false

  #-- bug in cloudshell makes client_config.object_id blank, so use the one we queried from the cli
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    #object_id = data.azurerm_client_config.current.object_id
    object_id = data.external.UserAccount.result.objectId
    key_permissions = [
    ]
    secret_permissions = [
      "Get",
      "Set",
      "List",
      "Delete",
      "Purge"
    ]
    storage_permissions = [
    ]
  }

  #-- delegate access to azfinsim service principal
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azuread_service_principal.azfinsim.id
 
    key_permissions = [
    ]
    secret_permissions = [
      "Get",
      "Set",
      "List",
      "Delete",
      "Purge"
    ]
  }
  #-- delegate access to Microsoft Azure Batch service
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.external.batchservice.result.objectId
 
    key_permissions = [
    ]
    secret_permissions = [
      "Get",
      "Set",
      "List",
      "Delete",
	  "Recover"
    ]
  }
  tags = local.resource_tags
}
