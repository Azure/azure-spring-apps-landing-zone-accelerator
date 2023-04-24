param isForSpringApps bool = false
param location string
param name string
param principalId string = '' //This value is only required for user defined routes used Azure Spring Apps.
param routes array
param tags object = {}

resource route 'Microsoft.Network/routeTables@2022-09-01' = {
  name: name
  location: location
  properties: {
    disableBgpRoutePropagation: false
    routes: routes
  }
  tags: tags
}

var roleDefinitionID = '8e3af657-a8ff-443c-a75c-2fe8c4bcb635' //ID of Owner Role. This value is global to Azure.
var roleAssignmentName = guid(route.name, roleDefinitionID, resourceGroup().id)

// When deploying an Azure Spring Apps instance, the Azure Spring Cloud Resource Provider needs to be able to make modifications to the 
// UDR during the provisioning process, so the principal ID gets passed in to assign the onwer role to the user defined route.
// See https://learn.microsoft.com/en-us/azure/spring-apps/how-to-deploy-in-azure-virtual-network?tabs=azure-portal#grant-service-permission-to-the-virtual-network
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01'= if(isForSpringApps) {
  name: roleAssignmentName
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionID)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
  scope: route
}

output id string = route.id
