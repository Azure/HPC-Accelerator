#-- Container Registry 
resource "azurerm_container_registry" "azfinsim" {
  name                = format("%sazcr", var.prefix)
  resource_group_name = azurerm_resource_group.azfinsim.name
  location            = azurerm_resource_group.azfinsim.location
  sku                 = "Premium"
  admin_enabled       = true
  tags                = local.resource_tags
}
