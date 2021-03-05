output "hub_vnet_name" { 
    description     = "Hub VNET Name"
    value           = azurerm_virtual_network.hub.name
}

output "hub_vnet_id" {
    description     = "Hub VNET Id"
    value           = azurerm_virtual_network.hub.id 
}

output "hub_address_space" { 
    description     = "Hub Address Space"
    value           = azurerm_virtual_network.hub.address_space
}

output "spoke_vnet_name" {
    description     = "Spoke VNET Name"
    value           = azurerm_virtual_network.spoke.name
}

output "spoke_vnet_id" {
    description     = "Spoke VNET Id"
    value           = azurerm_virtual_network.spoke.id
}

output "spoke_address_space" { 
    description     = "Spoke Address Space"
    value           = azurerm_virtual_network.spoke.address_space
}

output "azure_firewall_private_ip" { 
    description     = "Azure FW Private IP"
    value           = module.azure_firewall.ip
}

output "sc_rt_subnetid" {
    value = azurerm_subnet.azuresbcloudsvc.id
}
output "sc_apps_subnetid" {
    value = azurerm_subnet.azuresbcloudapps.id
}

output "sc_support_subnetid" {
    value = azurerm_subnet.azuresbcloudsupport.id
}

output "sc_data_subnetid" {
    value = azurerm_subnet.azuresbclouddata.id
}

output "sc_default_apps_route" {
   value = azurerm_route_table.default_apps_route.id
}
output "sc_default_runtime_route" {
   value = azurerm_route_table.default_runtime_route.id
}