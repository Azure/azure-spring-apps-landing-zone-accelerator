# Hub-Spoke VNET 
resource "azurerm_virtual_network" "hub" {
    name                        = var.hub_vnet_name
    location                    = var.location 
    resource_group_name         = azurerm_resource_group.hub_sc_corp_rg.name
    address_space               = [var.hub_vnet_addr_prefix]
}

# The AppGW Subnet
resource "azurerm_subnet" "appgwsubnet" {
  name                 = var.appgw-subnet-name
  resource_group_name = azurerm_resource_group.hub_sc_corp_rg.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes       = [var.appgw-subnet-addr]
}

# The Shared Subnet
resource "azurerm_subnet" "snetsharedsubnet" {
  name                 = var.shared-subnet-name
  resource_group_name = azurerm_resource_group.hub_sc_corp_rg.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes       = [var.shared-subnet-addr]
}

# Hub-Spoke Peering
resource "azurerm_virtual_network_peering" "hub_spoke_peering" {
    name                        = "hub_spoke_peer"
    resource_group_name         = azurerm_resource_group.hub_sc_corp_rg.name
    virtual_network_name        = azurerm_virtual_network.hub.name 
    remote_virtual_network_id   = azurerm_virtual_network.spoke.id 
}


resource "azurerm_route_table" "default_hub_route" {
  name                          = "default_hub_route"
  resource_group_name                 = azurerm_resource_group.hub_sc_corp_rg.name
  location                            = var.location

  route {
    name                        = "default_egress"
    address_prefix              = "0.0.0.0/0" 
    next_hop_type               = "VirtualAppliance"
    next_hop_in_ip_address      =  azurerm_firewall.azure_firewall_instance.ip_configuration[0].private_ip_address
  }

  

}

resource "azurerm_subnet_route_table_association" "hub_association" {
  subnet_id      = azurerm_subnet.snetsharedsubnet.id
  route_table_id = azurerm_route_table.default_hub_route.id

  depends_on = [
    #Last Firewall rule is in!
    azurerm_firewall_application_rule_collection.AllowSpringCloudWebAccess-AllowDigiCerty
  ]
}
