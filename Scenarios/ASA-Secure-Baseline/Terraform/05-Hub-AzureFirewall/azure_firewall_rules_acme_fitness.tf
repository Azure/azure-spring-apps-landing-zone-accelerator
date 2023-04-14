
## ACME Fitness Application Rules

resource "azurerm_firewall_application_rule_collection" "AllowAcmeFitnessInstall" {
    provider = azurerm.hub-subscription
    
    name                = "AllowAcmeFitnessInstall"
    azure_firewall_name = azurerm_firewall.azure_firewall_instance.name
    resource_group_name = data.azurerm_resource_group.hub_rg.name
    priority            = 800
    action              = "Allow"

    
        rule {
            name = "nuget"
            source_addresses = [
                "${local.address_range_cloudsvc}", "${local.address_range_cloudapps}",
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
                "${local.address_range_cloudsvc }", "${local.address_range_cloudapps}",
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
                "${local.address_range_cloudsvc }", "${local.address_range_cloudapps}",
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
                "${local.address_range_cloudsvc }", "${local.address_range_cloudapps}",
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
                "${local.address_range_cloudsvc }", "${local.address_range_cloudapps}",
            ]

            target_fqdns = [
                "repo.maven.apache.org",
            ]

            protocol {
                port = "443"
                type = "Https"
            }
               
        }

        rule {
            name = "jfrog-jcenter"
            source_addresses = [
                "${local.address_range_cloudsvc }", "${local.address_range_cloudapps}",
            ]

            target_fqdns = [
                "jcenter.bintray.com",
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