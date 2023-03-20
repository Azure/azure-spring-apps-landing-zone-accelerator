# Azure Firewall TF Module
resource "azurerm_subnet" "azure_firewall" {
    name                        = "AzureFirewallSubnet"
    resource_group_name         = azurerm_resource_group.hub_sc_corp_rg.name
    virtual_network_name        = azurerm_virtual_network.hub.name
    address_prefixes            = [var.azurefw_addr_prefix]
} 

resource "azurerm_public_ip" "azure_firewall" {
    name                        = "azure-firewall-ip"
    location                    = var.location
    resource_group_name         = azurerm_resource_group.hub_sc_corp_rg.name
    allocation_method           = "Static"
    sku                         = "Standard"
}



resource "azurerm_firewall" "azure_firewall_instance" { 
    name                        = "${var.azurefw_name}-${random_string.random.result}"
    location                    = var.location
    resource_group_name         = azurerm_resource_group.hub_sc_corp_rg.name
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
  depends_on = [ azurerm_public_ip.azure_firewall ]
}

resource "azurerm_monitor_diagnostic_setting" "azfw_diag" {
  name                        = "monitoring"
  target_resource_id          = azurerm_firewall.azure_firewall_instance.id
  log_analytics_workspace_id  = azurerm_log_analytics_workspace.sc_law.id

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
    azurerm_public_ip.azure_firewall,
    azurerm_log_analytics_workspace.sc_law
  ]

}
