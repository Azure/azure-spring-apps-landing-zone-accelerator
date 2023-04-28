param parentKeyVaultName string
param secretName string
@secure()
param secretValue string

resource parentKeyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: parentKeyVaultName
}

resource kvSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: secretName
  parent: parentKeyVault
  properties: {
    value: secretValue
  }
}
