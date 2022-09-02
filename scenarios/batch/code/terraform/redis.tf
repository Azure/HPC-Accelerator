#-- Redis Cache: Premium P1 
# NOTE: the Name used for Redis needs to be globally unique
resource "azurerm_redis_cache" "azfinsim" {
  name                = format("%scache", var.prefix)
  resource_group_name = azurerm_resource_group.azfinsim.name
  location            = azurerm_resource_group.azfinsim.location
  capacity            = 1
  family              = "P"
  sku_name            = "Premium"
  enable_non_ssl_port = true
  minimum_tls_version = "1.2"

  redis_configuration {
  }
  tags                = local.resource_tags
}
