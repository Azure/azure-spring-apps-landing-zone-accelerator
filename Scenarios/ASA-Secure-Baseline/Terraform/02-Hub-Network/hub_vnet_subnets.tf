# The default Subnet
resource "azurerm_subnet" "defaulthubsubnet" {
  provider = azurerm.hub
  
  name                      = "default"
  resource_group_name       = azurerm_resource_group.hub_rg.name
  virtual_network_name      = azurerm_virtual_network.hub_vnet.name
  address_prefixes          = [var.default-subnet-addr]
}

