param dnsResourceGroupName string
param enableSoftDelete bool
param location string
param name string
param networkResourceGroupName string
param subnetName string
param tags object
param targetResourceGroupName string
param tenantId string = tenant().tenantId
param timeStamp string
param vnetName string

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: name
  location: location
  properties: {
    sku: {
      name: 'standard'
      family: 'A'
    }
    tenantId: tenantId
    accessPolicies: []
    enableSoftDelete: enableSoftDelete
    enableRbacAuthorization: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
  }
  tags: tags
}

module privateEndpoint 'privateendpoint.bicep' = {
  name: '${timeStamp}-${name}-privateEndpoint'
  scope: resourceGroup(targetResourceGroupName)
  params: {
    dnsResourceGroupName: dnsResourceGroupName
    dnsZoneName: 'privatelink.vaultcore.azure.net'
    groupId: 'vault'
    location: location
    networkResourceGroupName: networkResourceGroupName
    privateEndpointName: 'sc-keyvault-endpoint'
    serviceResourceId: keyVault.id
    subnetName: subnetName
    tags: tags
    vnetName: vnetName
  }
}

output name string = keyVault.name
