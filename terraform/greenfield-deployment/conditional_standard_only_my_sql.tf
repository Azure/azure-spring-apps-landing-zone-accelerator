##################################################
### VNET Injection setup
##################################################

# Data Services Subnet
resource "azurerm_subnet" "mysql-azuresbclouddata" {

  # Only execute if Standard Tier
  count = (var.skuTier == "Standard" || var.skuTier == "standard" ? 1 : 0)

  name                  = var.springboot-data-subnet-name
  resource_group_name   = azurerm_resource_group.spoke_sc_corp_rg.name
  virtual_network_name  = azurerm_virtual_network.spoke.name
  address_prefixes      = [var.springboot-data-subnet-addr]
  service_endpoints     = ["Microsoft.Storage"]
  
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

# DNS Zone
resource "azurerm_private_dns_zone" "mysql_zone" {
  
  # Only execute if Standard Tier
  count = (var.skuTier == "Standard" || var.skuTier == "standard" ? 1 : 0)
  
  name                = "private.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.hub_sc_corp_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "ms-hub-link" {

  # Only execute if Standard Tier
  count = (var.skuTier == "Standard" || var.skuTier == "standard" ? 1 : 0)

  name                  = "mysql-zone-hub-link"
  resource_group_name   = azurerm_resource_group.hub_sc_corp_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.mysql_zone[0].name
  virtual_network_id    = azurerm_virtual_network.hub.id 
}

resource "azurerm_private_dns_zone_virtual_network_link" "ms-spoke-link" {

  # Only execute if Standard Tier
  count = (var.skuTier == "Standard" || var.skuTier == "standard" ? 1 : 0)

  name                  = "mysql-zone-spoke-link"
  resource_group_name   = azurerm_resource_group.hub_sc_corp_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.mysql_zone[0].name
  virtual_network_id    = azurerm_virtual_network.spoke.id
}


##################################################
### MYSQL Service
##################################################

resource "azurerm_mysql_flexible_server" "mysql" {

  # Only execute if Standard Tier
  count = (var.skuTier == "Standard" || var.skuTier == "standard" ? 1 : 0)

  name                = "${var.mysql_server_name_prefix}-${random_string.random.result}"
  location            = var.location
  resource_group_name = azurerm_resource_group.spoke_sc_corp_rg.name

  administrator_login    = var.jump_host_admin_username
  administrator_password = var.jump_host_password

  version = "5.7"
  sku_name               = "B_Standard_B1ms"
  backup_retention_days  = 7
  geo_redundant_backup_enabled = false

  storage {
    auto_grow_enabled = true
    iops              = 360
    size_gb           = 20
  }

  delegated_subnet_id    = azurerm_subnet.mysql-azuresbclouddata[0].id
  private_dns_zone_id    = azurerm_private_dns_zone.mysql_zone[0].id

  lifecycle {
    ignore_changes = [
      zone
    ]
  }


  depends_on = [azurerm_private_dns_zone_virtual_network_link.ms-hub-link[0],
                azurerm_private_dns_zone_virtual_network_link.ms-spoke-link[0]
                ]
}


