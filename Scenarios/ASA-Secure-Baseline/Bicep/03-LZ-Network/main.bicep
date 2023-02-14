targetScope = 'subscription'

/******************************/
/*         PARAMETERS         */
/******************************/
@description('IP CIDR Block for the App Gateway Subnet')
param appGwSubnetSpace string

@description('Name of the hub VNET. Leave blank if you need one created')
param hubVnetName string = 'vnet-${namePrefix}-${location}-HUB'

@description('Name of the RG that has the hub VNET. Leave blank if you need one created')
param hubVnetResourceGroupName string = 'rg-${namePrefix}-HUB'

@description('The Azure Region in which to deploy the Spring Apps Landing Zone Accelerator')
param location string

@description('The common prefix used when naming resources')
param namePrefix string

@description('IP CIDR Block for the Shared Subnet')
param sharedSubnetSpace string

@description('Spoke VNET Prefix')
param spokeVnetAddressPrefixes string

@description('Name of the RG that has the spoke VNET. Leave blank if you need one created')
param spokeVnetName string = 'vnet-${namePrefix}-${location}-SPOKE'

@description('IP CIDR Block for the Spring Apps Subnet')
param springBootAppsSubnetSpace string

@description('IP CIDR Block for the Spring Apps Service Subnet')
param springBootServiceSubnetSpace string

@description(' for the Spring Apps SUpport Subnet')
param springBootSupportSubnetSpace string

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
  name: 'rg-${namePrefix}-SPOKE'
  location: location
  tags: tags
}

module spokeVnet '../Modules/vnet.bicep' = {
  name: '${timeStamp}-${spokeVnetName}'
  scope: resourceGroup(spokeRg.name)
  params: {
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
            id: runtimeNsg.outputs.id
          }
        }
      }
      {
        name: 'snet-app'
        properties: {
          addressPrefix: springBootAppsSubnetSpace
          networkSecurityGroup: {
            id: appNsg.outputs.id
          }
        }
      }
      {
        name: 'snet-support'
        properties: {
          addressPrefix: springBootSupportSubnetSpace
          networkSecurityGroup: {
            id: supportNsg.outputs.id
          }
        }
      }
      {
        name: 'snet-shared'
        properties: {
          addressPrefix: sharedSubnetSpace
          networkSecurityGroup: {
            id: sharedNsg.outputs.id
          }
        }
      }
      {
        name: 'snet-agw'
        properties: {
          addressPrefix: appGwSubnetSpace
          networkSecurityGroup: {
            id: agwNsg.outputs.id
          }
        }
      }
    ]
    tags: tags
  }
}

module appNsg '../Modules/nsg.bicep' = {
  name: '${timeStamp}-${namePrefix}-snet-app-nsg'
  scope: resourceGroup(spokeRg.name)
  params: {
    name: 'snet-app-nsg'
    location: location
    securityRules: [ ]
    tags: tags
  }
}

module runtimeNsg '../Modules/nsg.bicep' = {
  name: '${timeStamp}-${namePrefix}-snet-runtime-nsg'
  scope: resourceGroup(spokeRg.name)
  params: {
    name: 'snet-runtime-nsg'
    location: location
    securityRules: [ ]
    tags: tags
  }
}

module supportNsg '../Modules/nsg.bicep' = {
  name: '${timeStamp}-${namePrefix}-snet-support-nsg'
  scope: resourceGroup(spokeRg.name)
  params: {
    name: 'snet-support-nsg'
    location: location
    securityRules: []
    tags: tags
  }
}

module sharedNsg '../Modules/nsg.bicep' = {
  name: '${timeStamp}-${namePrefix}-snet-shared-nsg'
  scope: resourceGroup(spokeRg.name)
  params: {
    name: 'snet-shared-nsg'
    location: location
    securityRules: []
    tags: tags
  }
}

module agwNsg '../Modules/nsg.bicep' = {
  name: '${timeStamp}-${namePrefix}-snet-agw-nsg'
  scope: resourceGroup(spokeRg.name)
  params: {
    name: 'snet-agw-nsg'
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
  name: '${timeStamp}-${namePrefix}-dns-private-springapps'
  scope: resourceGroup(hubVnetRg.name)
  params: {
    tags: tags
    zoneName: 'private.azuremicroservices.io'
  }
}

module hubVnetSpringAppsZoneLink '../Modules/virtualNetworkLink.bicep' = {
  name: '${timeStamp}-${namePrefix}-dns-hub-link-springapps'
  scope: resourceGroup(hubVnetRg.name)
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
  name: '${timeStamp}-${namePrefix}-dns-spoke-link-springapps'
  scope: resourceGroup(hubVnetRg.name)
  dependsOn: [
    privateZoneSpringApps
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
  name: '${timeStamp}-${namePrefix}-dns-private-kv'
  scope: resourceGroup(hubVnetRg.name)
  params: {
    tags: tags
    zoneName: 'privatelink.vaultcore.azure.net'
  }
}

module hubVnetKvZoneLink '../Modules/virtualNetworkLink.bicep' = {
  name: '${timeStamp}-${namePrefix}-dns-hub-link-kv'
  scope: resourceGroup(hubVnetRg.name)
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
  name: '${timeStamp}-${namePrefix}-dns-spoke-link-kv'
  scope: resourceGroup(hubVnetRg.name)
  dependsOn: [
    privateZoneSpringApps
  ]
  params: {
    vnetName: spokeVnet.outputs.name
    vnetId: spokeVnet.outputs.id
    zoneName: 'privatelink.vaultcore.azure.net'
    autoRegistration: false
  }
}

module hubToSpokePeering '../Modules/virtualNetworkPeering.bicep' = {
  name: '${timeStamp}-${namePrefix}-vnet-hubToSpokePeering'
  scope: resourceGroup(hubVnetRg.name)
  params: {
    localVnetName: hubVnet.name
    remoteVnetName: spokeVnet.outputs.name
    remoteVnetId: spokeVnet.outputs.id
  }
}

module spokeToHubPeering '../Modules/virtualNetworkPeering.bicep' = {
  name: '${timeStamp}-${namePrefix}-vnet-spokeToHubPeering'
  scope: resourceGroup(spokeRg.name)
  params: {
    localVnetName: spokeVnet.outputs.name
    remoteVnetName: hubVnet.name
    remoteVnetId: hubVnet.id
  }
}

//TODO Grant owner to Azure AD Service Principle to Spoke VNET
