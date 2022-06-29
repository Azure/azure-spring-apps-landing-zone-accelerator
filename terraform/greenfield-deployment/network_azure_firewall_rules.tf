resource "azurerm_firewall_network_rule_collection" "VmAppAccess-AllowVMAppAccess" {
    name                = "VmAppAccess-AllowVMAppAccess"
    azure_firewall_name = azurerm_firewall.azure_firewall_instance.name
    resource_group_name = azurerm_resource_group.hub_sc_corp_rg.name
    priority            = 100
    action              = "Allow"

    
        rule {
            name = "AllowVMAppAccess"
            source_addresses = [
                "${var.shared-subnet-addr}",
            ]

            destination_addresses = [
                "${var.springboot-apps-subnet-addr}",
            ]

            destination_ports     = [
                "80", "443" ,
            ]


            protocols             = [
                "TCP",
            ]
                
        }

    depends_on = [
        
    ]

}
resource "azurerm_firewall_network_rule_collection" "VmInternetAccess-AllowVMAppAccess" {
    name                = "VmInternetAccess-AllowVMAppAccess"
    azure_firewall_name = azurerm_firewall.azure_firewall_instance.name
    resource_group_name = azurerm_resource_group.hub_sc_corp_rg.name
    priority            = 150
    action              = "Allow"

    
        rule {
            name = "AllowVMAppAccess"
            source_addresses = [
                "${var.shared-subnet-addr}",
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

    depends_on = [
        azurerm_firewall_network_rule_collection.VmAppAccess-AllowVMAppAccess
    ]

}
resource "azurerm_firewall_network_rule_collection" "VmInternetAccess-AllowKMSActivation" {
    name                = "VmInternetAccess-AllowKMSActivation"
    azure_firewall_name = azurerm_firewall.azure_firewall_instance.name
    resource_group_name = azurerm_resource_group.hub_sc_corp_rg.name
    priority            = 200
    action              = "Allow"

    
        rule {
            name = "AllowKMSActivation"
            source_addresses = [
                "${var.shared-subnet-addr}",
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

    depends_on = [
        azurerm_firewall_network_rule_collection.VmInternetAccess-AllowVMAppAccess
    ]

}
resource "azurerm_firewall_network_rule_collection" "SpringCloudAccess-SpringMgmt" {
    name                = "SpringCloudAccess-SpringMgmt"
    azure_firewall_name = azurerm_firewall.azure_firewall_instance.name
    resource_group_name = azurerm_resource_group.hub_sc_corp_rg.name
    priority            = 250
    action              = "Allow"

    
        rule {
            name = "SpringMgmt"
            source_addresses = [
                "${var.springboot-service-subnet-addr}", "${var.springboot-apps-subnet-addr}",
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

    depends_on = [
        azurerm_firewall_network_rule_collection.VmInternetAccess-AllowKMSActivation
    ]

}
resource "azurerm_firewall_network_rule_collection" "SpringCloudAccess-KubernetesMgmtTcp" {
    name                = "SpringCloudAccess-KubernetesMgmtTcp"
    azure_firewall_name = azurerm_firewall.azure_firewall_instance.name
    resource_group_name = azurerm_resource_group.hub_sc_corp_rg.name
    priority            = 300
    action              = "Allow"

    
        rule {
            name = "KubernetesMgmtTcp"
            source_addresses = [
                "${var.springboot-service-subnet-addr}", "${var.springboot-apps-subnet-addr}",
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

    depends_on = [
        azurerm_firewall_network_rule_collection.SpringCloudAccess-SpringMgmt
    ]

}
resource "azurerm_firewall_network_rule_collection" "SpringCloudAccess-KubernetesMgmtUdp" {
    name                = "SpringCloudAccess-KubernetesMgmtUdp"
    azure_firewall_name = azurerm_firewall.azure_firewall_instance.name
    resource_group_name = azurerm_resource_group.hub_sc_corp_rg.name
    priority            = 350
    action              = "Allow"

    
        rule {
            name = "KubernetesMgmtUdp"
            source_addresses = [
                "${var.springboot-service-subnet-addr}", "${var.springboot-apps-subnet-addr}",
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

    depends_on = [
        azurerm_firewall_network_rule_collection.SpringCloudAccess-KubernetesMgmtTcp
    ]

}
resource "azurerm_firewall_network_rule_collection" "SpringCloudAccess-AzureContainerRegistery" {
    name                = "SpringCloudAccess-AzureContainerRegistery"
    azure_firewall_name = azurerm_firewall.azure_firewall_instance.name
    resource_group_name = azurerm_resource_group.hub_sc_corp_rg.name
    priority            = 400
    action              = "Allow"

    
        rule {
            name = "AzureContainerRegistery"
            source_addresses = [
                "${var.springboot-service-subnet-addr}", "${var.springboot-apps-subnet-addr}",
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

    depends_on = [
        azurerm_firewall_network_rule_collection.SpringCloudAccess-KubernetesMgmtUdp
    ]

}
resource "azurerm_firewall_network_rule_collection" "SpringCloudAccess-AzureStorage" {
    name                = "SpringCloudAccess-AzureStorage"
    azure_firewall_name = azurerm_firewall.azure_firewall_instance.name
    resource_group_name = azurerm_resource_group.hub_sc_corp_rg.name
    priority            = 450
    action              = "Allow"

    
        rule {
            name = "AzureStorage"
            source_addresses = [
                "${var.springboot-service-subnet-addr}", "${var.springboot-apps-subnet-addr}",
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

    depends_on = [
        azurerm_firewall_network_rule_collection.SpringCloudAccess-AzureContainerRegistery
    ]

}
resource "azurerm_firewall_network_rule_collection" "SpringCloudAccess-NtpQuery" {
    name                = "SpringCloudAccess-NtpQuery"
    azure_firewall_name = azurerm_firewall.azure_firewall_instance.name
    resource_group_name = azurerm_resource_group.hub_sc_corp_rg.name
    priority            = 500
    action              = "Allow"

    
        rule {
            name = "NtpQuery"
            source_addresses = [
                "${var.springboot-service-subnet-addr}", "${var.springboot-apps-subnet-addr}",
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

    depends_on = [
        azurerm_firewall_network_rule_collection.SpringCloudAccess-AzureStorage
    ]

}
resource "azurerm_firewall_application_rule_collection" "AllowSpringCloudWebAccess-AllowAks" {
    name                = "AllowSpringCloudWebAccess-AllowAks"
    azure_firewall_name = azurerm_firewall.azure_firewall_instance.name
    resource_group_name = azurerm_resource_group.hub_sc_corp_rg.name
    priority            = 100
    action              = "Allow"

    
        rule {
            name = "AllowAks"
            source_addresses = [
                "${var.springboot-service-subnet-addr}", "${var.springboot-apps-subnet-addr}",
            ]

            

            
            fqdn_tags = [
               "AzureKubernetesService",
            
            ]


                
        }

    depends_on = [
        azurerm_firewall_network_rule_collection.SpringCloudAccess-NtpQuery
    ]

}
resource "azurerm_firewall_application_rule_collection" "AllowSpringCloudWebAccess-AllowKubMgmt" {
    name                = "AllowSpringCloudWebAccess-AllowKubMgmt"
    azure_firewall_name = azurerm_firewall.azure_firewall_instance.name
    resource_group_name = azurerm_resource_group.hub_sc_corp_rg.name
    priority            = 150
    action              = "Allow"

    
        rule {
            name = "AllowKubMgmt"
            source_addresses = [
                "${var.springboot-service-subnet-addr}", "${var.springboot-apps-subnet-addr}",
            ]

            target_fqdns = [
                "*.azmk8s.io", "management.azure.com",
            ]

            protocol {
                port = "443"
                type = "Https"
            }


            

                
        }

    depends_on = [
        azurerm_firewall_application_rule_collection.AllowSpringCloudWebAccess-AllowAks
    ]

}
resource "azurerm_firewall_application_rule_collection" "AllowSpringCloudWebAccess-AllowMCR" {
    name                = "AllowSpringCloudWebAccess-AllowMCR"
    azure_firewall_name = azurerm_firewall.azure_firewall_instance.name
    resource_group_name = azurerm_resource_group.hub_sc_corp_rg.name
    priority            = 200
    action              = "Allow"

    
        rule {
            name = "AllowMCR"
            source_addresses = [
                "${var.springboot-service-subnet-addr}", "${var.springboot-apps-subnet-addr}",
            ]

            target_fqdns = [
                "mcr.microsoft.com",
            ]

            protocol {
                port = "443"
                type = "Https"
            }


            

                
        }

    depends_on = [
        azurerm_firewall_application_rule_collection.AllowSpringCloudWebAccess-AllowKubMgmt
    ]

}
resource "azurerm_firewall_application_rule_collection" "AllowSpringCloudWebAccess-AllowMCRStorage" {
    name                = "AllowSpringCloudWebAccess-AllowMCRStorage"
    azure_firewall_name = azurerm_firewall.azure_firewall_instance.name
    resource_group_name = azurerm_resource_group.hub_sc_corp_rg.name
    priority            = 250
    action              = "Allow"

    
        rule {
            name = "AllowMCRStorage"
            source_addresses = [
                "${var.springboot-service-subnet-addr}", "${var.springboot-apps-subnet-addr}",
            ]

            target_fqdns = [
                "*.cdn.mscr.io", "*.data.mcr.microsoft.com",
            ]

            protocol {
                port = "443"
                type = "Https"
            }


            

                
        }

    depends_on = [
        azurerm_firewall_application_rule_collection.AllowSpringCloudWebAccess-AllowMCR
    ]

}
resource "azurerm_firewall_application_rule_collection" "AllowSpringCloudWebAccess-AllowAzureAd" {
    name                = "AllowSpringCloudWebAccess-AllowAzureAd"
    azure_firewall_name = azurerm_firewall.azure_firewall_instance.name
    resource_group_name = azurerm_resource_group.hub_sc_corp_rg.name
    priority            = 300
    action              = "Allow"

    
        rule {
            name = "AllowAzureAd"
            source_addresses = [
                "${var.springboot-service-subnet-addr}", "${var.springboot-apps-subnet-addr}",
            ]

            target_fqdns = [
                "login.microsoftonline.com",
            ]

            protocol {
                port = "443"
                type = "Https"
            }


            

                
        }

    depends_on = [
        azurerm_firewall_application_rule_collection.AllowSpringCloudWebAccess-AllowMCRStorage
    ]

}
resource "azurerm_firewall_application_rule_collection" "AllowSpringCloudWebAccess-AllowMSPackRepo" {
    name                = "AllowSpringCloudWebAccess-AllowMSPackRepo"
    azure_firewall_name = azurerm_firewall.azure_firewall_instance.name
    resource_group_name = azurerm_resource_group.hub_sc_corp_rg.name
    priority            = 350
    action              = "Allow"

    
        rule {
            name = "AllowMSPackRepo"
            source_addresses = [
                "${var.springboot-service-subnet-addr}", "${var.springboot-apps-subnet-addr}",
            ]

            target_fqdns = [
                "packages.microsoft.com", "acs-mirror.azureedge.net", "*.azureedge.net",
            ]

            protocol {
                port = "443"
                type = "Https"
            }


            

                
        }

    depends_on = [
        azurerm_firewall_application_rule_collection.AllowSpringCloudWebAccess-AllowAzureAd
    ]

}
resource "azurerm_firewall_application_rule_collection" "AllowSpringCloudWebAccess-AllowGitHub" {
    name                = "AllowSpringCloudWebAccess-AllowGitHub"
    azure_firewall_name = azurerm_firewall.azure_firewall_instance.name
    resource_group_name = azurerm_resource_group.hub_sc_corp_rg.name
    priority            = 400
    action              = "Allow"

    
        rule {
            name = "AllowGitHub"
            source_addresses = [
                "${var.springboot-service-subnet-addr}", "${var.springboot-apps-subnet-addr}",
            ]

            target_fqdns = [
                "github.com",
            ]

            protocol {
                port = "443"
                type = "Https"
            }


            

                
        }

    depends_on = [
        azurerm_firewall_application_rule_collection.AllowSpringCloudWebAccess-AllowMSPackRepo
    ]

}
resource "azurerm_firewall_application_rule_collection" "AllowSpringCloudWebAccess-AllowDocker" {
    name                = "AllowSpringCloudWebAccess-AllowDocker"
    azure_firewall_name = azurerm_firewall.azure_firewall_instance.name
    resource_group_name = azurerm_resource_group.hub_sc_corp_rg.name
    priority            = 450
    action              = "Allow"

    
        rule {
            name = "AllowDocker"
            source_addresses = [
                "${var.springboot-service-subnet-addr}", "${var.springboot-apps-subnet-addr}",
            ]

            target_fqdns = [
                "*.docker.io", "*.docker.com",
            ]

            protocol {
                port = "443"
                type = "Https"
            }


            

                
        }

    depends_on = [
        azurerm_firewall_application_rule_collection.AllowSpringCloudWebAccess-AllowGitHub
    ]

}
resource "azurerm_firewall_application_rule_collection" "AllowSpringCloudWebAccess-AllowSnapcraft" {
    name                = "AllowSpringCloudWebAccess-AllowSnapcraft"
    azure_firewall_name = azurerm_firewall.azure_firewall_instance.name
    resource_group_name = azurerm_resource_group.hub_sc_corp_rg.name
    priority            = 500
    action              = "Allow"

    
        rule {
            name = "AllowSnapcraft"
            source_addresses = [
                "${var.springboot-service-subnet-addr}", "${var.springboot-apps-subnet-addr}",
            ]

            target_fqdns = [
                "api.snapcraft.io",
            ]

            protocol {
                port = "443"
                type = "Https"
            }


            

                
        }

    depends_on = [
        azurerm_firewall_application_rule_collection.AllowSpringCloudWebAccess-AllowDocker
    ]

}
resource "azurerm_firewall_application_rule_collection" "AllowSpringCloudWebAccess-AllowClamAv" {
    name                = "AllowSpringCloudWebAccess-AllowClamAv"
    azure_firewall_name = azurerm_firewall.azure_firewall_instance.name
    resource_group_name = azurerm_resource_group.hub_sc_corp_rg.name
    priority            = 550
    action              = "Allow"

    
        rule {
            name = "AllowClamAv"
            source_addresses = [
                "${var.springboot-service-subnet-addr}", "${var.springboot-apps-subnet-addr}",
            ]

            target_fqdns = [
                "database.clamav.net",
            ]

            protocol {
                port = "443"
                type = "Https"
            }


            

                
        }

    depends_on = [
        azurerm_firewall_application_rule_collection.AllowSpringCloudWebAccess-AllowSnapcraft
    ]

}
resource "azurerm_firewall_application_rule_collection" "AllowSpringCloudWebAccess-Allow_UbuntuMisc" {
    name                = "AllowSpringCloudWebAccess-Allow_UbuntuMisc"
    azure_firewall_name = azurerm_firewall.azure_firewall_instance.name
    resource_group_name = azurerm_resource_group.hub_sc_corp_rg.name
    priority            = 600
    action              = "Allow"

    
        rule {
            name = "Allow*UbuntuMisc"
            source_addresses = [
                "${var.springboot-service-subnet-addr}", "${var.springboot-apps-subnet-addr}",
            ]

            target_fqdns = [
                "motd.ubuntu.com",
            ]

            protocol {
                port = "443"
                type = "Https"
            }


            

                
        }

    depends_on = [
        azurerm_firewall_application_rule_collection.AllowSpringCloudWebAccess-AllowClamAv
    ]

}
resource "azurerm_firewall_application_rule_collection" "AllowSpringCloudWebAccess-MsCrls" {
    name                = "AllowSpringCloudWebAccess-MsCrls"
    azure_firewall_name = azurerm_firewall.azure_firewall_instance.name
    resource_group_name = azurerm_resource_group.hub_sc_corp_rg.name
    priority            = 650
    action              = "Allow"

    
        rule {
            name = "MsCrls"
            source_addresses = [
                "${var.springboot-service-subnet-addr}", "${var.springboot-apps-subnet-addr}",
            ]

            target_fqdns = [
                "crl.microsoft.com", "mscrl.microsoft.com",
            ]

            protocol {
                port = "80"
                type = "Http"
            }


            

                
        }

    depends_on = [
        azurerm_firewall_application_rule_collection.AllowSpringCloudWebAccess-Allow_UbuntuMisc
    ]

}
resource "azurerm_firewall_application_rule_collection" "AllowSpringCloudWebAccess-AllowDigiCerty" {
    name                = "AllowSpringCloudWebAccess-AllowDigiCerty"
    azure_firewall_name = azurerm_firewall.azure_firewall_instance.name
    resource_group_name = azurerm_resource_group.hub_sc_corp_rg.name
    priority            = 700
    action              = "Allow"

    
        rule {
            name = "AllowDigiCerty"
            source_addresses = [
                "${var.springboot-service-subnet-addr}", "${var.springboot-apps-subnet-addr}",
            ]

            target_fqdns = [
                "crl3.digicert.com", "crl4.digicert.com",
            ]

            protocol {
                port = "80"
                type = "Http"
            }


            

                
        }

    depends_on = [
        azurerm_firewall_application_rule_collection.AllowSpringCloudWebAccess-MsCrls
    ]

}

