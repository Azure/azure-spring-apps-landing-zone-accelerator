param addressPrefixes array
param isForSpringApps bool = false
param location string
param name string
param principalId string = '' //This value is only required for VNETs that will host Azure Spring Apps.
param subnets array
param tags object

resource vnet 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    subnets: subnets
  }
  tags: tags
}

var roleDefinitionID = '8e3af657-a8ff-443c-a75c-2fe8c4bcb635' //ID of Owner Role. This value is global to Azure.
var roleAssignmentName = guid(vnet.name, roleDefinitionID, resourceGroup().id)

// When deploying an Azure Spring Apps instance, the Azure Spring Cloud Resource Provider needs to be able to make modifications to the 
// VNET during the provisioning process, so the principal ID gets passed in to assign the onwer role to the VNET
// See https://learn.microsoft.com/en-us/azure/spring-apps/how-to-deploy-in-azure-virtual-network?tabs=azure-portal#grant-service-permission-to-the-virtual-network
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (isForSpringApps) {
  name: roleAssignmentName
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionID)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
  scope: vnet
}

output id string = vnet.id
output name string = vnet.name
