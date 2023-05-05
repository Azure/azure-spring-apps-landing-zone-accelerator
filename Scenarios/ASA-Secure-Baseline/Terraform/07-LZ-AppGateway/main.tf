### Notice about changes ######################################################
# We recommend the use of parameters.tfvars for changes.
# Have a particular customization in mind not addressable via parameters.tfvars?
#  Consider filing a feature request at 
#  https://github.com/Azure/azure-spring-apps-landing-zone-accelerator/issues 
#

data "terraform_remote_state" "lz-network" {
  backend = "azurerm"

  config = {
    storage_account_name = var.state_sa_name
    container_name       = var.state_sa_container_name
    key                  = "lz-network"
    resource_group_name = var.state_sa_rg
  }
}


locals  {
 
  spoke_vnet_name            = data.terraform_remote_state.lz-network.outputs.spoke_vnet_name
  spoke_rg                   = data.terraform_remote_state.lz-network.outputs.spoke_rg

  subnet_appgw_name          = var.appgw-subnet-name

  appgw_rg                   = ( var.APPGW_Rg == "" ? "${var.prefix_rg}${var.name_prefix}-APPGW${var.suffix_rg}" : var.APPGW_Rg )
  appgw_name                 = ( var.APPGW_Name == "" ? "${var.prefix_appgw}${var.name_prefix}${var.suffix_appgw}" : var.APPGW_Name )
           
    
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


# Create the APPGW Resource group 
resource "azurerm_resource_group" "appgw_rg" {
    name                        = local.appgw_rg 
    location                    = var.location
}
