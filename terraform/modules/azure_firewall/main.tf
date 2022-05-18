# Azure Firewall TF Module
resource "azurerm_subnet" "azure_firewall" {
    name                        = "AzureFirewallSubnet"
    resource_group_name         = var.resource_group_name
    virtual_network_name        = var.azurefw_vnet_name
    address_prefixes            = [var.azurefw_addr_prefix]
} 

resource "azurerm_public_ip" "azure_firewall" {
    name                        = "azure-firewall-ip"
    location                    = var.location
    resource_group_name         = var.resource_group_name
    allocation_method           = "Static"
    sku                         = "Standard"
}



resource "azurerm_firewall" "azure_firewall_instance" { 
    name                        = var.azurefw_name
    location                    = var.location
    resource_group_name         = var.resource_group_name

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
  log_analytics_workspace_id  = var.sc_law_id

  log {
    category = "AzureFirewallApplicationRule"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }
  log {
    category = "AzureFirewallNetworkRule"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }
  log {
    category = "AzureFirewallDnsProxy"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }
  

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  }

}

resource "azurerm_firewall_network_rule_collection" "private_aks" {
    name                = "PrivateAKSNetworkRules"
    azure_firewall_name = azurerm_firewall.azure_firewall_instance.name
    resource_group_name = var.resource_group_name
    priority            = 100
    action              = "Allow"
    rule { 
        name = "NTP"
        source_addresses  = [ 
            "*" 
        ]
        destination_addresses = [
            "*"
        ]
        destination_ports = [ 
            "123" 
        ]
        protocols = [ 
            "UDP" 
        ]
    }
}

resource "azurerm_firewall_application_rule_collection" "private_aks" { 
    name                = "PrivateAKSAppRules"
    azure_firewall_name = azurerm_firewall.azure_firewall_instance.name
    resource_group_name = var.resource_group_name
    priority            = 100
    action              = "Allow"
    rule {
        name = "AKSService_FQDNTag"
        source_addresses = [ 
            "*" 
        ]
        fqdn_tags = [ 
            "AzureKubernetesService" 
        ]
    }
}

resource "azurerm_firewall_network_rule_collection" "spring_cloud_tcp" {
  name                = "spring_cloud_network_tcp_rules"
  azure_firewall_name = azurerm_firewall.azure_firewall_instance.name
  resource_group_name = var.resource_group_name
  priority            = 300
  action              = "Allow"

  rule {
    name = "AzureSpringCloudStorageNetwork"

    source_addresses = [
      "*",
    ]

    destination_ports = [  
      "445",  
    ]

    destination_addresses = [
      "Storage",
    ]

    protocols = [
      "TCP",
    ]
  }

  rule {
    name = "AzureGlobalRequiredNetwork_UDP"

    source_addresses = [
      "*",
    ]

    destination_ports = [
      "1194",
      "53",  
    ]

    destination_addresses = [
      "AzureCloud",
      
    ]

    protocols = [
      "UDP",
    ]
  }
  
}

resource "azurerm_firewall_network_rule_collection" "aks_netrules_tcp" {
  name                = "AKS_network_tcp_rules"
  azure_firewall_name = azurerm_firewall.azure_firewall_instance.name
  resource_group_name = var.resource_group_name
  priority            = 150
  action              = "Allow"

  rule {
    name = "AzureGlobalRequiredNetwork_TCP"

    source_addresses = [
      "*",
    ]

    destination_ports = [
      "9000",
      "443",  
    ]

    destination_addresses = [
      "AzureCloud",
    ]

    protocols = [
      "TCP",
    ]
  }
  
}

resource "azurerm_firewall_application_rule_collection" "ubuntu_libs" {
  name                = "ubuntu_libaries_rules"
  azure_firewall_name = azurerm_firewall.azure_firewall_instance.name
  resource_group_name = var.resource_group_name
  priority            = 350
  action              = "Allow"

  rule {
    name = "Ubuntu Libraries"

    source_addresses = [
      "*",
    ]

    target_fqdns = [      
       
       "api.snapcraft.io",
       "motd.ubuntu.com",      
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }
}

resource "azurerm_firewall_application_rule_collection" "microsoft_crl" {
  name                = "Microsoft_CRL_rules"
  azure_firewall_name = azurerm_firewall.azure_firewall_instance.name
  resource_group_name = var.resource_group_name
  priority            = 450
  action              = "Allow"

  rule {
    name = "Required CRL Rules"

    source_addresses = [
      "*",
    ]

    target_fqdns = [      
       
       "crl.microsoft.com",
       "mscrl.microsoft.com",
       "crl3.digicert.com",
       "ocsp.digicert.com"
       
    ]

    protocol {
      port = "80"
      type = "Http"
    }
  }
}

resource "azurerm_firewall_application_rule_collection" "BlobStorage_rules" {
  name                = "Microsoft_Blob_rules"
  azure_firewall_name = azurerm_firewall.azure_firewall_instance.name
  resource_group_name = var.resource_group_name
  priority            = 500
  action              = "Allow"

  rule {
    name = "Blob Storage Rules"

    source_addresses = [
      "*",
    ]

    target_fqdns = [      
       
       "*.blob.core.windows.net"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }
}

resource "azurerm_firewall_application_rule_collection" "database_clamav_rules" {
  name                = "database_clamav_rules"
  azure_firewall_name = azurerm_firewall.azure_firewall_instance.name
  resource_group_name = var.resource_group_name
  priority            = 550
  action              = "Allow"

  rule {
    name = "Database Clamav Rules"

    source_addresses = [
      "*",
    ]

    target_fqdns = [      
       
       "database.clamav.net"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }
}

resource "azurerm_firewall_application_rule_collection" "Github_rules" {
  name                = "Github_rules"
  azure_firewall_name = azurerm_firewall.azure_firewall_instance.name
  resource_group_name = var.resource_group_name
  priority            = 600
  action              = "Allow"

  rule {
    name = "GitHub Rules"

    source_addresses = [
      "*",
    ]

    target_fqdns = [      
       
       "github.com"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }
}

resource "azurerm_firewall_application_rule_collection" "Microsoft_Metrics_rules" {
  name                = "Microsoft_Metric_rules"
  azure_firewall_name = azurerm_firewall.azure_firewall_instance.name
  resource_group_name = var.resource_group_name
  priority            = 650
  action              = "Allow"

  rule {
    name = "Microsoft Metric Rules"

    source_addresses = [
      "*",
    ]

    target_fqdns = [      
       
       "*.prod.microsoftmetrics.com"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }
}

resource "azurerm_firewall_application_rule_collection" "AKS_acs_rules" {
  name                = "AKS_acs_rules"
  azure_firewall_name = azurerm_firewall.azure_firewall_instance.name
  resource_group_name = var.resource_group_name
  priority            = 700
  action              = "Allow"

  rule {
    name = "AKS acs Rules"

    source_addresses = [
      "*",
    ]

    target_fqdns = [      
       
       "acs-mirror.azureedge.net",
       "*.docker.io"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }
}

resource "azurerm_firewall_application_rule_collection" "Microsoft_Login_rules" {
  name                = "Microsoft_Login_rules"
  azure_firewall_name = azurerm_firewall.azure_firewall_instance.name
  resource_group_name = var.resource_group_name
  priority            = 750
  action              = "Allow"

  rule {
    name = "Microsoft Login Rules"

    source_addresses = [
      "*",
    ]

    target_fqdns = [      
       
       "login.microsoftonline.com"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }
}