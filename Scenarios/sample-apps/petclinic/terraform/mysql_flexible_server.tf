resource "random_string" "random" {
  length  = 4
  upper   = false
  special = false
}

locals {
  mysql_server_name = "pcsms-db-${lower(var.resource_group)}-${random_string.random.result}"
}

resource "azurerm_subnet" "mysql" {
  name                 = "snet-mysql"
  resource_group_name  = data.azurerm_resource_group.spoke_rg.name
  virtual_network_name = data.azurerm_virtual_network.spoke.name
  address_prefixes     = ["${var.mysql_CIDR}"]
  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_network_security_group" "asa_svc_nsg" {
  name                = "snet-mysql-nsg"
  location            = data.azurerm_resource_group.spoke_rg.location
  resource_group_name = data.azurerm_resource_group.spoke_rg.name
}

resource "azurerm_private_dns_zone" "mysql" {
  name                = "private.mysql.database.azure.com"
  resource_group_name = data.azurerm_resource_group.private_zones_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "mysql" {
  name = "mysql-spoke-link"

  resource_group_name   = data.azurerm_resource_group.private_zones_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.mysql.name
  virtual_network_id    = data.azurerm_virtual_network.spoke.id
}

resource "azurerm_mysql_flexible_server" "mysql" {
  name                   = local.mysql_server_name
  resource_group_name    = data.azurerm_resource_group.spring_apps_rg.name
  location               = data.azurerm_resource_group.spring_apps_rg.location
  administrator_login    = var.mysql_server_admin_username
  administrator_password = var.mysql_server_admin_password
  backup_retention_days  = 7
  delegated_subnet_id    = azurerm_subnet.mysql.id
  private_dns_zone_id    = azurerm_private_dns_zone.mysql.id
  sku_name               = "GP_Standard_D2ds_v4"

  lifecycle {
    ignore_changes = [
      zone
    ]
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.mysql]
}

resource "azurerm_mysql_flexible_database" "petclinic_database" {
  name                = var.mysql_database_name
  resource_group_name = data.azurerm_resource_group.spring_apps_rg.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

resource "azurerm_mysql_flexible_server_firewall_rule" "allazureips" {
  name                = "allAzureIPs"
  resource_group_name = data.azurerm_resource_group.spring_apps_rg.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_mysql_flexible_server_configuration" "timeout" {
  name                = "interactive_timeout"
  resource_group_name = data.azurerm_resource_group.spring_apps_rg.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  value               = "2147483"
}

resource "azurerm_mysql_flexible_server_configuration" "time_zone" {
  name                = "time_zone"
  resource_group_name = data.azurerm_resource_group.spring_apps_rg.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  value               = "-8:00" // Add appropriate offset based on your region.
  depends_on = [
    azurerm_mysql_flexible_server.mysql
  ]
}
