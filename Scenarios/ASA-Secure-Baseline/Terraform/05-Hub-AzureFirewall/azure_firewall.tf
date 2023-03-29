# Azure Firewall
resource "azurerm_subnet" "azure_firewall" {

    provider = azurerm.hub-subscription

    name                        = "AzureFirewallSubnet"
    resource_group_name         = data.azurerm_resource_group.hub_rg.name
    virtual_network_name        = data.azurerm_virtual_network.hub_vnet.name
    address_prefixes            = [var.azurefw_addr_prefix]    
} 

resource "azurerm_public_ip" "azure_firewall" {
    provider = azurerm.hub-subscription

    name                        = "azure-firewall-ip"
    location                    = var.location
    resource_group_name         = data.azurerm_resource_group.hub_rg.name
    allocation_method           = "Static"
    sku                         = "Standard"

    tags = var.tags
}



resource "azurerm_firewall" "azure_firewall_instance" {
    provider = azurerm.hub-subscription

    name                        = local.fw_name
    location                    = var.location
    resource_group_name         = data.azurerm_resource_group.hub_rg.name
    sku_name                    = "AZFW_VNet"
    sku_tier                    = "Standard"
    
    dns_servers                 = [ 
        "168.63.129.16"
    ]
    ip_configuration {
        name                    = "configuration"
        subnet_id               = azurerm_subnet.azure_firewall.id 
        public_ip_address_id    = azurerm_public_ip.azure_firewall.id
    }

    timeouts {
      create = "60m"
      delete = "2h"
  }


  zones = var.azure_firewall_zones

  tags = var.tags

  depends_on = [ azurerm_public_ip.azure_firewall ]
}

resource "azurerm_monitor_diagnostic_setting" "azfw_diag" {
  provider = azurerm.hub-subscription
  
  name                        = "monitoring"
  target_resource_id          = azurerm_firewall.azure_firewall_instance.id
  log_analytics_workspace_id  = data.azurerm_log_analytics_workspace.sc_law.id

  log_analytics_destination_type = "AzureDiagnostics"

  log {
    category = "AzureFirewallApplicationRule"
    enabled  = true

    retention_policy {
      enabled = false
      days    = 0
    }
  }
  log {
    category = "AzureFirewallNetworkRule"
    enabled  = true

    retention_policy {
      enabled = false
      days    = 0
    }
  }
  log {
    category = "AzureFirewallDnsProxy"
    enabled  = true

    retention_policy {
      enabled = false
      days    = 0
    }
  }
  

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
      days    = 0
    }
  }

   lifecycle {
    ignore_changes = [
      log, metric
    ]
  }

  depends_on = [
    azurerm_public_ip.azure_firewall  ]

}
