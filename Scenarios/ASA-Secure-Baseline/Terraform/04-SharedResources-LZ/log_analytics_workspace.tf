resource "azurerm_log_analytics_workspace" "sc_law" {
  name                = "${var.name_prefix}-law"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.shared_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30


}

