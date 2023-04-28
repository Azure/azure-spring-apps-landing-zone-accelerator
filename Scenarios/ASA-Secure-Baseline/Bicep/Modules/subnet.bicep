param addressPrefix string
param delegations array = []
param name string
param networkSecurityGroup object = {}
param serviceEndpoints array = []
param vnetName string

resource vnet 'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  name: vnetName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' = {
  name: name
  parent: vnet
  properties: {
    addressPrefix: addressPrefix
    delegations: delegations
    serviceEndpoints: serviceEndpoints
    networkSecurityGroup: empty(networkSecurityGroup) ? null : networkSecurityGroup
  }
}

output id string = subnet.id
