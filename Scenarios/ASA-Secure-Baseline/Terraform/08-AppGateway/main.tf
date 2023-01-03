# Azure provider version 
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "= 3.32.0"
    }
  }
}

provider "azurerm" {
    features {
     resource_group {
       prevent_deletion_if_contains_resources = false
     }
    } 
}

locals  {
 
  spoke_rg                 = "${var.name_prefix}-SPOKE"
  spoke_vnet_name          = "${var.name_prefix}-vnet-SPOKE"

  subnet_appgw_name        = var.appgw-subnet-name

  appgw_rg                 = "${var.name_prefix}-APPGW"
  appgw_name               = "${var.name_prefix}-gw"
           
    
  backend_address_pool = {
      fqdns = ["${var.backendPoolFQDN}"]
  }
  backend_address_pool_name      = "backend-pool"
  frontend_port_name             = "port_443"
  frontend_ip_configuration_name = "appGwPublicFrontendIp"
  http_setting_name              = "backend-httpsettings"
  listener_name                  = "myapp-listener-https"
  request_routing_rule_name      = "myapp-rule"  


}

# Get info about the existing AppGatewaySubnet
data "azurerm_subnet" "appgwsubnet" {
  name                 =  local.subnet_appgw_name
  virtual_network_name =  local.spoke_vnet_name
  resource_group_name  =  local.spoke_rg
}



# # Get info about Log Analytics workspace
# data "azurerm_log_analytics_workspace" "sc_law" {
#   name = "${var.name_prefix}-law"
# }

# Create the APPGW Resource group 
resource "azurerm_resource_group" "appgw_rg" {
    name                        = local.appgw_rg 
    location                    = var.location
}
