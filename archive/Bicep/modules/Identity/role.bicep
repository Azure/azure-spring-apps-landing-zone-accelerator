param principalId string
param roleGuid string
param resourceName string
param resourceType string

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = if(resourceType == 'vnet') {
  name: resourceName
}

resource routeTbl 'Microsoft.Network/routeTables@2021-02-01' existing = if(resourceType == 'route') {
  name: resourceName
}

resource roleassignmentVnet 'Microsoft.Authorization/roleAssignments@2021-04-01-preview' = if(resourceType == 'vnet') {
  name: guid(subscription().id, vnet.name)
  scope: vnet
  properties: {
    principalId: principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleGuid)
  }
}

resource roleassignmentRoute 'Microsoft.Authorization/roleAssignments@2021-04-01-preview' = if(resourceType == 'route') {
  name: guid(subscription().id, routeTbl.name)
  scope: routeTbl
  properties: {
    principalId: principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleGuid)
  }
}
