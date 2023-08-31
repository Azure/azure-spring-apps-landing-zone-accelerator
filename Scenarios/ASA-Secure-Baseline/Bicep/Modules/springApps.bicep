param appInsightsInstrumentationKey string = ''
param appSubnetId string
param appNetworkResourceGroup string
param enterprise bool
param location string
param name string
param sku object
param serviceCidr string
param serviceRuntimeNetworkResourceGroup string
param serviceRuntimeSubnetId string
param tags object
param workspaceId string

resource springApps 'Microsoft.AppPlatform/Spring@2022-12-01' = {
  name: name
  location: location
  properties: {
    networkProfile: {
      appNetworkResourceGroup: appNetworkResourceGroup
      appSubnetId: appSubnetId
      serviceRuntimeNetworkResourceGroup: serviceRuntimeNetworkResourceGroup
      serviceRuntimeSubnetId: serviceRuntimeSubnetId
      serviceCidr: serviceCidr
    }
  }
  sku: sku
  tags: tags
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'monitoring'
  scope: springApps
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'ApplicationConsole'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}

//TODO: This is app specific so should be moved out of baseline and into the app layer
/*
resource configService 'Microsoft.AppPlatform/Spring/configurationServices@2022-12-01' = if (enterprise) {
  parent: springApps
  name: 'default'
}
*/

resource springCloudGateway 'Microsoft.AppPlatform/Spring/gateways@2022-12-01' = if (enterprise) {
  parent: springApps
  name: 'default'
  properties: {
    public: true
  }
  sku: {
    name: 'E0'
    capacity: 2
  }
}

resource apiPortal 'Microsoft.AppPlatform/Spring/apiPortals@2022-12-01' = if (enterprise) {
  parent: springApps
  name: 'default'
  properties: {
    gatewayIds: [
      springCloudGateway.id
    ]
    httpsOnly: false
    public: true
  }
  sku: {
    name: 'E0'
    capacity: 1
  }
}

resource serviceRegistry 'Microsoft.AppPlatform/Spring/serviceRegistries@2022-12-01' = if (enterprise) {
  parent: springApps
  name: 'default'
}

resource monitoringSettings 'Microsoft.AppPlatform/Spring/monitoringSettings@2022-12-01' = if (enterprise) {
  parent: springApps
  name: 'default'
  properties: {
    appInsightsInstrumentationKey: appInsightsInstrumentationKey
  }
}

resource buildService 'Microsoft.AppPlatform/Spring/buildServices@2023-03-01-preview' = if (enterprise) {
  parent: springApps
  name: 'default'
  properties: {
    resourceRequests: {}
  }
}

resource agentPool 'Microsoft.AppPlatform/Spring/buildServices/agentPools@2023-03-01-preview' = if (enterprise) {
  parent: buildService
  name: 'default'
  properties: {
    poolSize: {
      name: 'S1'
    }
  }
}

resource builder 'Microsoft.AppPlatform/Spring/buildServices/builders@2022-12-01' existing = {
  name: 'default'
  parent: buildService
}

resource buildPackBinding 'Microsoft.AppPlatform/Spring/buildServices/builders/buildpackBindings@2022-12-01' = if (enterprise) {
  parent: builder
  name: 'default'
  properties: {
    bindingType: 'ApplicationInsights'
  }
}
