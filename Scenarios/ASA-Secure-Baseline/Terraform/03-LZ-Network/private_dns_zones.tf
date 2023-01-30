
# Azure Spring apps DNS ZONE
resource "azurerm_private_dns_zone" "spring_cloud_zone" {
  provider = azurerm.hub-subscription

  name                = var.springapps_dnszone_name
  resource_group_name = data.azurerm_resource_group.hub_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "hub-link" {
  provider = azurerm.hub-subscription

  name                  = "azure-spring-cloud-hub-link"
  resource_group_name   = data.azurerm_resource_group.hub_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.spring_cloud_zone.name
  virtual_network_id    = data.azurerm_virtual_network.hub_vnet.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "spoke-link" {
  provider = azurerm.hub-subscription
  
  name                  = "azure-spring-cloud-spoke-link"
  resource_group_name   = data.azurerm_resource_group.hub_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.spring_cloud_zone.name
  virtual_network_id    = azurerm_virtual_network.spoke_vnet.id
}

# Azure KeyVault Private Link DNS Zone
resource "azurerm_private_dns_zone" "keyvault_zone" {
  provider = azurerm.hub-subscription

  name                = var.keyvault_dnszone_name
  resource_group_name = data.azurerm_resource_group.hub_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "kv-hub-link" {
  provider = azurerm.hub-subscription

  name                  = "keyvault-zone-hub-link"
  resource_group_name   = data.azurerm_resource_group.hub_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.keyvault_zone.name
  virtual_network_id    = data.azurerm_virtual_network.hub_vnet.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "kv-spoke-link" {
  provider = azurerm.hub-subscription

  name                  = "keyvault-zone-spoke-link"
  resource_group_name   = data.azurerm_resource_group.hub_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.keyvault_zone.name
  virtual_network_id    = azurerm_virtual_network.spoke_vnet.id
}








