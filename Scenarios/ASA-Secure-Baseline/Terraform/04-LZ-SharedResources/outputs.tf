output shared_rg {
    value = azurerm_resource_group.shared_rg.name
}

output law_name {
    value = azurerm_log_analytics_workspace.sc_law.name
}

output PASSWORD_NOTICE {
    value = local.password_notice
}