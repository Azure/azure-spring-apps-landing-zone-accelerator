## General Network rules

resource "azurerm_firewall_network_rule_collection" "SpringAppsRefArchNetworkRules" {
    provider = azurerm.hub-subscription
    
    name                = "SpringAppsRefArchNetworkRules"
    azure_firewall_name = azurerm_firewall.azure_firewall_instance.name
    resource_group_name = data.azurerm_resource_group.hub_rg.name
    priority            = 100
    action              = "Allow"

    
        rule {
            name = "AllowVMAppAccess"
            source_addresses = [
                "${local.address_range_shared}",
            ]

            destination_addresses = [
                "${local.address_range_cloudapps}",
            ]

            destination_ports     = [
                "80", "443" ,
            ]


            protocols             = [
                "TCP",
            ]
                
        }

        rule {
            name = "AllowAllWebAccess"
            source_addresses = [
                "${local.address_range_shared}",
            ]

            destination_addresses = [
                "*",
            ]

            destination_ports     = [
                "80", "443" ,
            ]


            protocols             = [
                "TCP",
            ]
                
        }

        rule {
            name = "AllowKMSActivation"
            source_addresses = [
                "${local.address_range_shared}",
            ]

            destination_addresses = [
                "*",
            ]

            destination_ports     = [
                "1688" ,
            ]


            protocols             = [
                "TCP",
            ]
                
        }

        rule {
            name = "SpringMgmt"
            source_addresses = [
                "${local.address_range_cloudsvc }", "${local.address_range_cloudapps}",
            ]

            destination_addresses = [
                "AzureCloud",
            ]

            destination_ports     = [
                "443" ,
            ]


            protocols             = [
                "TCP",
            ]
                
        }

        rule {
            name = "KubernetesMgmtTcp"
            source_addresses = [
                "${local.address_range_cloudsvc }", "${local.address_range_cloudapps}",
            ]

            destination_addresses = [
                "AzureCloud",
            ]

            destination_ports     = [
                "9000" ,
            ]


            protocols             = [
                "TCP",
            ]
                
        }

        rule {
            name = "KubernetesMgmtUdp"
            source_addresses = [
                "${local.address_range_cloudsvc }", "${local.address_range_cloudapps}",
            ]

            destination_addresses = [
                "AzureCloud",
            ]

            destination_ports     = [
                "1194" ,
            ]


            protocols             = [
                "UDP",
            ]
                
        }

        rule {
            name = "AzureContainerRegistery"
            source_addresses = [
                "${local.address_range_cloudsvc }", "${local.address_range_cloudapps}",
            ]

            destination_addresses = [
                "AzureContainerRegistry",
            ]

            destination_ports     = [
                "443" ,
            ]


            protocols             = [
                "TCP",
            ]
                
        }

        rule {
            name = "AzureStorage"
            source_addresses = [
                "${local.address_range_cloudsvc }", "${local.address_range_cloudapps}",
            ]

            destination_addresses = [
                "Storage",
            ]

            destination_ports     = [
                "445" ,
            ]


            protocols             = [
                "TCP",
            ]
                
        }

        rule {
            name = "NtpQuery"
            source_addresses = [
                "${local.address_range_cloudsvc }", "${local.address_range_cloudapps}", 
            ]

            destination_addresses = [
                "*",
            ]

            destination_ports     = [
                "123" ,
            ]


            protocols             = [
                "UDP",
            ]
                
        }


}

