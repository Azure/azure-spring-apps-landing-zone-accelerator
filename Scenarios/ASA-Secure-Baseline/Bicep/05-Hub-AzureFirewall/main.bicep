targetScope = 'subscription'

/******************************/
/*         PARAMETERS         */
/******************************/
@description('IP CIDR Block for the App Gateway Subnet')
param appGwSubnetPrefix string

@description('Name of the Azure Firewall. Specify this value in the parameters.json file to override this default.')
param azureFirewallName string = 'fw-${namePrefix}'

@description('IP CIDR Block for the Azure Firewall Subnet')
param azureFirewallSubnetPrefix string

@description('Name of the default apps route table. Specify this value in the parameters.json file to override this default.')
param defaultAppsRouteName string = 'default_apps_route'

@description('Name of the default hub route table. Specify this value in the parameters.json file to override this default.')
param defaultHubRouteName string = 'default_hub_route'

@description('Name of the default runtime route table. Specify this value in the parameters.json file to override this default.')
param defaultRuntimeRouteName string = 'default_runtime_route'

@description('Name of the default shared route table. Specify this value in the parameters.json file to override this default.')
param defaultSharedRouteName string = 'default_shared_route'

@description('Name of the hub VNET. Specify this value in the parameters.json file to override this default.')
param hubVnetName string = 'vnet-${namePrefix}-${location}-HUB'

@description('Name of the resource group that contains the hub VNET. Specify this value in the parameters.json file to override this default.')
param hubVnetResourceGroupName string = 'rg-${namePrefix}-HUB'

@description('The Azure Region in which to deploy the Spring Apps Landing Zone Accelerator')
param location string

@description('The common prefix used when naming resources')
param namePrefix string

@description('The Azure AD Service Principal ID of the Azure Spring Cloud Resource Provider - this value varies by tenant - use the command "az ad sp show --id e8de9221-a19c-4c81-b814-fd37c6caf9d2 --query id --output tsv" to get the value specific to your tenant')
param principalId string

@description('IP CIDR Block for the Shared Subnet')
param sharedSubnetPrefix string

@description('Network Security Group name for the Application Gateway subnet should you chose to deploy an AppGW. Specify this value in the parameters.json file to override this default.')
param snetAppGwNsg string = 'snet-agw-nsg'

@description('Network Security Group name for the ASA app subnet. Specify this value in the parameters.json file to override this default.')
param snetAppNsg string = 'snet-app-nsg'

@description('Network Security Group name for the ASA runtime subnet. Specify this value in the parameters.json file to override this default.')
param snetRuntimeNsg string = 'snet-runtime-nsg'

@description('Network Security Group name for the shared subnet. Specify this value in the parameters.json file to override this default.')
param snetSharedNsg string = 'snet-shared-nsg'

@description('Network Security Group name for the support subnet. Specify this value in the parameters.json file to override this default.')
param snetSupportNsg string = 'snet-support-nsg'

@description('Name of the resource group that contains the spoke VNET. Specify this value in the parameters.json file to override this default.')
param spokeVnetResourceGroupName string = 'rg-${namePrefix}-SPOKE'

@description('IP CIDR Block for the Spoke VNET')
param spokeVnetAddressPrefix string

@description('Name of the spoke VNET. Specify this value in the parameters.json file to override this default.')
param spokeVnetName string = 'vnet-${namePrefix}-${location}-SPOKE'

@description('IP CIDR Block for the Spring Apps Subnet')
param springAppsSubnetPrefix string

@description('IP CIDR Block for the Spring Apps Runtime Subnet')
param springAppsRuntimeSubnetPrefix string

@description('IP CIDR Block for the Support Subnet')
param supportSubnetPrefix string

@description('Azure Resource Tags')
param tags object = {}

@description('Timestamp value used to group and uniquely identify a given deployment')
param timeStamp string = utcNow('yyyyMMddHHmm')

/******************************/
/*     RESOURCES & MODULES    */
/******************************/
module azfwSubnet '../Modules/subnet.bicep' = {
  name: '${timeStamp}-azfwSubnet'
  scope: resourceGroup(hubVnetResourceGroupName)
  params: {
    addressPrefix: azureFirewallSubnetPrefix
    vnetName: hubVnetName
    name: 'AzureFirewallSubnet'
  }
}


module azfw '../Modules/azfw.bicep' = {
  name: '${timeStamp}-azfw'
  scope: resourceGroup(hubVnetResourceGroupName)
  params: {
    name: azureFirewallName
    privateTrafficPrefixes: azureFirewallSubnetPrefix
    fireWallSubnetName: 'AzureFirewallSubnet'
    location: location
    hubVnetName: hubVnetName
    networkRules: [
      {
        name: 'SpringAppsRefArchNetworkRules'
        properties: {
          action: { type: 'Allow' }
          priority: 100
          rules: [
            {
              name: 'AllowVMAppAccess'
              sourceAddresses: [
                sharedSubnetPrefix
              ]
              destinationAddresses: [
                springAppsSubnetPrefix
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
                sharedSubnetPrefix
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
                sharedSubnetPrefix
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
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
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
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
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
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
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
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
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
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
              ]
              destinationAddresses: [
                'Storage'
              ]
              destinationPorts: [
                '445'
              ]
              protocols: [
                'TCP'
              ]
            }
            {
              name: 'NtpQuery'
              sourceAddresses: [
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
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
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
              ]
              fqdnTags: [
                'AzureKubernetesService'
              ]
            }
            {
              name: 'AllowKubMgmt'
              sourceAddresses: [
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
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
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
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
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
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
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
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
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
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
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
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
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
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
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
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
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
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
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
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
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
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
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
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
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
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
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
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
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
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
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
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
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
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
  dependsOn: [
    azfwSubnet
  ]
}

module defaultHubRoute '../Modules/udr.bicep' = {
  name: '${timeStamp}-default-hub-route'
  scope: resourceGroup(hubVnetResourceGroupName)
  params: {
    name: defaultHubRouteName
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
  name: '${timeStamp}-default-apps-route'
  scope: resourceGroup(spokeVnetResourceGroupName)
  params: {
    isForSpringApps: true
    name: defaultAppsRouteName
    location: location
    principalId: principalId
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
    name: defaultRuntimeRouteName
    location: location
    principalId: principalId
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
    name: defaultSharedRouteName
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

// Currently in Bicep you cannot associate a route table with an existing subnet, so this workaround
// effectively redeploys the network so that the UDRs defined above can be associated.
resource runtimeNsg 'Microsoft.Network/networkSecurityGroups@2022-09-01' existing = {
  name: snetRuntimeNsg
  scope: resourceGroup(spokeVnetResourceGroupName)
}

resource appNsg 'Microsoft.Network/networkSecurityGroups@2022-09-01' existing = {
  name: snetAppNsg
  scope: resourceGroup(spokeVnetResourceGroupName)
}

resource supportNsg 'Microsoft.Network/networkSecurityGroups@2022-09-01' existing = {
  name: snetSupportNsg
  scope: resourceGroup(spokeVnetResourceGroupName)
}

resource sharedNsg 'Microsoft.Network/networkSecurityGroups@2022-09-01' existing = {
  name: snetSharedNsg
  scope: resourceGroup(spokeVnetResourceGroupName)
}

resource agwNsg 'Microsoft.Network/networkSecurityGroups@2022-09-01' existing = {
  name: snetAppGwNsg
  scope: resourceGroup(spokeVnetResourceGroupName)
}

module spokeVnet '../Modules/vnet.bicep' = {
  name: '${timeStamp}-${spokeVnetName}'
  scope: resourceGroup(spokeVnetResourceGroupName)
  params: {
    isForSpringApps: true
    name: spokeVnetName
    location: location
    principalId: principalId
    addressPrefixes: [
      spokeVnetAddressPrefix
    ]
    subnets: [
      {
        name: 'snet-runtime'
        properties: {
          addressPrefix: springAppsRuntimeSubnetPrefix
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
          addressPrefix: springAppsSubnetPrefix
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
          addressPrefix: supportSubnetPrefix
          networkSecurityGroup: {
            id: supportNsg.id
          }
        }
      }
      {
        name: 'snet-shared'
        properties: {
          addressPrefix: sharedSubnetPrefix
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
          addressPrefix: appGwSubnetPrefix
          networkSecurityGroup: {
            id: agwNsg.id
          }
        }
      }
    ]
    tags: tags
  }
}
