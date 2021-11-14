param vnetName string
param location string
param tags object
param cidr string
param subnets array
param ddosProtection bool

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        cidr
      ]
    }
    subnets: subnets
    enableDdosProtection: ddosProtection
  }
}

output vnetName string = vnet.name
output vnetId string = vnet.id
