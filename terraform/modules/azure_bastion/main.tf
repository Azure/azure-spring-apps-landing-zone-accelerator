# Azure Bastion TF Module
resource "azurerm_subnet" "azure_bastion" {
    name                        = "AzureBastionSubnet"
    resource_group_name         = var.resource_group_name
    virtual_network_name        = var.azurebastion_vnet_name
    address_prefixes            = [var.azurebastion_addr_prefix]
} 

resource "azurerm_public_ip" "azure_bastion" { 
    name                        = "azure_bastion_ip"
    location                    = var.location
    resource_group_name         = var.resource_group_name
    allocation_method           = "Static"
    sku                         = "Standard" 
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