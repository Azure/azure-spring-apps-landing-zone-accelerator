resource "azurerm_log_analytics_workspace" "sc_law" {
  name                = "sc-law-${random_string.random.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "random_string" "random" {
  length = 8
  upper = false
  special = false

}