param addressPrefixes array
param name string
param location string
param subnets array
param tags object


resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
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

output id string = vnet.id
output name string = vnet.name
