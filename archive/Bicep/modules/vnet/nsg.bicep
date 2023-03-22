param nsgName string
param nsgLocation string
param nsgTags object

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: nsgName
  location: nsgLocation
  tags: nsgTags
  properties: {
    securityRules: []
  }
}

output nsgId string = nsg.id
