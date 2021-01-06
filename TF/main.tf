# Azure provider version 

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.40"
    }
  }
}

provider "azurerm" {
    version = "=2.40.0"
    features {} 
}

# Resource group 
resource "azurerm_resource_group" "sc_corp_rg" {
    name                        = var.resource_group_name
    location                    = var.location

}

# SC Resource group 
resource "azurerm_resource_group" "sc_spring_cloud_rg" {
    name                        = var.sc_resource_group_name 
    location                    = var.location

}

module "spring_cloud" {
  source                          = "./modules/azure_spring_cloud"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  app_subnet_id                   = module.hub_spoke.sc_rt_subnetid
  service_runtime_subnet_id       = module.hub_spoke.sc_apps_subnetid
  hub_virtual_network_id          = module.hub_spoke.hub_vnet_id
  spoke_virtual_network_id        = module.hub_spoke.spoke_vnet_id
  sc_resource_group_name          = var.sc_resource_group_name
  sc_service_name                 = var.sc_service_name
  azure_fw_private_ip             = module.hub_spoke.azure_firewall_private_ip
  depends_on = [ azurerm_resource_group.sc_spring_cloud_rg ]
}

module "my_sql" {
  source                          = "./modules/my_sql"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  my_sql_name                     = var.my_sql_name
  my_sql_password                 = var.my_sql_password
  my_sql_admin                    = var.my_sql_admin
  sc_support_subnetid             = module.hub_spoke.sc_support_subnetid
  hub_virtual_network_id          = module.hub_spoke.hub_vnet_id
  spoke_virtual_network_id        = module.hub_spoke.spoke_vnet_id
  depends_on = [ azurerm_resource_group.sc_corp_rg]
}

module "keyvault" {
  source                          = "./modules/key_vault"

    resource_group_name             = azurerm_resource_group.sc_corp_rg.name
    location                        = var.location
    keyvault_prefix                 = var.keyvault_prefix
    sc_support_subnetid             = module.hub_spoke.sc_support_subnetid
    hub_virtual_network_id          = module.hub_spoke.hub_vnet_id
    spoke_virtual_network_id        = module.hub_spoke.spoke_vnet_id

}

# Hub-Spoke VNET, Azure Bastion, Azure Firewall, BIND DNS 
module "hub_spoke" { 
    source                          = "./modules/single_region_hub_spoke"
    resource_group_name             = var.resource_group_name
    depends_on = [ azurerm_resource_group.sc_corp_rg ]
    location                        = var.location

    hub_vnet_name                   = var.hub_vnet_name
    hub_vnet_addr_prefix            = var.hub_vnet_addr_prefix
    spoke_vnet_name                 = var.spoke_vnet_name
    spoke_vnet_addr_prefix          = var.spoke_vnet_addr_prefix

    azurefw_name                    = var.azurefw_name
    azurefw_addr_prefix             = var.azurefw_addr_prefix

    azurebastion_name               = var.azurebastion_name
    azurebastion_addr_prefix        = var.azurebastion_addr_prefix

    jump_box_name                       = var.jump_box_name
    jump_box_addr_prefix                = var.jump_box_addr_prefix
    jump_box_private_ip_addr            = var.jump_box_private_ip_addr
    jump_box_vm_size                    = var.jump_box_vm_size
    jump_box_admin_username             = var.jump_box_admin_username
    jump_box_password                   = var.jump_box_password
}
