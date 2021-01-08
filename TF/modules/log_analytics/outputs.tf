output log_analytics_id {
    description     = "log analytics workspace ID"
    value = azurerm_log_analytics_workspace.sc_law.id
}