param name string
param location string
param tags object
param skuName string
param skuTier string
param springCloudServiceCidrs string
param rtsubnetId string
param appsubnetId string
param workspaceId string
param appInsightsInstrumentationKey string

resource springcloud 'Microsoft.AppPlatform/Spring@2020-07-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    networkProfile: {
      serviceCidr: springCloudServiceCidrs
      serviceRuntimeSubnetId: rtsubnetId
      appSubnetId: appsubnetId
    }
  }
}

resource springCloudMonitoringSettings 'Microsoft.AppPlatform/Spring/monitoringSettings@2020-07-01' = {
  name: '${springcloud.name}/default'
  properties: {
    traceEnabled: true
    appInsightsInstrumentationKey: appInsightsInstrumentationKey
  }
}

resource springclouddiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: 'springclouddiagnostics'
  scope: springcloud
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

output springcloudName string = springcloud.name
output springCloudNetworkRG string = springcloud.properties.networkProfile.serviceRuntimeNetworkResourceGroup
