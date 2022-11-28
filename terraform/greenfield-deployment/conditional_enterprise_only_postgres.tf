##################################################
### VNET Injection setup
##################################################

# Data Services Subnet
resource "azurerm_subnet" "postgres-azuresbclouddata" {

  # Only execute if Enterprise tier
  count = (var.skuTier == "Enterprise" || var.skuTier == "enterprise" ? 1 : 0)

  name                  = var.springboot-data-subnet-name
  resource_group_name   = azurerm_resource_group.spoke_sc_corp_rg.name
  virtual_network_name  = azurerm_virtual_network.spoke.name
  address_prefixes      = [var.springboot-data-subnet-addr]
  
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

# DNS Zone
resource "azurerm_private_dns_zone" "postgres_zone" {
  
  # Only execute if Enterprise tier
  count = (var.skuTier == "Enterprise" || var.skuTier == "enterprise" ? 1 : 0)

  name                = "private.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.hub_sc_corp_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres-hub-link" {

  # Only execute if Enterprise tier
  count = (var.skuTier == "Enterprise" || var.skuTier == "enterprise" ? 1 : 0)

  name                  = "postgres-zone-hub-link"
  resource_group_name   = azurerm_resource_group.hub_sc_corp_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.postgres_zone[0].name
  virtual_network_id    = azurerm_virtual_network.hub.id 
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres-spoke-link" {

  # Only execute if Enterprise tier
  count = (var.skuTier == "Enterprise" || var.skuTier == "enterprise" ? 1 : 0)

  name                  = "postgres-zone-spoke-link"
  resource_group_name   = azurerm_resource_group.hub_sc_corp_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.postgres_zone[0].name
  virtual_network_id    = azurerm_virtual_network.spoke.id
}

##################################################
### POSTGRES Service
##################################################

resource "azurerm_postgresql_flexible_server" "postgres" {

  
  # Only execute if Enterprise tier
  count = (var.skuTier == "Enterprise" || var.skuTier == "enterprise" ? 1 : 0)

  name                = "${var.postgres_name_prefix}-${random_string.random.result}"
  location            = var.location
  resource_group_name = azurerm_resource_group.spoke_sc_corp_rg.name


  version                = "13"
  delegated_subnet_id    = azurerm_subnet.postgres-azuresbclouddata[0].id
  private_dns_zone_id    = azurerm_private_dns_zone.postgres_zone[0].id

  administrator_login    = var.jump_host_admin_username
  administrator_password = var.jump_host_password
  
  #131072 = 128GB
  storage_mb = 131072 

  sku_name   = "GP_Standard_D2ds_v4"

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  lifecycle {
    ignore_changes = [
      zone
    ]
  }

  depends_on = [
      azurerm_private_dns_zone_virtual_network_link.postgres-hub-link[0],
      azurerm_private_dns_zone_virtual_network_link.postgres-spoke-link[0],
      #Last Firewall rule is in!
      azurerm_firewall_application_rule_collection.SpringAppsRefArchApplicationRules
      ]

}

