
locals  {
 
  spoke_vnet_name          = "vnet-${var.name_prefix}-${var.location}-SPOKE"
  spoke_rg                 = "rg-${var.name_prefix}-SPOKE"

  subnet_appgw_name        = var.appgw-subnet-name

  appgw_rg                 = "rg-${var.name_prefix}-APPGW"
  appgw_name               = "appgw-${var.name_prefix}"
           
    
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
