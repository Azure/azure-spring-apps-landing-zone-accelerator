targetScope = 'subscription'

@description('Name of the application insights instance. Specify this value in the parameters.json file to override this default.')
param appInsightsName string

@description('Name of the resource group that contains the Spring Apps instance. Specify this value in the parameters.json file to override this default.')
param appRgName string

@description('The Azure Region in which to deploy the Spring Apps Landing Zone Accelerator')
param location string

@description('Name of the log analytics workspace instance. Specify this value in the parameters.json file to override this default.')
param logAnalyticsWorkspaceName string

@description('Name of the spring apps instance. Specify this value in the parameters.json file to override this default.')
param springAppsName string

@description('The CIDR Range that will be used for the Spring Apps backend cluster')
param springAppsRuntimeCidr string

@description('Name of the resource group that contains the spoke VNET. Specify this value in the parameters.json file to override this default.')
param spokeRgName string

@description('Name of the RG that has the spoke VNET. Specify this value in the parameters.json file to override this default.')
param spokeVnetName string

@description('Name of the resource group that contains the shared resources. Specify this value in the parameters.json file to override this default.')
param sharedRgName string

@description('Azure Resource Tags')
param tags object

@description('Timestamp value used to group and uniquely identify a given deployment')
param timeStamp string

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
    appSubnetId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${spokeRgName}/providers/Microsoft.Network/virtualNetworks/${spokeVnetName}/subnets/snet-app'
    location: location
    name: springAppsName
    serviceCidr: springAppsRuntimeCidr
    serviceRuntimeSubnetId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${spokeRgName}/providers/Microsoft.Network/virtualNetworks/${spokeVnetName}/subnets/snet-runtime'
    tags: tags
  }
  dependsOn: [
    appRg
  ]
}
