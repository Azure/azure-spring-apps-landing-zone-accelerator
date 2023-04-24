param addressPrefix string
param vnetName string
param name string

resource vnet 'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  name: vnetName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' = {
  name: name
  parent: vnet
  properties: {
    addressPrefix: addressPrefix
  }
}
