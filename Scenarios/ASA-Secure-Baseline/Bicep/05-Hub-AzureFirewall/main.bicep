targetScope = 'subscription'

/******************************/
/*         PARAMETERS         */
/******************************/
param appGwSubnetSpace string

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

param spokeRgName string = 'rg-${namePrefix}-SPOKE'

@description('Spoke VNET Prefix')
param spokeVnetAddressPrefixes string

@description('Name of the spoke VNET. Leave blank if you need one created')
param spokeVnetName string = 'vnet-${namePrefix}-${location}-SPOKE'

@description('Name of the RG that has the spoke VNET. Leave blank if you need one created')
param spokeVnetResourceGroupName string = 'rg-${namePrefix}-SPOKE'

param springBootAppsSubnetSpace string
param springBootServiceSubnetSpace string
param springBootSupportSubnetSpace string
param sharedSubnetSpace string

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

//TODO: Add Diagnostics configuration
module azfw '../Modules/azfw.bicep' = {
  name: '${timeStamp}-${namePrefix}-azfw'
  scope: resourceGroup(hubVnetResourceGroupName)
  params: {
    name: 'fw-${namePrefix}'
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
                sharedSubnetSpace
              ]
              destinationAddresses: [
                springBootAppsSubnetSpace
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
                sharedSubnetSpace
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
                sharedSubnetSpace
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
                springBootAppsSubnetSpace
                springBootServiceSubnetSpace
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
                springBootAppsSubnetSpace
                springBootServiceSubnetSpace
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
                springBootAppsSubnetSpace
                springBootServiceSubnetSpace
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
                springBootAppsSubnetSpace
                springBootServiceSubnetSpace
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
                springBootAppsSubnetSpace
                springBootServiceSubnetSpace
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
                springBootAppsSubnetSpace
                springBootServiceSubnetSpace
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
                springBootAppsSubnetSpace
                springBootServiceSubnetSpace
              ]
              fqdnTags: [
                'AzureKubernetesService'
              ]
            }
            {
              name: 'AllowKubMgmt'
              sourceAddresses: [
                springBootAppsSubnetSpace
                springBootServiceSubnetSpace
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
                springBootAppsSubnetSpace
                springBootServiceSubnetSpace
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
                springBootAppsSubnetSpace
                springBootServiceSubnetSpace
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
                springBootAppsSubnetSpace
                springBootServiceSubnetSpace
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
                springBootAppsSubnetSpace
                springBootServiceSubnetSpace
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
                springBootAppsSubnetSpace
                springBootServiceSubnetSpace
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
                springBootAppsSubnetSpace
                springBootServiceSubnetSpace
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
                springBootAppsSubnetSpace
                springBootServiceSubnetSpace
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
                springBootAppsSubnetSpace
                springBootServiceSubnetSpace
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
                springBootAppsSubnetSpace
                springBootServiceSubnetSpace
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
                springBootAppsSubnetSpace
                springBootServiceSubnetSpace
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
                springBootAppsSubnetSpace
                springBootServiceSubnetSpace
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
                springBootAppsSubnetSpace
                springBootServiceSubnetSpace
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
                springBootAppsSubnetSpace
                springBootServiceSubnetSpace
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
                springBootAppsSubnetSpace
                springBootServiceSubnetSpace
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
                springBootAppsSubnetSpace
                springBootServiceSubnetSpace
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
                springBootAppsSubnetSpace
                springBootServiceSubnetSpace
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

module defaultHubRoute '../Modules/udr.bicep' = {
  name: '${timeStamp}-defaultHubRoute'
  scope: resourceGroup(hubVnetResourceGroupName)
  params: {
    name: 'default_hub_route'
    location: location
    routes: [
      {
        name: 'default_egress'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: azfw.outputs.privateIp
        }
      }
    ]
  }
}

module defaultAppsRoute '../Modules/udr.bicep' = {
  name: '${timeStamp}-defaultAppsRoute'
  scope: resourceGroup(spokeVnetResourceGroupName)
  params: {
    isForSpringApps: true
    name: 'default_apps_route'
    location: location
    routes: [
      {
        name: 'default_egress'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: azfw.outputs.privateIp
        }
      }
    ]
  }
}

module defaultRuntimeRoute '../Modules/udr.bicep' = {
  name: '${timeStamp}-defaultRuntimeRoute'
  scope: resourceGroup(spokeVnetResourceGroupName)
  params: {
    isForSpringApps: true
    name: 'default_runtime_route'
    location: location
    routes: [
      {
        name: 'default_egress'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: azfw.outputs.privateIp
        }
      }
    ]
  }
}

module defaultSharedRoute '../Modules/udr.bicep' = {
  name: '${timeStamp}-defaultSharedRoute'
  scope: resourceGroup(spokeVnetResourceGroupName)
  params: {
    name: 'default_shared_route'
    location: location
    routes: [
      {
        name: 'default_egress'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: azfw.outputs.privateIp
        }
      }
    ]
  }
}


//TODO - this section is a hack
resource runtimeNsg 'Microsoft.Network/networkSecurityGroups@2022-09-01' existing = {
  name: 'snet-runtime-nsg'
  scope: resourceGroup(spokeRgName)
}

resource appNsg 'Microsoft.Network/networkSecurityGroups@2022-09-01' existing = {
  name: 'snet-app-nsg'
  scope: resourceGroup(spokeRgName)
}

resource supportNsg 'Microsoft.Network/networkSecurityGroups@2022-09-01' existing = {
  name: 'snet-support-nsg'
  scope: resourceGroup(spokeRgName)
}

resource sharedNsg 'Microsoft.Network/networkSecurityGroups@2022-09-01' existing = {
  name: 'snet-shared-nsg'
  scope: resourceGroup(spokeRgName)
}

resource agwNsg 'Microsoft.Network/networkSecurityGroups@2022-09-01' existing = {
  name: 'snet-agw-nsg'
  scope: resourceGroup(spokeRgName)
}

module spokeVnet '../Modules/vnet.bicep' = {
  name: '${timeStamp}-${spokeVnetName}'
  scope: resourceGroup(spokeRgName)
  params: {
    isForSpringApps: true
    name: spokeVnetName
    location: location
    addressPrefixes: [
      spokeVnetAddressPrefixes
    ]
    subnets: [
      {
        name: 'snet-runtime'
        properties: {
          addressPrefix: springBootServiceSubnetSpace
          networkSecurityGroup: {
            id: runtimeNsg.id
          }
          routeTable: {
            id: defaultRuntimeRoute.outputs.id
          }
        }
      }
      {
        name: 'snet-app'
        properties: {
          addressPrefix: springBootAppsSubnetSpace
          networkSecurityGroup: {
            id: appNsg.id
          }
          routeTable: {
            id: defaultAppsRoute.outputs.id
          }
        }
      }
      {
        name: 'snet-support'
        properties: {
          addressPrefix: springBootSupportSubnetSpace
          networkSecurityGroup: {
            id: supportNsg.id
          }
        }
      }
      {
        name: 'snet-shared'
        properties: {
          addressPrefix: sharedSubnetSpace
          networkSecurityGroup: {
            id: sharedNsg.id
          }
          routeTable: {
            id: defaultSharedRoute.outputs.id
          }
        }
      }
      {
        name: 'snet-agw'
        properties: {
          addressPrefix: appGwSubnetSpace
          networkSecurityGroup: {
            id: agwNsg.id
          }
        }
      }
    ]
    tags: tags
  }
}
