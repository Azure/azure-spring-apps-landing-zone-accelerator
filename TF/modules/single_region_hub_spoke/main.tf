# Hub-Spoke VNET 
resource "azurerm_virtual_network" "hub" {
    name                        = var.hub_vnet_name
    location                    = var.location 
    resource_group_name         = var.resource_group_name
    address_space               = [var.hub_vnet_addr_prefix]
    tags                        = var.tags
}

# Spoke VNET 
resource "azurerm_virtual_network" "spoke" {
    name                        = var.spoke_vnet_name
    location                    = var.location 
    resource_group_name         = var.resource_group_name
    address_space               = [var.spoke_vnet_addr_prefix]
    dns_servers                 = [module.azure_firewall.ip]
    tags                        = var.tags
}

resource "azurerm_subnet" "azuresbcloudsvc" {
  name                 = var.springboot-service-subnet-name
  resource_group_name = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes       = [var.springboot-service-subnet-addr]
}

resource "azurerm_subnet" "azuresbcloudapps" {
  name                 = var.springboot-apps-subnet-name
  resource_group_name = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes       = [var.springboot-apps-subnet-addr]
}


# Hub-Spoke Peering
resource "azurerm_virtual_network_peering" "hub_spoke_peering" {
    name                        = "hub_spoke_peer"
    resource_group_name         = var.resource_group_name
    virtual_network_name        = azurerm_virtual_network.hub.name 
    remote_virtual_network_id   = azurerm_virtual_network.spoke.id 
}

resource "azurerm_virtual_network_peering" "spoke_hub_peering" {
    name                        = "spoke_hub_peer"
    resource_group_name         = var.resource_group_name
    virtual_network_name        = azurerm_virtual_network.spoke.name 
    remote_virtual_network_id   = azurerm_virtual_network.hub.id 
}

# Azure Firewall 
module "azure_firewall" { 
    source                      = "../azure_firewall"
    resource_group_name         = var.resource_group_name
    location                    = var.location 
    azurefw_name                = var.azurefw_name
    azurefw_vnet_name           = azurerm_virtual_network.hub.name
    azurefw_addr_prefix         = var.azurefw_addr_prefix
}

# Azure Bastion
module "azure_bastion" { 
    source                      = "../azure_bastion"
    resource_group_name         = var.resource_group_name
    location                    = var.location
    azurebastion_name           = var.azurebastion_name
    azurebastion_vnet_name      = azurerm_virtual_network.hub.name
    azurebastion_addr_prefix    = var.azurebastion_addr_prefix
}

# Jump Box
module "jump_boxes" { 
    source                              = "../jump_boxes"
    resource_group_name                 = var.resource_group_name
    location                            = var.location
    jump_box_name                       = var.jump_box_name
    jump_box_vnet_name                  = azurerm_virtual_network.hub.name
    jump_box_addr_prefix                = var.jump_box_addr_prefix
    jump_box_private_ip_addr            = var.jump_box_private_ip_addr
    jump_box_ssh_source_addr_prefixes   = var.jump_box_ssh_source_addr_prefixes
    jump_box_vm_size                    = var.jump_box_vm_size
    jump_box_admin_username             = var.jump_box_admin_username
    jump_box_pub_key_name               = var.jump_box_pub_key_name
}