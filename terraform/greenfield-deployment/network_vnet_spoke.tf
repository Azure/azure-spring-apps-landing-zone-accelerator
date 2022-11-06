# Spoke VNET 
resource "azurerm_virtual_network" "spoke" {
    name                        = var.spoke_vnet_name
    location                    = var.location 
    resource_group_name         = azurerm_resource_group.spoke_sc_corp_rg.name
    address_space               = [var.spoke_vnet_addr_prefix]
    dns_servers                 = [azurerm_firewall.azure_firewall_instance.ip_configuration[0].private_ip_address]
}

# Spring Cloud Service Subnet
resource "azurerm_subnet" "azuresbcloudsvc" {
  name                 = var.springboot-service-subnet-name
  resource_group_name = azurerm_resource_group.spoke_sc_corp_rg.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes       = [var.springboot-service-subnet-addr]
}

# Spring Cloud Apps Subnet
resource "azurerm_subnet" "azuresbcloudapps" {
  name                 = var.springboot-apps-subnet-name
  resource_group_name = azurerm_resource_group.spoke_sc_corp_rg.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes       = [var.springboot-apps-subnet-addr]
}


# Supported Services Subnet, e.g. keyvault
resource "azurerm_subnet" "azuresbcloudsupport" {
  name                 = var.springboot-support-subnet-name
  resource_group_name = azurerm_resource_group.spoke_sc_corp_rg.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes       = [var.springboot-support-subnet-addr]
  private_endpoint_network_policies_enabled = false
}


# Spoke-Hub Peering
resource "azurerm_virtual_network_peering" "spoke_hub_peering" {
    name                        = "spoke_hub_peer"
    resource_group_name         = azurerm_resource_group.spoke_sc_corp_rg.name
    virtual_network_name        = azurerm_virtual_network.spoke.name 
    remote_virtual_network_id   = azurerm_virtual_network.hub.id 
}

resource "azurerm_route_table" "default_apps_route" {
  name                          = "default_apps_route"
  resource_group_name                 = azurerm_resource_group.spoke_sc_corp_rg.name
  location                            = var.location

  route {
    name                        = "default_egress"
    address_prefix              = "0.0.0.0/0" 
    next_hop_type               = "VirtualAppliance"
    next_hop_in_ip_address      =  azurerm_firewall.azure_firewall_instance.ip_configuration[0].private_ip_address
  }

  lifecycle {
    ignore_changes = [
      route,tags
    ]
  }

}

resource "azurerm_route_table" "default_runtime_route" {
  name                          = "default_runtime_route"
  resource_group_name                 = azurerm_resource_group.spoke_sc_corp_rg.name
  location                            = var.location

  route {
    name                        = "default_egress"
    address_prefix              = "0.0.0.0/0" 
    next_hop_type               = "VirtualAppliance"
    next_hop_in_ip_address      =  azurerm_firewall.azure_firewall_instance.ip_configuration[0].private_ip_address
  }

  lifecycle {
    ignore_changes = [
      route,tags
    ]
  }

}

resource "azurerm_subnet_route_table_association" "sc_app_association" {
  subnet_id      = azurerm_subnet.azuresbcloudapps.id
  route_table_id = azurerm_route_table.default_apps_route.id

  depends_on = [
    #Last Firewall rule is in!
    azurerm_firewall_application_rule_collection.AllowSpringCloudWebAccess-AllowDigiCerty
  ]
}

resource "azurerm_subnet_route_table_association" "sc_runtime_association" {
  subnet_id      = azurerm_subnet.azuresbcloudsvc.id
  route_table_id = azurerm_route_table.default_runtime_route.id

  depends_on = [
    #Last Firewall rule is in!
    azurerm_firewall_application_rule_collection.AllowSpringCloudWebAccess-AllowDigiCerty
  ]
}

