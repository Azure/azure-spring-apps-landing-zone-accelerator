targetScope = 'subscription'

/******************************/
/*         PARAMETERS         */
/******************************/
@description('Azure Bastion Subnet Address Space')
param azureFirewallSubnetSpace string

@description('Name of the hub VNET. Leave blank if you need one created')
param hubVnetName string = 'vnet-${namePrefix}-${location}-HUB'

@description('Name of the RG that has the hub VNET. Leave blank if you need one created')
param hubVnetResourceGroupName string = 'rg-${namePrefix}-HUB'

@description('The Azure Region in which to deploy the Spring Apps Landing Zone Accelerator')
param location string

@description('The common prefix used when naming resources')
param namePrefix string

param springBootAppsAddressPrefix string
param springBootSvcAddressPrefix string
param sharedAddressPrefix string

@description('Azure Resource Tags')
param tags object = {}

@description('Timestamp value used to group and uniquely identify a given deployment')
param timeStamp string = utcNow('yyyyMMddHHmm')

module azfwSubnet '../Modules/subnet.bicep' = {
  name: '${timeStamp}-${namePrefix}-azfwSubnet'
  scope: resourceGroup(hubVnetResourceGroupName)
  params: {
    azureFirewallSubnetSpace: azureFirewallSubnetSpace
    hubVentName: hubVnetName
    name: 'AzureFirewallSubnet'
  }
}

module azfw '../Modules/azfw.bicep' = {
  name: '${timeStamp}-${namePrefix}-azfw'
  scope: resourceGroup(hubVnetResourceGroupName)
  params: {
    prefix: namePrefix
    privateTrafficPrefixes: azureFirewallSubnetSpace
    fireWallSubnetName: 'AzureFirewallSubnet'
    location: location
    hubVnetName: hubVnetName
    networkRules: [
      {
        name: 'SpringAppsRefArchNetworkRules'
        properties: {
          action: { type: 'Allow' }
          priority: 110
          rules: [
            {
              name: 'AllowVMAppAccess'
              sourceAddresses: [
                sharedAddressPrefix
              ]
              destinationAddresses: [
                springBootAppsAddressPrefix
              ]
              destinationPorts: [
                '80'
                '443'
              ]
              protocols: [
                'TCP'
              ]
            }
            {
              name: 'AllowAllWebAccess'
              sourceAddresses: [
                sharedAddressPrefix
              ]
              destinationAddresses: [
                '*'
              ]
              destinationPorts: [
                '80'
                '443'
              ]
              protocols: [
                'TCP'
              ]
            }
            {
              name: 'AllowKMSActivation'
              sourceAddresses: [
                sharedAddressPrefix
              ]
              destinationAddresses: [
                '*'
              ]
              destinationPorts: [
                '1688'
              ]
              protocols: [
                'TCP'
              ]
            }
            {
              name: 'SpringMgmt'
              sourceAddresses: [
                springBootAppsAddressPrefix
                springBootSvcAddressPrefix
              ]
              destinationAddresses: [
                'AzureCloud'
              ]
              destinationPorts: [
                '443'
              ]
              protocols: [
                'TCP'
              ]
            }
            {
              name: 'KubernetesMgmtTcp'
              sourceAddresses: [
                springBootAppsAddressPrefix
                springBootSvcAddressPrefix
              ]
              destinationAddresses: [
                'AzureCloud'
              ]
              destinationPorts: [
                '9000'
              ]
              protocols: [
                'TCP'
              ]
            }
            {
              name: 'KubernetesMgmtUdp'
              sourceAddresses: [
                springBootAppsAddressPrefix
                springBootSvcAddressPrefix
              ]
              destinationAddresses: [
                'AzureCloud'
              ]
              destinationPorts: [
                '1194'
              ]
              protocols: [
                'UDP'
              ]
            }

            {
              name: 'AzureContainerRegistery'
              sourceAddresses: [
                springBootAppsAddressPrefix
                springBootSvcAddressPrefix
              ]
              destinationAddresses: [
                'AzureContainerRegistry'
              ]
              destinationPorts: [
                '443'
              ]
              protocols: [
                'TCP'
              ]
            }
            {
              name: 'AzureStorage'
              sourceAddresses: [
                springBootAppsAddressPrefix
                springBootSvcAddressPrefix
              ]
              destinationAddresses: [
                'Storage'
              ]
              destinationPorts: [
                '443'
              ]
              protocols: [
                'TCP'
              ]
            }
            {
              name: 'NtpQuery'
              sourceAddresses: [
                springBootAppsAddressPrefix
                springBootSvcAddressPrefix
              ]
              destinationAddresses: [
                '*'
              ]
              destinationPorts: [
                '123'
              ]
              protocols: [
                'UDP'
              ]
            }
          ]
        }
      }
    ]
    applicationRules: [
      {
        name: 'SpringAppsApplicationRules'
        properties: {
          action: {
            type: 'Allow'
          }
          priority: 100
          rules: [
            {
              name: 'AllowAks'
              sourceAddresses: [
                springBootAppsAddressPrefix
                springBootSvcAddressPrefix
              ]
              fqdnTags: [
                'AzureKubernetesService'
              ]
            }
            {
              name: 'AllowKubMgmt'
              sourceAddresses: [
                springBootAppsAddressPrefix
                springBootSvcAddressPrefix
              ]
              targetFqdns: [
                '*.azmk8s.io'
                substring(environment().resourceManager, 8, length(environment().resourceManager) - 9) //This strips off the protocol and trailing slash and is to eliminate the linter failure on hard coded special domains
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
            }
            {
              name: 'AllowMCR'
              sourceAddresses: [
                springBootAppsAddressPrefix
                springBootSvcAddressPrefix
              ]
              targetFqdns: [
                'mcr.microsoft.com'
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
            }
            {
              name: 'AllowMCRStorage'
              sourceAddresses: [
                springBootAppsAddressPrefix
                springBootSvcAddressPrefix
              ]
              targetFqdns: [
                '*.cdn.mscr.io'
                '*.data.mcr.microsoft.com'
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
            }
            {
              name: 'AllowAzureAd'
              sourceAddresses: [
                springBootAppsAddressPrefix
                springBootSvcAddressPrefix
              ]
              targetFqdns: [
                substring(environment().authentication.loginEndpoint, 8, length(environment().authentication.loginEndpoint) - 9) //This strips off the protocol and trailing slash and is to eliminate the linter failure on hard coded special domains
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
            }
            {
              name: 'AllowMSPackRepo'
              sourceAddresses: [
                springBootAppsAddressPrefix
                springBootSvcAddressPrefix
              ]
              targetFqdns: [
                'packages.microsoft.com'
                'acs-mirror.azureedge.net'
                '*.azureedge.net'
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
            }
            {
              name: 'AllowGitHub'
              sourceAddresses: [
                springBootAppsAddressPrefix
                springBootSvcAddressPrefix
              ]
              targetFqdns: [
                'github.com'
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
            }
            {
              name: 'AllowDocker'
              sourceAddresses: [
                springBootAppsAddressPrefix
                springBootSvcAddressPrefix
              ]
              targetFqdns: [
                '*.docker.io'
                '*.docker.com'
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]

            }
            {
              name: 'AllowSnapcraft'
              sourceAddresses: [
                springBootAppsAddressPrefix
                springBootSvcAddressPrefix
              ]
              targetFqdns: [
                'api.snapcraft.io'
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
            }
            {
              name: 'AllowClamAv'
              sourceAddresses: [
                springBootAppsAddressPrefix
                springBootSvcAddressPrefix
              ]
              targetFqdns: [
                'database.clamav.net'
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
            }
            {
              name: 'Allow*UbuntuMisc'
              sourceAddresses: [
                springBootAppsAddressPrefix
                springBootSvcAddressPrefix
              ]
              targetFqdns: [
                'motd.ubuntu.com'
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
            }
            {
              name: 'MsCrls'
              sourceAddresses: [
                springBootAppsAddressPrefix
                springBootSvcAddressPrefix
              ]
              targetFqdns: [
                'crl.microsoft.com'
                'mscrl.microsoft.com'
              ]
              protocols: [
                {
                  port: 80
                  protocolType: 'Http'
                }
              ]
            }
            {
              name: 'AllowDigiCerty'
              sourceAddresses: [
                springBootAppsAddressPrefix
                springBootSvcAddressPrefix
              ]
              targetFqdns: [
                'crl3.digicert.com'
                'crl4.digicert.com'
              ]
              protocols: [
                {
                  port: 80
                  protocolType: 'Http'
                }
              ]
            }
          ]
        }
      }
      {
        name: 'AllowAcmeFitnessInstall'
        properties: {
          action: {
            type: 'Allow'
          }
          priority: 800
          rules: [
            {
              name: 'nuget'
              sourceAddresses: [
                springBootAppsAddressPrefix
                springBootSvcAddressPrefix
              ]
              targetFqdns: [
                'api.nuget.org'
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
            }
            {
              name: 'pypi'
              sourceAddresses: [
                springBootAppsAddressPrefix
                springBootSvcAddressPrefix
              ]
              targetFqdns: [
                'pypi.org'
                'files.pythonhosted.org'
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
            }
            {
              name: 'npm'
              sourceAddresses: [
                springBootAppsAddressPrefix
                springBootSvcAddressPrefix
              ]
              targetFqdns: [
                'registry.npmjs.org'
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
            }
            {
              name: 'gradle'
              sourceAddresses: [
                springBootAppsAddressPrefix
                springBootSvcAddressPrefix
              ]
              targetFqdns: [
                'services.gradle.org'
                'downloads.gradle-dn.com'
                'plugins.gradle.org'
                'plugins-artifacts.gradle.org'
                'repo.gradle.org'
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
            }
            {
              name: 'maven'
              sourceAddresses: [
                springBootAppsAddressPrefix
                springBootSvcAddressPrefix
              ]
              targetFqdns: [
                'repo.maven.apache.org'
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
            }
          ]
        }
      }
    ]
    tags: tags
  }
}
