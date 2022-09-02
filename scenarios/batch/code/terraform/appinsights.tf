#-- Application insights
resource "azurerm_application_insights" "azfinsim" {
  name                = format("%s-appinsights", var.prefix)
  resource_group_name = azurerm_resource_group.azfinsim.name
  location            = azurerm_resource_group.azfinsim.location
  application_type    = "other"
  tags                = local.resource_tags
}
