@description('The instance name of the Azure Spring Apps resource')
param springAppsInstanceName string

@description('The name of the Application Insights instance for Azure Spring Apps')
param appInsightsName string

@description('The resource ID of the existing Log Analytics workspace. This will be used for both diagnostics logs and Application Insights')
param laWorkspaceResourceId string

@description('The resourceID of the Azure Spring Apps App Subnet')
param springAppsAppSubnetID string

@description('The resourceID of the Azure Spring Apps Runtime Subnet')
param springAppsRuntimeSubnetID string

@description('Comma-separated list of IP address ranges in CIDR format. The IP ranges are reserved to host underlying Azure Spring Apps infrastructure, which should be 3 at least /16 unused IP ranges, must not overlap with any Subnet IP ranges')
param springAppsServiceCidrs string = '10.0.0.0/16,10.2.0.0/16,10.3.0.1/16'

@description('The tags that will be associated to the Resources')
param tags object = {
  environment: 'lab'
}

var springAppsSkuName = 'S0'
var springAppsSkuTier = 'Standard'
var location = resourceGroup().location

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: appInsightsName
  location: location
  kind: 'web'
  tags: tags
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Bluefield'
    Request_Source: 'rest'
    WorkspaceResourceId: laWorkspaceResourceId
  }
}

resource springAppsInstance 'Microsoft.AppPlatform/Spring@2020-07-01' = {
  name: springAppsInstanceName
  location: location
  tags: tags
  sku: {
    name: springAppsSkuName
    tier: springAppsSkuTier
  }
  properties: {
    networkProfile: {
      serviceCidr: springAppsServiceCidrs
      serviceRuntimeSubnetId: springAppsRuntimeSubnetID
      appSubnetId: springAppsAppSubnetID
    }
  }
}

resource springAppsMonitoringSettings 'Microsoft.AppPlatform/Spring/monitoringSettings@2020-07-01' = {
  name: '${springAppsInstance.name}/default'
  properties: {
    traceEnabled: true
    appInsightsInstrumentationKey: appInsights.properties.InstrumentationKey
  }
}

resource springAppsDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: 'monitoring'
  scope: springAppsInstance
  properties: {
    workspaceId: laWorkspaceResourceId
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
  }
}
