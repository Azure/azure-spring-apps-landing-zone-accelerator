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
      name                        = "AllowGatewayManagerInbound"
      priority                    = 200
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "Tcp"
      source_port_range           = "*"
      destination_port_range      = "443"
      source_address_prefix       = "GatewayManager"
      destination_address_prefix  = "*"
    }
    security_rule {
      name                        = "AllowAzureLBInbound"
      priority                    = 300
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "Tcp"
      source_port_range           = "*"
      destination_port_range      = "443"
      source_address_prefix       = "AzureLoadBalancer"
      destination_address_prefix  = "*"
    }
    security_rule {
      name                        = "AllowBastionHostCommunication"
      priority                    = 400
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_ranges      = ["5701","8080"]
      source_address_prefix       = "VirtualNetwork"
      destination_address_prefix  = "VirtualNetwork"
    }
    security_rule {
      name                        = "AllowRdpSshOutbound"
      priority                    = 100
      direction                   = "Outbound"
      access                      = "Allow"
      protocol                    = "Tcp"
      source_port_range           = "*"
      destination_port_ranges      = ["22", "3389"]
      source_address_prefix       = "*"
      destination_address_prefix  = "VirtualNetwork"
    }
      security_rule {
      name                        = "AllowBastionHostCommunicationOutbound"
      priority                    = 110
      direction                   = "Outbound"
      access                      = "Allow"
      protocol                    = "Tcp"
      source_port_range           = "*"
      destination_port_ranges      = ["5701", "8080"]
      source_address_prefix       = "VirtualNetwork"
      destination_address_prefix  = "VirtualNetwork"
  }
    security_rule {
      name                        = "AllowAzureCloudOutbound"
      priority                    = 120
      direction                   = "Outbound"
      access                      = "Allow"
      protocol                    = "Tcp"
      source_port_range           = "*"
      destination_port_ranges      = ["443"]
      source_address_prefix       = "*"
      destination_address_prefix  = "AzureCloud"
    }
    security_rule {
      name                        = "AllowGetSessionInformation"
      priority                    = 130
      direction                   = "Outbound"
      access                      = "Allow"
      protocol                    = "Tcp"
      source_port_range           = "*"
      destination_port_ranges      = ["80"]
      source_address_prefix       = "*"
      destination_address_prefix  = "Internet"
}
    
}

resource "azurerm_subnet_network_security_group_association" "bastion_nsg_assoc" {
  subnet_id                 = azurerm_subnet.azure_bastion.id
  network_security_group_id = azurerm_network_security_group.bastion_nsg.id
  depends_on = [ azurerm_bastion_host.azure_bastion_instance ]
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