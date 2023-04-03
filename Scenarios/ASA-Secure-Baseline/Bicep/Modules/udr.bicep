param isForSpringApps bool = false
param name string
param routes array
param location string = resourceGroup().location

resource route 'Microsoft.Network/routeTables@2022-09-01' = {
  name: name
  location: location
  properties: {
    disableBgpRoutePropagation: false
    routes: routes
  }
}

var roleDefinitionID = '8e3af657-a8ff-443c-a75c-2fe8c4bcb635' //ID of Owner Role
var roleAssignmentName= guid(route.name, roleDefinitionID, resourceGroup().id)

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01'= if(isForSpringApps) {
  name: roleAssignmentName
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionID)
    principalId: '77e44c53-4911-427e-83c2-e2a52f569dee' //ID of Azure Spring Cloud Resource Provider -- az ad sp show --id e8de9221-a19c-4c81-b814-fd37c6caf9d2 --query id --output tsv
    principalType: 'ServicePrincipal'
  }
  scope: route
}

output id string = route.id
