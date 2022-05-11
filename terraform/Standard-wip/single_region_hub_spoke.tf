# Hub-Spoke VNET 
resource "azurerm_virtual_network" "hub" {
    name                        = var.hub_vnet_name
    location                    = var.location 
    resource_group_name         = azurerm_resource_group.sc_corp_rg.name
    address_space               = [var.hub_vnet_addr_prefix]
}

resource "azurerm_subnet" "appgwsubnet" {
  name                 = var.appgw-subnet-name
  resource_group_name = azurerm_resource_group.sc_corp_rg.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes       = [var.appgw-subnet-addr]
}

# Spoke VNET 
resource "azurerm_virtual_network" "spoke" {
    name                        = var.spoke_vnet_name
    location                    = var.location 
    resource_group_name         = azurerm_resource_group.sc_corp_rg.name
    address_space               = [var.spoke_vnet_addr_prefix]
    dns_servers                 = [azurerm_firewall.azure_firewall_instance.ip_configuration[0].private_ip_address]
}

# Spring Cloud Service Subnet
resource "azurerm_subnet" "azuresbcloudsvc" {
  name                 = var.springboot-service-subnet-name
  resource_group_name = azurerm_resource_group.sc_corp_rg.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes       = [var.springboot-service-subnet-addr]
}

# Spring Cloud Apps Subnet
resource "azurerm_subnet" "azuresbcloudapps" {
  name                 = var.springboot-apps-subnet-name
  resource_group_name = azurerm_resource_group.sc_corp_rg.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes       = [var.springboot-apps-subnet-addr]
}

# Data Services Subnet
resource "azurerm_subnet" "azuresbclouddata" {
  name                 = var.springboot-data-subnet-name
  resource_group_name = azurerm_resource_group.sc_corp_rg.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes       = [var.springboot-data-subnet-addr]
  enforce_private_link_endpoint_network_policies = true
}

# Supported Services Subnet, e.g. keyvault
resource "azurerm_subnet" "azuresbcloudsupport" {
  name                 = var.springboot-support-subnet-name
  resource_group_name = azurerm_resource_group.sc_corp_rg.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes       = [var.springboot-support-subnet-addr]
  enforce_private_link_endpoint_network_policies = true
}


# Hub-Spoke Peering
resource "azurerm_virtual_network_peering" "hub_spoke_peering" {
    name                        = "hub_spoke_peer"
    resource_group_name         = azurerm_resource_group.sc_corp_rg.name
    virtual_network_name        = azurerm_virtual_network.hub.name 
    remote_virtual_network_id   = azurerm_virtual_network.spoke.id 
}

resource "azurerm_virtual_network_peering" "spoke_hub_peering" {
    name                        = "spoke_hub_peer"
    resource_group_name         = azurerm_resource_group.sc_corp_rg.name
    virtual_network_name        = azurerm_virtual_network.spoke.name 
    remote_virtual_network_id   = azurerm_virtual_network.hub.id 
}

# # Azure Firewall 
# module "azure_firewall" { 
#     source                      = "../azure_firewall"
#     resource_group_name         = azurerm_resource_group.sc_corp_rg.name
#     location                    = var.location 
#     azurefw_name                = "${var.azurefw_name}-${random_string.random.result}"
#     azurefw_vnet_name           = azurerm_virtual_network.hub.name
#     azurefw_addr_prefix         = var.azurefw_addr_prefix
#     sc_law_id                   = azurerm_log_analytics_workspace.sc_law.id
# }

# # Azure Bastion
# module "azure_bastion" { 
#     source                      = "../azure_bastion"
#     resource_group_name         = azurerm_resource_group.sc_corp_rg.name
#     location                    = var.location
#     azurebastion_name           = var.azurebastion_name
#     azurebastion_vnet_name      = azurerm_virtual_network.hub.name
#     azurebastion_addr_prefix    = var.azurebastion_addr_prefix
# }

# Jump host

# module "jump_host" { 
#     source                              = "../jump_host"
#     resource_group_name                 = azurerm_resource_group.sc_corp_rg.name
#     location                            = var.location
#     jump_host_name                       = var.jump_host_name
#     jump_host_vnet_name                  = azurerm_virtual_network.hub.name
#     jump_host_addr_prefix                = var.jump_host_addr_prefix
#     jump_host_private_ip_addr            = var.jump_host_private_ip_addr
#     jump_host_vm_size                    = var.jump_host_vm_size
#     jump_host_admin_username             = var.jump_host_admin_username
#     jump_host_password                   = var.jump_host_password
# }

resource "azurerm_route_table" "default_apps_route" {
  name                          = "default_apps_route"
  resource_group_name                 = azurerm_resource_group.sc_corp_rg.name
  location                            = var.location

  route {
    name                        = "default_egress"
    address_prefix              = "0.0.0.0/0" 
    next_hop_type               = "VirtualAppliance"
    next_hop_in_ip_address      =  azurerm_firewall.azure_firewall_instance.ip_configuration[0].private_ip_address
  }

}

resource "azurerm_route_table" "default_runtime_route" {
  name                          = "default_runtime_route"
  resource_group_name                 = azurerm_resource_group.sc_corp_rg.name
  location                            = var.location

  route {
    name                        = "default_egress"
    address_prefix              = "0.0.0.0/0" 
    next_hop_type               = "VirtualAppliance"
    next_hop_in_ip_address      =  azurerm_firewall.azure_firewall_instance.ip_configuration[0].private_ip_address
  }

}

resource "azurerm_subnet_route_table_association" "sc_app_association" {
  subnet_id      = azurerm_subnet.azuresbcloudapps.id
  route_table_id = azurerm_route_table.default_apps_route.id
}

resource "azurerm_subnet_route_table_association" "sc_runtime_association" {
  subnet_id      = azurerm_subnet.azuresbcloudsvc.id
  route_table_id = azurerm_route_table.default_runtime_route.id
}

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
    value           = azurerm_firewall.azure_firewall_instance.ip_configuration[0].private_ip_address
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



