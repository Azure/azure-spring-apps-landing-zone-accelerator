# SpringApps Service Subnet
resource "azurerm_subnet" "azuresbcloudsvc" {
  name                  = var.springboot-service-subnet-name
  resource_group_name   = azurerm_resource_group.spoke_rg.name
  virtual_network_name  = azurerm_virtual_network.spoke_vnet.name
  address_prefixes      = [var.springboot-service-subnet-addr]
}

# SpringApps Apps Subnet
resource "azurerm_subnet" "azuresbcloudapps" {
  name                  = var.springboot-apps-subnet-name
  resource_group_name   = azurerm_resource_group.spoke_rg.name
  virtual_network_name  = azurerm_virtual_network.spoke_vnet.name
  address_prefixes      = [var.springboot-apps-subnet-addr]
}

# Support Services Subnet, e.g. keyvault
resource "azurerm_subnet" "azuresbcloudsupport" {
  name                  = var.springboot-support-subnet-name
  resource_group_name   = azurerm_resource_group.spoke_rg.name
  virtual_network_name  = azurerm_virtual_network.spoke_vnet.name
  address_prefixes      = [var.springboot-support-subnet-addr]
  private_endpoint_network_policies_enabled = false
}

# The Shared Subnet
resource "azurerm_subnet" "snetsharedsubnet" {
  name                  = var.shared-subnet-name
  resource_group_name   = azurerm_resource_group.spoke_rg.name
  virtual_network_name  = azurerm_virtual_network.spoke_vnet.name
  address_prefixes      = [var.shared-subnet-addr]
}

# The AppGW Subnet
resource "azurerm_subnet" "appgwsubnet" {
  name                  = var.appgw-subnet-name
  resource_group_name   = azurerm_resource_group.spoke_rg.name
  virtual_network_name  = azurerm_virtual_network.spoke_vnet.name
  address_prefixes      = [var.appgw-subnet-addr]
}






# NSG for Support Services Subnet subnet
resource "azurerm_network_security_group" "support_svc_nsg" { 
    name                        = "${var.springboot-support-subnet-name}-nsg"
    location                    = var.location
    resource_group_name         = azurerm_resource_group.spoke_rg.name
}

resource "azurerm_subnet_network_security_group_association" "support_svc_nsg_assoc" {
  subnet_id                 = azurerm_subnet.azuresbcloudsupport.id
  network_security_group_id = azurerm_network_security_group.support_svc_nsg.id
}




# NSG for Shared Subnet
resource "azurerm_network_security_group" "snetshared_nsg" { 
    name                        = "${var.shared-subnet-name}-nsg"
    location                    = var.location
    resource_group_name         = azurerm_resource_group.spoke_rg.name
}

resource "azurerm_subnet_network_security_group_association" "shared_nsg_assoc" {
  subnet_id                 = azurerm_subnet.snetsharedsubnet.id 
  network_security_group_id = azurerm_network_security_group.snetshared_nsg.id
}