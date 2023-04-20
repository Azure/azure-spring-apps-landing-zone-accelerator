resource "azurerm_application_insights" "sc_app_insights" {
  name                = local.app_insights_name
  location            = var.location
  resource_group_name = azurerm_resource_group.springapps_rg.name
  workspace_id        = data.azurerm_log_analytics_workspace.sc_law.id
  application_type    = "web"
  
  tags = var.tags  
}
