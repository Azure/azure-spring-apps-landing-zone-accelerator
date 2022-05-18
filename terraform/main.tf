# Azure provider version 

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "= 3.6.0"
    }
  }
}

provider "azurerm" {
    features {} 
}

# Resource group 
resource "azurerm_resource_group" "sc_corp_rg" {
    name                        = var.resource_group_name
    location                    = var.location

}

resource "random_string" "random" {
  length = 13
  upper = false
  special = false

}
module "log_analytics" {
  source                          = "./modules/log_analytics"
  resource_group_name             = azurerm_resource_group.sc_corp_rg.name
  location                        = var.location
  law_name               = "${var.law_prefix}-${random_string.random.result}"
}

module "spring_cloud" {
  source                          = "./modules/azure_spring_cloud"
  resource_group_name             = azurerm_resource_group.sc_corp_rg.name
  location                        = var.location
  sc_cidr                         = var.sc_cidr
  app_subnet_id                   = module.hub_spoke.sc_rt_subnetid
  service_runtime_subnet_id       = module.hub_spoke.sc_apps_subnetid
  hub_virtual_network_id          = module.hub_spoke.hub_vnet_id
  spoke_virtual_network_id        = module.hub_spoke.spoke_vnet_id
  sc_law_id                       = module.log_analytics.log_analytics_id
  sc_service_name                 = "${var.sc_prefix}-${random_string.random.result}"
  app_insights_name               = "${var.app_insights_prefix}-${random_string.random.result}"
  azure_fw_private_ip             = module.hub_spoke.azure_firewall_private_ip
  sc_default_apps_route           = module.hub_spoke.sc_default_apps_route
  sc_default_runtime_route        = module.hub_spoke.sc_default_runtime_route
}

module "my_sql" {
  source                          = "./modules/my_sql"
  resource_group_name             = azurerm_resource_group.sc_corp_rg.name
  location                        = var.location
  my_sql_name                     = "${var.mysql_server_name_prefix}-${random_string.random.result}"
  my_sql_password                 = var.my_sql_password
  my_sql_admin                    = var.my_sql_admin
  sc_data_subnetid                = module.hub_spoke.sc_data_subnetid
  hub_virtual_network_id          = module.hub_spoke.hub_vnet_id
  spoke_virtual_network_id        = module.hub_spoke.spoke_vnet_id
}

module "keyvault" {
  source                          = "./modules/key_vault"

    resource_group_name             = azurerm_resource_group.sc_corp_rg.name
    location                        = var.location
    keyvault_name                   = "${var.keyvault_prefix}-${random_string.random.result}"
    sc_support_subnetid             = module.hub_spoke.sc_support_subnetid
    hub_virtual_network_id          = module.hub_spoke.hub_vnet_id
    spoke_virtual_network_id        = module.hub_spoke.spoke_vnet_id
}

# Hub-Spoke VNET, Azure Bastion, Azure Firewall Using DNS Proxy
module "hub_spoke" { 
    source                          = "./modules/single_region_hub_spoke"
    resource_group_name             = azurerm_resource_group.sc_corp_rg.name  
    location                        = var.location
    sc_law_id                       = module.log_analytics.log_analytics_id
    hub_vnet_name                   = var.hub_vnet_name
    hub_vnet_addr_prefix            = var.hub_vnet_addr_prefix
    spoke_vnet_name                 = var.spoke_vnet_name
    spoke_vnet_addr_prefix          = var.spoke_vnet_addr_prefix
    springboot-service-subnet-name  = var.springboot-service-subnet-name
    springboot-service-subnet-addr  = var.springboot-service-subnet-addr
    springboot-apps-subnet-name     = var.springboot-apps-subnet-name
    springboot-apps-subnet-addr     = var.springboot-apps-subnet-addr
    springboot-data-subnet-name     = var.springboot-data-subnet-name
    springboot-data-subnet-addr     = var.springboot-data-subnet-addr
    springboot-support-subnet-addr  = var.springboot-support-subnet-addr
    springboot-support-subnet-name  = var.springboot-support-subnet-name
    appgw-subnet-name               = var.appgw-subnet-name
    appgw-subnet-addr               = var.appgw-subnet-addr
    azurefw_name                    = "${var.azurefw_name}-${random_string.random.result}"
    azurefw_addr_prefix             = var.azurefw_addr_prefix

    azurebastion_name               = var.azurebastion_name
    azurebastion_addr_prefix        = var.azurebastion_addr_prefix

    jump_host_name                       = var.jump_host_name
    jump_host_addr_prefix                = var.jump_host_addr_prefix
    jump_host_private_ip_addr            = var.jump_host_private_ip_addr
    jump_host_vm_size                    = var.jump_host_vm_size
    jump_host_admin_username             = var.jump_host_admin_username
    jump_host_password                   = var.jump_host_password 
}
