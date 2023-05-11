targetScope = 'subscription'

@description('Name of the application insights instance. Specify this value in the parameters.json file to override this default.')
param appInsightsName string

@description('Name of the resource group that contains the Spring Apps instance. Specify this value in the parameters.json file to override this default.')
param appRgName string

@description('IP CIDR Block for the App Gateway Subnet')
param appGwSubnetPrefix string

@description('Name of the resource group that Spring Apps creates for its app space. Specify this value in the parameters.json file to override this default.')
param appNetworkResourceGroup string

@description('Private IP address of the existing firewll. If this script is not configured to deploy a firewall, this value must be set')
param azureFirewallIp string

@description('Name of the default apps route table. Specify this value in the parameters.json file to override this default.')
param defaultAppsRouteName string

@description('Name of the default hub route table. Specify this value in the parameters.json file to override this default.')
param defaultHubRouteName string

@description('Name of the default runtime route table. Specify this value in the parameters.json file to override this default.')
param defaultRuntimeRouteName string

@description('Name of the default shared route table. Specify this value in the parameters.json file to override this default.')
param defaultSharedRouteName string

@description('Name of the resource group that contains the hub VNET. Specify this value in the parameters.json file to override this default.')
param hubVnetRgName string

@description('The Azure Region in which to deploy the Spring Apps Landing Zone Accelerator')
param location string

@description('Name of the log analytics workspace instance. Specify this value in the parameters.json file to override this default.')
param logAnalyticsWorkspaceName string

@description('The Azure AD Service Principal ID of the Azure Spring Cloud Resource Provider - this value varies by tenant - use the command "az ad sp show --id e8de9221-a19c-4c81-b814-fd37c6caf9d2 --query id --output tsv" to get the value specific to your tenant')
param principalId string

@description('Name of the resource group that contains the private DNS zones. Specify this value in the parameters.json file to override this default.')
param privateZonesRgName string

@description('Name of the spring apps instance. Specify this value in the parameters.json file to override this default.')
param springAppsName string

@description('The CIDR Range that will be used for the Spring Apps backend cluster')
param springAppsRuntimeCidr string

@description('IP CIDR Block for the Spoke VNET')
param spokeVnetAddressPrefix string

@description('Name of the resource group that contains the spoke VNET. Specify this value in the parameters.json file to override this default.')
param spokeRgName string

@description('Name of the RG that has the spoke VNET. Specify this value in the parameters.json file to override this default.')
param spokeVnetName string

@description('Name of the resource group that contains the shared resources. Specify this value in the parameters.json file to override this default.')
param sharedRgName string

@description('IP CIDR Block for the Shared Subnet')
param sharedSubnetPrefix string

@description('Network Security Group name for the Application Gateway subnet should you chose to deploy an AppGW. Specify this value in the parameters.json file to override this default.')
param snetAppGwNsg string

@description('Network Security Group name for the ASA app subnet. Specify this value in the parameters.json file to override this default.')
param snetAppNsg string

@description('Network Security Group name for the ASA runtime subnet. Specify this value in the parameters.json file to override this default.')
param snetRuntimeNsg string

@description('Network Security Group name for the shared subnet. Specify this value in the parameters.json file to override this default.')
param snetSharedNsg string

@description('Network Security Group name for the support subnet. Specify this value in the parameters.json file to override this default.')
param snetSupportNsg string

@description('IP CIDR Block for the Spring Apps Subnet')
param springAppsSubnetPrefix string

@description('IP CIDR Block for the Spring Apps Runtime Subnet')
param springAppsRuntimeSubnetPrefix string

@description('Name of the resource group that contains the Spring Apps Runtime Network. Specify this value in the parameters.json file to override this default.')
param serviceRuntimeNetworkResourceGroup string

@description('IP CIDR Block for the Support Subnet')
param supportSubnetPrefix string

@description('Azure Resource Tags')
param tags object

@description('Timestamp value used to group and uniquely identify a given deployment')
param timeStamp string

module defaultHubRoute '../Modules/udr.bicep' = {
  name: '${timeStamp}-default-hub-route'
  scope: resourceGroup(hubVnetRgName)
  params: {
    name: defaultHubRouteName
    location: location
    routes: [
      {
        name: 'default_egress'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: azureFirewallIp
        }
      }
    ]
  }
}

module defaultAppsRoute '../Modules/udr.bicep' = {
  name: '${timeStamp}-default-apps-route'
  scope: resourceGroup(spokeRgName)
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
          nextHopIpAddress: azureFirewallIp
        }
      }
    ]
  }
}

module defaultRuntimeRoute '../Modules/udr.bicep' = {
  name: '${timeStamp}-defaultRuntimeRoute'
  scope: resourceGroup(spokeRgName)
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
          nextHopIpAddress: azureFirewallIp
        }
      }
    ]
  }
}

module defaultSharedRoute '../Modules/udr.bicep' = {
  name: '${timeStamp}-defaultSharedRoute'
  scope: resourceGroup(spokeRgName)
  params: {
    name: defaultSharedRouteName
    location: location
    routes: [
      {
        name: 'default_egress'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: azureFirewallIp
        }
      }
    ]
  }
}

// Currently in Bicep you cannot associate a route table with an existing subnet, so this workaround
// effectively redeploys the network so that the UDRs defined above can be associated.
resource runtimeNsg 'Microsoft.Network/networkSecurityGroups@2022-09-01' existing = {
  name: snetRuntimeNsg
  scope: resourceGroup(spokeRgName)
}

resource appNsg 'Microsoft.Network/networkSecurityGroups@2022-09-01' existing = {
  name: snetAppNsg
  scope: resourceGroup(spokeRgName)
}

resource supportNsg 'Microsoft.Network/networkSecurityGroups@2022-09-01' existing = {
  name: snetSupportNsg
  scope: resourceGroup(spokeRgName)
}

resource sharedNsg 'Microsoft.Network/networkSecurityGroups@2022-09-01' existing = {
  name: snetSharedNsg
  scope: resourceGroup(spokeRgName)
}

resource agwNsg 'Microsoft.Network/networkSecurityGroups@2022-09-01' existing = {
  name: snetAppGwNsg
  scope: resourceGroup(spokeRgName)
}

module spokeVnet '../Modules/vnet.bicep' = {
  name: '${timeStamp}-${spokeVnetName}'
  scope: resourceGroup(spokeRgName)
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

resource appRg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: appRgName
  location: location
  tags: tags
}

module logAnalyticsWorkspace '../Modules/logAnalyticsWorkspace.bicep' = {
  name: '${timeStamp}-law'
  scope: resourceGroup(sharedRgName)
  params: {
    location: location
    name: logAnalyticsWorkspaceName
    tags: tags
  }
}

module appInsights '../Modules/appInsights.bicep' = {
  name: '${timeStamp}-app-insights'
  scope: resourceGroup(appRgName)
  params: {
    logAnalyticsId: logAnalyticsWorkspace.outputs.id
    location: location
    name: appInsightsName
    tags: tags
  }
  dependsOn: [
    logAnalyticsWorkspace
    appRg
  ]
}

module springApps '../Modules/springApps.bicep' = {
  name: '${timeStamp}-spring-apps'
  scope: resourceGroup(appRgName)
  params: {
    appNetworkResourceGroup: appNetworkResourceGroup
    appSubnetId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${spokeRgName}/providers/Microsoft.Network/virtualNetworks/${spokeVnetName}/subnets/snet-app'
    location: location
    name: springAppsName
    serviceCidr: springAppsRuntimeCidr
    serviceRuntimeSubnetId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${spokeRgName}/providers/Microsoft.Network/virtualNetworks/${spokeVnetName}/subnets/snet-runtime'
    serviceRuntimeNetworkResourceGroup: serviceRuntimeNetworkResourceGroup
    tags: tags
  }
  dependsOn: [
    appRg
    defaultAppsRoute
    defaultRuntimeRoute
    spokeVnet
  ]
}

module springAppsDns '../Modules/springAppsDnsZoneARecord.bicep' = {
  name: '${timeStamp}-spring-apps-dns-record'
  scope: resourceGroup(privateZonesRgName)
  params: {
    dnsZone: 'private.azuremicroservices.io'
    name: '*'
    runtimeRgName: serviceRuntimeNetworkResourceGroup
    ttl: 10
  }
  dependsOn: [
    springApps
  ]
}
