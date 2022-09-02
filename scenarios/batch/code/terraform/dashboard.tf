resource "azurerm_portal_dashboard" "azfinsim" {
  name                = format("%s-dashboard",var.prefix)
  resource_group_name = azurerm_resource_group.azfinsim.name
  location            = azurerm_resource_group.azfinsim.location
  tags = {
    source = "terraform"
  }
  dashboard_properties = templatefile("dash.tpl",
  {
      video_link        = "https://youtu.be/r5jxlwJQEPc",
      provider_path     = format("/subscriptions/%s/resourceGroups/%s/providers", data.azurerm_subscription.current.subscription_id, azurerm_resource_group.azfinsim.name)
      cache_name        = format("%s",azurerm_redis_cache.azfinsim.name)
  })
}