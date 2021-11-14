param name string
param location string
param tags object
param keyVaultsku string
param tenantId string
param keyVaultObjectId string
param permissions object

resource keyvault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: keyVaultsku
    }
    tenantId: tenantId
    accessPolicies: [
      {
        objectId: keyVaultObjectId
        permissions: permissions
        tenantId: tenantId
      }
    ]
  }
}

output keyvaultId string = keyvault.id
