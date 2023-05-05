# Spring Apps Service Subnet
resource "azurerm_subnet" "azuresbcloudsvc" {
  name                  = var.springboot-service-subnet-name
  resource_group_name   = azurerm_resource_group.spoke_rg.name
  virtual_network_name  = azurerm_virtual_network.spoke_vnet.name
  address_prefixes      = [var.springboot-service-subnet-addr]
}

# Spring Apps Apps Subnet
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

# NSG for Spring Apps Service subnet
resource "azurerm_network_security_group" "asa_svc_nsg" { 
    name                        = local.nsg_svc_name
    location                    = var.location
    resource_group_name         = azurerm_resource_group.spoke_rg.name

    tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "asa_svc_nsg_assoc" {
  subnet_id                 = azurerm_subnet.azuresbcloudsvc.id
  network_security_group_id = azurerm_network_security_group.asa_svc_nsg.id
}

# NSG for Spring Apps Apps subnet
resource "azurerm_network_security_group" "asa_apps_nsg" { 
    name                        = local.nsg_apps_name
    location                    = var.location
    resource_group_name         = azurerm_resource_group.spoke_rg.name

    tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "asa_apps_nsg_assoc" {
  subnet_id                 = azurerm_subnet.azuresbcloudapps.id
  network_security_group_id = azurerm_network_security_group.asa_apps_nsg.id
}

# NSG for Support Services Subnet subnet
resource "azurerm_network_security_group" "support_svc_nsg" { 
    name                        = local.nsg_support_name
    location                    = var.location
    resource_group_name         = azurerm_resource_group.spoke_rg.name

    tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "support_svc_nsg_assoc" {
  subnet_id                 = azurerm_subnet.azuresbcloudsupport.id
  network_security_group_id = azurerm_network_security_group.support_svc_nsg.id
}

# NSG for Shared Subnet
resource "azurerm_network_security_group" "snetshared_nsg" { 
    name                        = local.nsg_shared_name
    location                    = var.location
    resource_group_name         = azurerm_resource_group.spoke_rg.name

    tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "shared_nsg_assoc" {
  subnet_id                 = azurerm_subnet.snetsharedsubnet.id 
  network_security_group_id = azurerm_network_security_group.snetshared_nsg.id
}

# NSG for Appplication Gateway V2

resource "azurerm_network_security_group" "appgw_nsg" { 
    name                        = local.nsg_appgw_name
    location                    = var.location
    resource_group_name         = azurerm_resource_group.spoke_rg.name

    security_rule {      
      name                        = "AllowHTTPSInbound"
      priority                    = 100
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "Tcp"
      source_port_range           = "*"
      destination_port_range      = "443"
      source_address_prefix       = "Internet"
      destination_address_prefix  = "*"
    }
    security_rule {      
      name                        = "AllowHTTPInbound"
      priority                    = 200
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "Tcp"
      source_port_range           = "*"
      destination_port_range      = "80"
      source_address_prefix       = "Internet"
      destination_address_prefix  = "*"
    }
    security_rule {
      name                        = "AllowGatewayManagerInbound"
      priority                    = 300
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "Tcp"
      source_port_range           = "*"
      destination_port_range      = "65200-65535"
      source_address_prefix       = "GatewayManager"
      destination_address_prefix  = "*"
    }
    security_rule {
      name                        = "AllowAzureLBInbound"
      priority                    = 400
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "Tcp"
      source_port_range           = "*"
      destination_port_range      = "443"
      source_address_prefix       = "AzureLoadBalancer"
      destination_address_prefix  = "*"
    }  

    tags = var.tags 
}

resource "azurerm_subnet_network_security_group_association" "appgw_nsg_assoc" {
  subnet_id                 = azurerm_subnet.appgwsubnet.id 
  network_security_group_id = azurerm_network_security_group.appgw_nsg.id
}