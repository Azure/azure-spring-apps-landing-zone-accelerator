targetScope = 'subscription'

@description('Name of the RG that has the Spring Apps instance. Leave blank if you need one created')
param appResourceGroupName string = 'rg-${namePrefix}-APPS'

param environment string

@description('The Azure Region in which to deploy the Spring Apps Landing Zone Accelerator')
param location string

@description('The common prefix used when naming resources')
param namePrefix string

@description('The CIDR Range that will be used for the Spring Apps backend cluster')
param serviceCidr string

@description('Name of the RG that has the spoke resources. Leave blank if you need one created')
param spokeResourceGroupName string = 'rg-${namePrefix}-SPOKE'

@description('Azure Resource Tags')
param tags object = {}

@description('Timestamp value used to group and uniquely identify a given deployment')
param timeStamp string = utcNow('yyyyMMddHHmm')

var randomSufix = substring(uniqueString(namePrefix), 0, 4)

resource appRg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: appResourceGroupName
  location: location
  tags: tags
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: 'law-${namePrefix}-${randomSufix}'
  scope: resourceGroup('rg-${namePrefix}-SHARED')
}

module appInsights '../Modules/appInsights.bicep' = {
  name: '${timeStamp}-appInsights'
  scope: resourceGroup(appResourceGroupName)
  params: {
    logAnalyticsId: logAnalytics.id
    location: location
    name: 'ai-${namePrefix}-${location}-${randomSufix}'
    tags: tags
  }
  dependsOn: [
    appRg
  ]
}

module springApps '../Modules/springApps.bicep' = {
  name: '${timeStamp}-springApps'
  scope: resourceGroup(appResourceGroupName)
  params: {
    appSubnetId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${spokeResourceGroupName}/providers/Microsoft.Network/virtualNetworks/vnet-${namePrefix}-${location}-SPOKE/subnets/snet-app'
    location: location
    name: 'spring-${namePrefix}-${location}-${substring(uniqueString(timeStamp), 0, 4)}'
    serviceCidr: serviceCidr
    serviceRuntimeSubnetId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${spokeResourceGroupName}/providers/Microsoft.Network/virtualNetworks/vnet-${namePrefix}-${location}-SPOKE/subnets/snet-runtime'
    tags: tags
  }
  dependsOn: [
    appRg
  ]
}
