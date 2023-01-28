output shared_rg {
    value = azurerm_resource_group.shared_rg.name
}

output law_name {
    value = azurerm_log_analytics_workspace.sc_law.name
}

output jump_host_name {
    value = local.jumphost_name
}
output jump_host_IP {
    value = var.jump_host_private_ip_addr
}
output jump_host_user {
    value = local.jumphost_user
}

output jump_host_pass {
    value = "To get Password, run: az keyvault secret show --name jumphost-password --vault-name ${azurerm_key_vault.sc_vault.name} -o table"
}