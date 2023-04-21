
variable "postgresql_CIDR" {
  type    = string
  default = "10.1.6.0/24"

}

# Generate Admin User for Postgresql Server
resource "random_password" "admin" {
  length  = 16
  special = false
  numeric = false
  upper   = false
}

# Generate Password for Postgresql Server
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

variable "redis_CIDR" {
  type    = string
  default = "10.1.7.0/24"

}
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

resource "azurerm_redis_cache" "example" {
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

resource "azurerm_subnet" "postgresql_subnet" {
  name                 = "snet-postgres"
  resource_group_name  = data.azurerm_resource_group.spoke_rg.name
  virtual_network_name = data.azurerm_virtual_network.spoke_vnet.name
  address_prefixes     = ["${var.postgresql_CIDR}"]
  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_network_security_group" "postgres" {
  name                = "snet-psql-nsg"
  location            = data.azurerm_resource_group.spoke_rg.location
  resource_group_name = data.azurerm_resource_group.spoke_rg.name
}

resource "azurerm_private_dns_zone" "postgres" {
  name                = "private.postgres.database.azure.com"
  resource_group_name = data.azurerm_resource_group.private_zones_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name = "postgres-spoke-link"

  resource_group_name   = data.azurerm_resource_group.private_zones_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  virtual_network_id    = data.azurerm_virtual_network.spoke_vnet.id
}

# Postgresql Flexible Server
resource "azurerm_postgresql_flexible_server" "postgresql_server" {
  name                   = "${var.project_name}-db-server"
  resource_group_name    = data.azurerm_resource_group.springapps_rg.name
  location               = data.azurerm_resource_group.springapps_rg.location
  version                = "13"
  administrator_login    = random_password.admin.result
  administrator_password = random_password.password.result
  sku_name               = "GP_Standard_D4s_v3"
  storage_mb             = 32768
  zone                   = "1"
  delegated_subnet_id    = azurerm_subnet.postgresql_subnet.id
  private_dns_zone_id    = azurerm_private_dns_zone.postgres.id

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.postgres
  ]

}

# Allow connections from other Azure Services
resource "azurerm_postgresql_flexible_server_firewall_rule" "postgresql_server_fw" {
  name             = "${var.project_name}-db-server-fw"
  server_id        = azurerm_postgresql_flexible_server.postgresql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Enable the uuid-ossp extension
resource "azurerm_postgresql_flexible_server_configuration" "postgresql_server_config" {
  name      = local.azure-metadeta
  server_id = azurerm_postgresql_flexible_server.postgresql_server.id
  value     = "uuid-ossp"
}

# Acme Fitness Order Postgresql DB
resource "azurerm_postgresql_flexible_server_database" "postgres_order_service_db" {
  name      = var.order_service_db_name
  server_id = azurerm_postgresql_flexible_server.postgresql_server.id
  collation = "en_US.utf8"
  charset   = "utf8"
}

# Acme Fitness Catalog Postgresql DB
resource "azurerm_postgresql_flexible_server_database" "postgres_catalog_service_db" {
  name      = var.catalog_service_db_name
  server_id = azurerm_postgresql_flexible_server.postgresql_server.id
  collation = "en_US.utf8"
  charset   = "utf8"
}
