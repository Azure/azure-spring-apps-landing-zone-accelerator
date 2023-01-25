targetScope = 'subscription'

@description('Name of the hub VNET. Leave blank if you need one created')
param hubVnetName string = 'vnet-${namePrefix}-${location}-HUB'
@description('Name of the RG that has the hub VNET. Leave blank if you need one created')
param hubVnetResourceGroupName string = 'rg-${namePrefix}-HUB'
@description('The Azure Region in which to deploy the Spring Apps Landing Zone Accelerator')
param location string
@description('The common prefix used when naming resources')
param namePrefix string
@description('Spoke VNET Prefix')
param spokeVnetAddressPrefixes string
param tags object = {}
@description('Timestamp value used to group and uniquely identify a given deployment')
param timeStamp string = utcNow('yyyyMMddHHmm')

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
  name: '${timeStamp}-${hubVnetName}'
  scope: resourceGroup(hubVnetRg.name)
  params: {
    name: hubVnetName
    location: location
    addressPrefixes: [
      spokeVnetAddressPrefixes
    ]
    subnets: []
    tags: tags
  }
}
