## General Network rules

resource "azurerm_firewall_network_rule_collection" "SpringAppsRefArchNetworkRules" {
    name                = "SpringAppsRefArchNetworkRules"
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

        rule {
            name = "AllowAllWebAccess"
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


}

## General Application rules

resource "azurerm_firewall_application_rule_collection" "SpringAppsRefArchApplicationRules" {
    name                = "SpringAppsRefArchApplicationRules"
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
            azurerm_firewall_network_rule_collection.SpringAppsRefArchNetworkRules
        ]


}

## ACME Fitness Application Rules

resource "azurerm_firewall_application_rule_collection" "AllowAcmeFitnessInstall" {
    name                = "AllowAcmeFitnessInstall"
    azure_firewall_name = azurerm_firewall.azure_firewall_instance.name
    resource_group_name = azurerm_resource_group.hub_sc_corp_rg.name
    priority            = 800
    action              = "Allow"

    
        rule {
            name = "nuget"
            source_addresses = [
                "${var.springboot-service-subnet-addr}", "${var.springboot-apps-subnet-addr}",
            ]

            target_fqdns = [
                "api.nuget.org"
            ]

            protocol {
                port = "443"
                type = "Https"
            }
               
        }

        rule {
            name = "pypi"
            source_addresses = [
                "${var.springboot-service-subnet-addr}", "${var.springboot-apps-subnet-addr}",
            ]

            target_fqdns = [
                "pypi.org","files.pythonhosted.org",
            ]

            protocol {
                port = "443"
                type = "Https"
            }
               
        }

        rule {
            name = "npm"
            source_addresses = [
                "${var.springboot-service-subnet-addr}", "${var.springboot-apps-subnet-addr}",
            ]

            target_fqdns = [
                "registry.npmjs.org",
            ]

            protocol {
                port = "443"
                type = "Https"
            }
               
        }

        rule {
            name = "gradle"
            source_addresses = [
                "${var.springboot-service-subnet-addr}", "${var.springboot-apps-subnet-addr}",
            ]

            target_fqdns = [
                "services.gradle.org","downloads.gradle-dn.com","plugins.gradle.org","plugins-artifacts.gradle.org","repo.gradle.org",
            ]

            protocol {
                port = "443"
                type = "Https"
            }
               
        }

        rule {
            name = "maven"
            source_addresses = [
                "${var.springboot-service-subnet-addr}", "${var.springboot-apps-subnet-addr}",
            ]

            target_fqdns = [
                "repo.maven.apache.org",
            ]

            protocol {
                port = "443"
                type = "Https"
            }
               
        }
    depends_on = [
        azurerm_firewall_application_rule_collection.SpringAppsRefArchApplicationRules
    ]

}