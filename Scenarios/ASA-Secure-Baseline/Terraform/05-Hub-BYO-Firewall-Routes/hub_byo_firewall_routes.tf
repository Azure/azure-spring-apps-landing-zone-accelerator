resource "azurerm_route_table" "default_apps_route" {
  name                          = "default_apps_route"
  resource_group_name           = data.azurerm_resource_group.spoke_rg.name
  location                      = var.location

  route {
    name                        = "default_egress"
    address_prefix              = "0.0.0.0/0" 
    next_hop_type               = "VirtualAppliance"
    next_hop_in_ip_address      =  var.FW_IP
  }

  lifecycle {
    ignore_changes = [
      route,tags
    ]
  }

}


resource "azurerm_route_table" "default_runtime_route" {
  name                                = "default_runtime_route"
  resource_group_name                 = data.azurerm_resource_group.spoke_rg.name
  location                            = var.location

  route {
    name                        = "default_egress"
    address_prefix              = "0.0.0.0/0" 
    next_hop_type               = "VirtualAppliance"
    next_hop_in_ip_address      =  var.FW_IP
  }

  lifecycle {
    ignore_changes = [
      route,tags
    ]
  }

}

resource "azurerm_route_table" "default_shared_route" {
  name                                = "default_shared_route"
  resource_group_name                 = data.azurerm_resource_group.spoke_rg.name
  location                            = var.location

  route {
    name                        = "default_egress"
    address_prefix              = "0.0.0.0/0" 
    next_hop_type               = "VirtualAppliance"
    next_hop_in_ip_address      =  var.FW_IP
  }

  lifecycle {
    ignore_changes = [
      route,tags
    ]
  }

}

resource "azurerm_subnet_route_table_association" "sc_app_association" {
  subnet_id      = data.azurerm_subnet.azuresbcloudapps.id
  route_table_id = azurerm_route_table.default_apps_route.id
  
}

resource "azurerm_subnet_route_table_association" "sc_runtime_association" {
  subnet_id      = data.azurerm_subnet.azuresbcloudsvc.id
  route_table_id = azurerm_route_table.default_runtime_route.id
 
}

resource "azurerm_subnet_route_table_association" "sc_shared_association" {
  subnet_id      = data.azurerm_subnet.snetsharedsubnet.id
  route_table_id = azurerm_route_table.default_shared_route.id
 
}


