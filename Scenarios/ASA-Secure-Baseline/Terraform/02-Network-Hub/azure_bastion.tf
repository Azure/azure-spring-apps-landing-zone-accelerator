# Azure Bastion

resource "azurerm_public_ip" "azure_bastion" { 
    name                        = "azure-bastion-ip"
    location                    = var.location
    resource_group_name         = azurerm_resource_group.hub_rg.name
    allocation_method           = "Static"
    sku                         = "Standard" 
}


resource "azurerm_bastion_host" "azure_bastion_instance" {
    name                        = local.bastion_name
    location                    = var.location
    resource_group_name         = azurerm_resource_group.hub_rg.name

    ip_configuration { 
        name                    = "configuration"
        subnet_id               = azurerm_subnet.azure_bastion.id
        public_ip_address_id    = azurerm_public_ip.azure_bastion.id 
    }

    depends_on = [
      azurerm_public_ip.azure_bastion
    ]
}