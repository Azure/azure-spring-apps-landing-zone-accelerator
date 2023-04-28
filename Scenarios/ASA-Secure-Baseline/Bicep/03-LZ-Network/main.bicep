targetScope = 'subscription'

/******************************/
/*         PARAMETERS         */
/******************************/
@description('IP CIDR Block for the App Gateway Subnet')
param appGwSubnetPrefix string

@description('Name of the hub VNET. Specify this value in the parameters.json file to override this default.')
param hubVnetName string = 'vnet-${namePrefix}-${location}-HUB'

@description('Name of the RG that has the hub VNET. Specify this value in the parameters.json file to override this default.')
param hubVnetResourceGroupName string = 'rg-${namePrefix}-HUB'

@description('The Azure Region in which to deploy the Spring Apps Landing Zone Accelerator')
param location string

@description('The common prefix used when naming resources')
param namePrefix string

@description('The Azure AD Service Principal ID of the Azure Spring Cloud Resource Provider - this value varies by tenant - use the command "az ad sp show --id e8de9221-a19c-4c81-b814-fd37c6caf9d2 --query id --output tsv" to get the value specific to your tenant')
param principalId string

@description('Name of the resource group that contains the private DNS zones. Specify this value in the parameters.json file to override this default.')
param privateZonesRgName string = 'rg-${namePrefix}-PRIVATEZONES'

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
param spokeRgName string = 'rg-${namePrefix}-SPOKE'

@description('IP CIDR Block for the Spoke VNET')
param spokeVnetAddressPrefix string

@description('Name of the RG that has the spoke VNET. Specify this value in the parameters.json file to override this default.')
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
resource hubVnetRg 'Microsoft.Resources/resourceGroups@2022-09-01' existing = {
  name: hubVnetResourceGroupName
}

resource hubVnet 'Microsoft.Network/virtualNetworks@2020-06-01' existing = {
  name: hubVnetName
  scope: resourceGroup(hubVnetRg.name)
}

resource spokeRg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: spokeRgName
  location: location
  tags: tags
}

resource privateZonesRg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: privateZonesRgName
  location: location
  tags: tags
}

module spokeVnet '../Modules/vnet.bicep' = {
  name: '${timeStamp}-spoke-vnet'
  scope: resourceGroup(spokeRg.name)
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
            id: runtimeNsg.outputs.id
          }
        }
      }
      {
        name: 'snet-app'
        properties: {
          addressPrefix: springAppsSubnetPrefix
          networkSecurityGroup: {
            id: appNsg.outputs.id
          }
        }
      }
      {
        name: 'snet-support'
        properties: {
          addressPrefix: supportSubnetPrefix
          networkSecurityGroup: {
            id: supportNsg.outputs.id
          }
        }
      }
      {
        name: 'snet-shared'
        properties: {
          addressPrefix: sharedSubnetPrefix
          networkSecurityGroup: {
            id: sharedNsg.outputs.id
          }
        }
      }
      {
        name: 'snet-agw'
        properties: {
          addressPrefix: appGwSubnetPrefix
          networkSecurityGroup: {
            id: agwNsg.outputs.id
          }
        }
      }
    ]
    tags: tags
  }
  dependsOn: [
    appNsg
    runtimeNsg
    supportNsg
    sharedNsg
    agwNsg
  ]
}

module appNsg '../Modules/nsg.bicep' = {
  name: '${timeStamp}-nsg-snet-app'
  scope: resourceGroup(spokeRg.name)
  params: {
    name: snetAppNsg
    location: location
    securityRules: []
    tags: tags
  }
}

module runtimeNsg '../Modules/nsg.bicep' = {
  name: '${timeStamp}-nsg-snet-runtime'
  scope: resourceGroup(spokeRg.name)
  params: {
    name: snetRuntimeNsg
    location: location
    securityRules: []
    tags: tags
  }
}

module supportNsg '../Modules/nsg.bicep' = {
  name: '${timeStamp}-nsg-snet-support'
  scope: resourceGroup(spokeRg.name)
  params: {
    name: snetSupportNsg
    location: location
    securityRules: []
    tags: tags
  }
}

module sharedNsg '../Modules/nsg.bicep' = {
  name: '${timeStamp}-nsg-snet-shared'
  scope: resourceGroup(spokeRg.name)
  params: {
    name: snetSharedNsg
    location: location
    securityRules: []
    tags: tags
  }
}

module agwNsg '../Modules/nsg.bicep' = {
  name: '${timeStamp}-nsg-snet-agw'
  scope: resourceGroup(spokeRg.name)
  params: {
    name: snetAppGwNsg
    location: location
    securityRules: [
      {
        name: 'AllowHTTPSInbound'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowHTTPInbound'
        properties: {
          priority: 200
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowGatewayManagerInbound'
        properties: {
          priority: 300
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '65200-65535'
          sourceAddressPrefix: 'GatewayManager'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowAzureLBInbound'
        properties: {
          priority: 400
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: '*'
        }
      }
    ]
    tags: tags
  }
}

// Private DNS zone for Spring Apps
module privateZoneSpringApps '../Modules/privateDnsZone.bicep' = {
  name: '${timeStamp}-dns-private-springapps'
  scope: resourceGroup(privateZonesRg.name)
  params: {
    tags: tags
    zoneName: 'private.azuremicroservices.io'
  }
}

module hubVnetSpringAppsZoneLink '../Modules/virtualNetworkLink.bicep' = {
  name: '${timeStamp}-dns-hub-link-springapps'
  scope: resourceGroup(privateZonesRg.name)
  dependsOn: [
    privateZoneSpringApps
  ]
  params: {
    vnetName: hubVnet.name
    vnetId: hubVnet.id
    zoneName: 'private.azuremicroservices.io'
    autoRegistration: false
  }
}

module spokeVnetSpringAppsZoneLink '../Modules/virtualNetworkLink.bicep' = {
  name: '${timeStamp}-dns-spoke-link-springapps'
  scope: resourceGroup(privateZonesRg.name)
  dependsOn: [
    privateZoneSpringApps
    spokeVnet
  ]
  params: {
    vnetName: spokeVnet.outputs.name
    vnetId: spokeVnet.outputs.id
    zoneName: 'private.azuremicroservices.io'
    autoRegistration: false
  }
}

// Private DNS zone for Key Vault
module privateZoneKv '../Modules/privateDnsZone.bicep' = {
  name: '${timeStamp}-dns-private-kv'
  scope: resourceGroup(privateZonesRg.name)
  params: {
    tags: tags
    zoneName: 'privatelink.vaultcore.azure.net'
  }
}

module hubVnetKvZoneLink '../Modules/virtualNetworkLink.bicep' = {
  name: '${timeStamp}-dns-hub-link-kv'
  scope: resourceGroup(privateZonesRg.name)
  dependsOn: [
    privateZoneKv
  ]
  params: {
    vnetName: hubVnet.name
    vnetId: hubVnet.id
    zoneName: 'privatelink.vaultcore.azure.net'
    autoRegistration: false
  }
}

module spokeVnetKvZoneLink '../Modules/virtualNetworkLink.bicep' = {
  name: '${timeStamp}-dns-spoke-link-kv'
  scope: resourceGroup(privateZonesRg.name)
  dependsOn: [
    privateZoneSpringApps
    spokeVnet
  ]
  params: {
    vnetName: spokeVnet.outputs.name
    vnetId: spokeVnet.outputs.id
    zoneName: 'privatelink.vaultcore.azure.net'
    autoRegistration: false
  }
}

module hubToSpokePeering '../Modules/virtualNetworkPeering.bicep' = {
  name: '${timeStamp}-vnet-hubToSpokePeering'
  scope: resourceGroup(hubVnetRg.name)
  params: {
    localVnetName: hubVnet.name
    remoteVnetName: spokeVnet.outputs.name
    remoteVnetId: spokeVnet.outputs.id
  }
  dependsOn: [
    spokeVnet
  ]
}

module spokeToHubPeering '../Modules/virtualNetworkPeering.bicep' = {
  name: '${timeStamp}-vnet-spokeToHubPeering'
  scope: resourceGroup(spokeRg.name)
  params: {
    localVnetName: spokeVnet.outputs.name
    remoteVnetName: hubVnet.name
    remoteVnetId: hubVnet.id
  }
  dependsOn: [
    spokeVnet
  ]
}
