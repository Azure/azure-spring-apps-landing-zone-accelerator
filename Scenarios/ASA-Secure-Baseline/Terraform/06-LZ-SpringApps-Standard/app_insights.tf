resource "azurerm_application_insights" "sc_app_insights" {
  name                = "${var.name_prefix}-ai"
  location            = var.location
  resource_group_name = azurerm_resource_group.springapps_rg.name
  workspace_id        = data.azurerm_log_analytics_workspace.sc_law.id
  application_type    = "web"
  
  tags = var.tags  
}
