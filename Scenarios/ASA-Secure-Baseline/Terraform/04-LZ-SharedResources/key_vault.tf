
resource "azurerm_key_vault" "sc_vault" {
  name                = local.keyvault_name
  location            = var.location
  resource_group_name = azurerm_resource_group.shared_rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  purge_protection_enabled   = false
  soft_delete_retention_days = 7

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules = [ ]
 
  }
 access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    certificate_permissions = [
      "Backup",
      "Create",
      "Delete",
      "DeleteIssuers",
      "Get",
      "GetIssuers",
      "Import",
      "List",
      "ListIssuers",
      "ManageContacts",
      "ManageIssuers",
      "Purge",
      "Recover",
      "Restore",
      "SetIssuers",
      "Update"
    ]

    key_permissions = [
      "List",
      "Encrypt",
      "Decrypt",
      "WrapKey",
      "UnwrapKey",
      "Sign",
      "Verify",
      "Get",
      "Create",
      "Update",
      "Import",
      "Backup",
      "Restore",
      "Recover",
      "Delete",
      "Purge"
    ]

    secret_permissions = [
      "List",
      "Get",
      "Set",
      "Backup",
      "Restore",
      "Recover",
      "Purge",
      "Delete"
    ]

    storage_permissions = [
      "Backup",
      "Delete",
      "DeleteSAS",
      "Get",
      "GetSAS",
      "ListSAS",
      "Purge",
      "Recover",
      "RegenerateKey",
      "Restore",
      "Set",
      "SetSAS",
      "Update"
    ]
  }

  tags = var.tags

}


resource "azurerm_private_endpoint" "keyvault-endpoint" {
  name                = "sc-keyvault-endpoint"
  location            = var.location
  resource_group_name = azurerm_resource_group.shared_rg.name
  subnet_id           = data.azurerm_subnet.azuresbcloudsupport.id

  private_service_connection {
    name                           = "kv-private-link-connection"
    private_connection_resource_id = azurerm_key_vault.sc_vault.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  private_dns_zone_group {
    name                          = var.keyvault_dnszone_name
    private_dns_zone_ids          = [ data.azurerm_private_dns_zone.keyvault_zone.id ]
  }

  tags = var.tags

}


