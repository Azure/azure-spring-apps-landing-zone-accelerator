resource "azurerm_log_analytics_workspace" "sc_law" {
  name                = local.law_name
  location            = var.location
  resource_group_name = azurerm_resource_group.shared_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = var.tags
}

