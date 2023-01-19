param location string
param name string
param securityRules array
param tags object

resource nsg 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: name
  location: location
  properties: {
    securityRules: securityRules
  }
  tags: tags
}

output id string = nsg.id
output nsgName string = nsg.name
