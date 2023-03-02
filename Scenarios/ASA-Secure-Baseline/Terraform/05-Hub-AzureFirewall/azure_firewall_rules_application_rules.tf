## General Application rules

resource "azurerm_firewall_application_rule_collection" "SpringAppsRefArchApplicationRules" {
    provider = azurerm.hub-subscription
    
    name                = "SpringAppsRefArchApplicationRules"
    azure_firewall_name = azurerm_firewall.azure_firewall_instance.name
    resource_group_name = data.azurerm_resource_group.hub_rg.name
    priority            = 100
    action              = "Allow"

    
        rule {
            name = "AllowAks"
            source_addresses = [
                "${local.address_range_cloudsvc }", "${local.address_range_cloudapps}",
            ]

            

            
            fqdn_tags = [
               "AzureKubernetesService",
            
            ]


                
        }

  rule {
            name = "AllowKubMgmt"
            source_addresses = [
                "${local.address_range_cloudsvc }", "${local.address_range_cloudapps}",
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
                "${local.address_range_cloudsvc }", "${local.address_range_cloudapps}",
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
                "${local.address_range_cloudsvc }", "${local.address_range_cloudapps}",
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
                "${local.address_range_cloudsvc }", "${local.address_range_cloudapps}",
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
                "${local.address_range_cloudsvc}", "${local.address_range_cloudapps}",
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
                "${local.address_range_cloudsvc }", "${local.address_range_cloudapps}",
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
                "${local.address_range_cloudsvc}", "${local.address_range_cloudapps}",
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
                "${local.address_range_cloudsvc }", "${local.address_range_cloudapps}",
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
                "${local.address_range_cloudsvc }", "${local.address_range_cloudapps}",
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
                "${local.address_range_cloudsvc }", "${local.address_range_cloudapps}",
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
                "${local.address_range_cloudsvc }", "${local.address_range_cloudapps}",
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
                "${local.address_range_cloudsvc }", "${local.address_range_cloudapps}",
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
