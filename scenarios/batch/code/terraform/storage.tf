#-- Storage Account
resource "azurerm_storage_account" "azfinsim" {
  name                     = format("%sstorage", var.prefix)
  resource_group_name      = azurerm_resource_group.azfinsim.name
  location                 = azurerm_resource_group.azfinsim.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Hot"
  #allow_blob_public_access = true
  tags                      = local.resource_tags
}

#-- Storage Container
resource "azurerm_storage_container" "azfinsim" {
  name                  = "azfinsim"
  storage_account_name  = azurerm_storage_account.azfinsim.name
  container_access_type = "private"
}

#-- Create Storage Container Level SAS Key
data "azurerm_storage_account_blob_container_sas" "azfinsim" {
  connection_string = azurerm_storage_account.azfinsim.primary_connection_string
  container_name    = azurerm_storage_container.azfinsim.name
  https_only        = true

  #ip_address = "X.X.X.X"

  start  = "2021-01-01"
  expiry = "2025-01-01"

  permissions {
    read   = true
    add    = true
    create = true
    write  = true
    delete = true
    list   = true
  }
}
