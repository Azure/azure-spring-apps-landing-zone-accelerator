# Azure Bastion TF Module
resource "azurerm_subnet" "azure_bastion" {
    name                        = "AzureBastionSubnet"
    resource_group_name         = var.resource_group_name
    virtual_network_name        = var.azurebastion_vnet_name
    address_prefixes            = [var.azurebastion_addr_prefix]
} 

resource "azurerm_public_ip" "azure_bastion" { 
    name                        = "azure-bastion-ip"
    location                    = var.location
    resource_group_name         = var.resource_group_name
    allocation_method           = "Static"
    sku                         = "Standard" 
}

# NSG for Bastion subnet

resource "azurerm_network_security_group" "bastion_nsg" { 
    name                        = "bastion-nsg"
    location                    = var.location
    resource_group_name         = var.resource_group_name
}
/*
resource "azurerm_subnet_network_security_group_association" "bastion_nsg_assoc" {
  subnet_id                 = azurerm_subnet.azure_bastion.id
  network_security_group_id = azurerm_network_security_group.bastion_nsg.id
}*/

resource "azurerm_network_security_rule" "bastion_https_in" {
  name                        = "AllowHTTPSInbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.bastion_nsg.name
}

resource "azurerm_network_security_rule" "bastion_gateway_manager_in" {
  name                        = "AllowGatewayManagerInbound"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "GatewayManager"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.bastion_nsg.name
}

resource "azurerm_network_security_rule" "azure_lb_in" {
  name                        = "AllowAzureLBInbound"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.bastion_nsg.name
}

resource "azurerm_network_security_rule" "bastion_host_comm" {
  name                        = "AllowBastionHostCommunication"
  priority                    = 400
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_ranges      = ["8080","5701"]
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.bastion_nsg.name
}

resource "azurerm_bastion_host" "azure_bastion_instance" {
    name                        = var.azurebastion_name
    location                    = var.location
    resource_group_name         = var.resource_group_name

    ip_configuration { 
        name                    = "configuration"
        subnet_id               = azurerm_subnet.azure_bastion.id
        public_ip_address_id    = azurerm_public_ip.azure_bastion.id 
    }
}