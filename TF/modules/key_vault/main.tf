
data "azurerm_client_config" "current" {}

resource "random_string" "number" {
  length  = 6
  upper   = false
  lower   = false
  number  = true
  special = false
}

locals {

  keyvault_name = join("",
            [var.keyvault_prefix],
            [random_string.number.result])
}

resource "azurerm_private_dns_zone" "keyvault_zone" {
  name                = "private.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "hub-link" {
  name                  = "keyvault-zone-hub-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.keyvault_zone.name
  virtual_network_id    = var.hub_virtual_network_id
}

resource "azurerm_private_dns_zone_virtual_network_link" "spoke-link" {
  name                  = "keyvault-zone-spoke-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.keyvault_zone.name
  virtual_network_id    = var.spoke_virtual_network_id
}

resource "azurerm_key_vault" "sc_vault" {
  name                = local.keyvault_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  soft_delete_enabled        = true
  purge_protection_enabled   = false
  soft_delete_retention_days = 7
/*
  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    virtual_network_subnet_ids = [
      azurerm_subnet.adx1.id,
      azurerm_subnet.adx2.id,
      azurerm_subnet.adx3.id
    ]
    ip_rules = [
      "${chomp(data.http.myip.body)}/32"
    ]
  }*/

}

resource "azurerm_private_endpoint" "keyvault-endpoint" {
  name                = "keyvault-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.sc_support_subnetid

  private_service_connection {
    name                           = "example-privateserviceconnection"
    private_connection_resource_id = azurerm_key_vault.sc_vault.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  private_dns_zone_group {
    name                          = azurerm_private_dns_zone.keyvault_zone.name
    private_dns_zone_ids = [ azurerm_private_dns_zone.keyvault_zone.id ]
  }     
}