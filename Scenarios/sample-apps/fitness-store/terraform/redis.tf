
resource "random_string" "random_redis" {
  length  = 4
  upper   = false
  special = false
}
locals {
  redis_name = "acme-redis-fitness-${random_string.random_redis.result}"
}


resource "azurerm_subnet" "redis" {
  name                 = "snet-redis"
  resource_group_name  = data.azurerm_resource_group.spoke_rg.name
  virtual_network_name = data.azurerm_virtual_network.spoke_vnet.name
  address_prefixes     = ["${var.redis_CIDR}"]

}

resource "azurerm_network_security_group" "redis" {
  name                = "snet-redis-nsg"
  location            = data.azurerm_resource_group.spoke_rg.location
  resource_group_name = data.azurerm_resource_group.spoke_rg.name
}

resource "azurerm_subnet_network_security_group_association" "redis" {
  subnet_id                 = azurerm_subnet.redis.id
  network_security_group_id = azurerm_network_security_group.redis.id
}

resource "azurerm_private_dns_zone" "redis" {
  name                = "private.redis.cache.windows.net"
  resource_group_name = data.azurerm_resource_group.private_zones_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "redis" {
  name = "redis-spoke-link"

  resource_group_name   = data.azurerm_resource_group.private_zones_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.redis.name
  virtual_network_id    = data.azurerm_virtual_network.spoke_vnet.id
}

resource "azurerm_redis_cache" "redis" {
  name                = local.redis_name
  location            = data.azurerm_resource_group.springapps_rg.location
  resource_group_name = data.azurerm_resource_group.springapps_rg.name
  capacity            = 2
  family              = "P"
  sku_name            = "Premium"
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"
  subnet_id           = azurerm_subnet.redis.id

  redis_configuration {
  }
}
