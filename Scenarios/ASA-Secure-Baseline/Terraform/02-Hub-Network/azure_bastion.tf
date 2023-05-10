# Azure Bastion needed Network components

resource "azurerm_subnet" "azure_bastion" {
    provider = azurerm.hub-subscription

    name                        = "AzureBastionSubnet"
    resource_group_name         = azurerm_resource_group.hub_rg.name
    virtual_network_name        = azurerm_virtual_network.hub_vnet.name
    address_prefixes            = [var.azurebastion_addr_prefix]

} 

# NSG for Bastion subnet

resource "azurerm_network_security_group" "bastion_nsg" { 
    provider = azurerm.hub-subscription

    name                        = local.bastion_nsg
    location                    = var.location
    resource_group_name         = azurerm_resource_group.hub_rg.name

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
    
    tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "bastion_nsg_assoc" {
  provider = azurerm.hub-subscription

  subnet_id                 = azurerm_subnet.azure_bastion.id
  network_security_group_id = azurerm_network_security_group.bastion_nsg.id
  depends_on = [ azurerm_bastion_host.azure_bastion_instance ]
}




# Azure Bastion

resource "azurerm_public_ip" "azure_bastion" {
    provider = azurerm.hub-subscription

    name                        = local.bastion_pip
    location                    = var.location
    resource_group_name         = azurerm_resource_group.hub_rg.name
    allocation_method           = "Static"
    sku                         = "Standard"
   
    

    tags = var.tags 
}


resource "azurerm_bastion_host" "azure_bastion_instance" {
    provider = azurerm.hub-subscription
    
    name                        = local.bastion_name
    location                    = var.location
    resource_group_name         = azurerm_resource_group.hub_rg.name

    ip_configuration { 
        name                    = "configuration"
        subnet_id               = azurerm_subnet.azure_bastion.id
        public_ip_address_id    = azurerm_public_ip.azure_bastion.id 
    }

    tags = var.tags

    depends_on = [
      azurerm_public_ip.azure_bastion
    ]
}