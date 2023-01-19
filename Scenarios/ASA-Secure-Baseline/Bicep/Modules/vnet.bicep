param addressSpaces array
param location string
param subnets array
param tags object
param vnetName string

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: addressSpaces
    }
    subnets: subnets
  }
  tags: tags
}

output name string = vnet.name
output id string = vnet.id
