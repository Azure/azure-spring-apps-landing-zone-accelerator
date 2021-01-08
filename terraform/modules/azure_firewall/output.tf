output "ip" { 
    description     = "Azure Firewall IP Address"
    value           = azurerm_firewall.azure_firewall_instance.ip_configuration[0].private_ip_address
}
