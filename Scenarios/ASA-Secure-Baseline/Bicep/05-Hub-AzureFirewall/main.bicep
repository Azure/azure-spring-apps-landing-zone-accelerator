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

@description('Azure Resource Tags')
param tags object = {}

@description('Timestamp value used to group and uniquely identify a given deployment')
param timeStamp string = utcNow('yyyyMMddHHmm')

var azfwSubnetName = 'AzureFirewallSubnet'

module azfwSubnet '../Modules/subnet.bicep' = {
  name: '${timeStamp}-${namePrefix}-azfwSubnet'
  scope: resourceGroup(hubVnetResourceGroupName)
  params: {
    azureFirewallSubnetSpace: azureFirewallSubnetSpace
    hubVentName: hubVnetName
    name: azfwSubnetName
  }
}

module azfw '../Modules/azfw.bicep' = {
  name: '${timeStamp}-${namePrefix}-kv'
  scope: resourceGroup(hubVnetResourceGroupName)
  params: {
    fireWallSubnetName: azfwSubnetName
    hubVnetName: 'vnet-${namePrefix}-${location}-HUB'
    location: location
    name: 'fw-${namePrefix}'
    tags: tags
  }
}
