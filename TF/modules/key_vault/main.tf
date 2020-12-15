
data "azurerm_client_config" "current" {}

resource "random_string" "number" {
  length  = 6
  upper   = false
  lower   = false
  number  = true
  special = false
}

locals {
  //full_keyvault_name = "${var.keyvault_name}-${tostring(random_string.number.result)}"
  full_keyvault_name = join("",
            [var.keyvault_name],
            [random_string.number.result])
}

resource "azurerm_key_vault" "sc_vault" {
  name                = local.full_keyvault_name
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