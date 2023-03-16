
# Spoke-Hub Peering
resource "azurerm_virtual_network_peering" "spoke_hub_peering" {
    name                        = "spoke_hub_peer"
    resource_group_name         = azurerm_resource_group.spoke_rg.name
    virtual_network_name        = azurerm_virtual_network.spoke_vnet.name 
    remote_virtual_network_id   = data.azurerm_virtual_network.hub_vnet.id
}


# Hub-Spoke Peering
resource "azurerm_virtual_network_peering" "hub_spoke_peering" {

    # Only execute this if Bring_Your_Own_Hub == false
    count = ( var.Bring_Your_Own_Hub == false ? 1 : 0 )

    provider = azurerm.hub-subscription
    
    name                        = "hub_spoke_peer"
    resource_group_name         = data.azurerm_resource_group.hub_rg.name
    virtual_network_name        = data.azurerm_virtual_network.hub_vnet.name
    remote_virtual_network_id   = azurerm_virtual_network.spoke_vnet.id 
}

