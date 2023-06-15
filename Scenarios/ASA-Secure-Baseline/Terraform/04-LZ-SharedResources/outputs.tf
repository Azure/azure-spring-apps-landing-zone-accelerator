output "shared_rg" {
  value = azurerm_resource_group.shared_rg.name
}

output "law_name" {
  value = azurerm_log_analytics_workspace.sc_law.name
}

output "PASSWORD_NOTICE" {
  value = local.password_notice
}

output "jump_host_name" {
  value = local.jumphost_name
}
output "jump_host_IP" {
  value = var.jump_host_private_ip_addr
}
output "jump_host_user" {
  value = local.jumphost_user
}
