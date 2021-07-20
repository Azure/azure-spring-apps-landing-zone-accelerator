param name string
param location string
param tags object
param laretentionDays int

resource laworkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: name 
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: laretentionDays
  }
}

output laworkspaceName string = laworkspace.name
output laworkspaceId string = laworkspace.id
output laworkspaceCId string = laworkspace.properties.customerId
output laworkspaceKey string = listKeys(laworkspace.id, '2015-11-01-preview').primarySharedKey
