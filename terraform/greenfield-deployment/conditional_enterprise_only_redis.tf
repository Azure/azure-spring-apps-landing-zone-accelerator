
resource "azurerm_private_dns_zone" "redis_zone" {
  
  # Only execute if Enterprise tier
  count = (var.skuTier == "Enterprise" || var.skuTier == "enterprise" ? 1 : 0)

  name                = "privatelink.redis.cache.azure.com"
  resource_group_name = azurerm_resource_group.hub_sc_corp_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "redis-hub-link" {

  # Only execute if Enterprise tier
  count = (var.skuTier == "Enterprise" || var.skuTier == "enterprise" ? 1 : 0)

  name                  = "redis-zone-hub-link"
  resource_group_name   = azurerm_resource_group.hub_sc_corp_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.redis_zone[0].name
  virtual_network_id    = azurerm_virtual_network.hub.id 
}

resource "azurerm_private_dns_zone_virtual_network_link" "redis-spoke-link" {

  # Only execute if Enterprise tier
  count = (var.skuTier == "Enterprise" || var.skuTier == "enterprise" ? 1 : 0)

  name                  = "redis-zone-spoke-link"
  resource_group_name   = azurerm_resource_group.hub_sc_corp_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.redis_zone[0].name
  virtual_network_id    = azurerm_virtual_network.spoke.id
}


resource "azurerm_redis_cache" "rediscache" {

  # Only execute if Enterprise tier
  count = (var.skuTier == "Enterprise" || var.skuTier == "enterprise" ? 1 : 0)
  
  name                = "${var.redis_cache_name_prefix}-${random_string.random.result}"
  location            = var.location
  resource_group_name = azurerm_resource_group.spoke_sc_corp_rg.name

  capacity            = 0
  family              = "C"
  sku_name            = "Basic"
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"
  public_network_access_enabled = false

  redis_configuration {
  }
}



resource "azurerm_private_endpoint" "redis-endpoint" {
  name                = "sc-redis-endpoint"
  location            = var.location
  resource_group_name = azurerm_resource_group.spoke_sc_corp_rg.name
  subnet_id           = azurerm_subnet.azuresbcloudsupport.id

  private_service_connection {
    name                           = "redis-private-link-connection"
    private_connection_resource_id = azurerm_redis_cache.rediscache[0].id
    is_manual_connection           = false
    subresource_names              = ["redisCache"]
  }

  private_dns_zone_group {
    name                          = azurerm_private_dns_zone.redis_zone[0].name
    private_dns_zone_ids          = [ azurerm_private_dns_zone.redis_zone[0].id ]
  }

  depends_on = [
    azurerm_subnet.azuresbcloudsupport,
    azurerm_subnet_network_security_group_association.support_svc_nsg_assoc
  ]

}