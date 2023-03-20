param name string
param location string
param tags object
param skuName string
param skuTier string
param springAppsServiceCidrs string
param rtsubnetId string
param appsubnetId string
param workspaceId string
param appInsightsInstrumentationKey string

resource springapps 'Microsoft.AppPlatform/Spring@2020-07-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    networkProfile: {
      serviceCidr: springAppsServiceCidrs
      serviceRuntimeSubnetId: rtsubnetId
      appSubnetId: appsubnetId
    }
  }
}

resource springAppsMonitoringSettings 'Microsoft.AppPlatform/Spring/monitoringSettings@2020-07-01' = {
  name: '${springapps.name}/default'
  properties: {
    traceEnabled: true
    appInsightsInstrumentationKey: appInsightsInstrumentationKey
  }
}

resource springappsdiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: 'springappsdiagnostics'
  scope: springapps
  properties: {
    logs: [
      {
        category: 'ApplicationConsole'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: false
        }
      }
    ]
    workspaceId: workspaceId
  }
}

output springappsName string = springapps.name
output springAppsNetworkRG string = springapps.properties.networkProfile.serviceRuntimeNetworkResourceGroup
