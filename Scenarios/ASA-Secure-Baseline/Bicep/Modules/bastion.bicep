param location string
param name string
param subnetId string

resource bastionIP 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: 'azure-bastion-ip'
  location: location
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2020-06-01' = {
  name: name
  location: location
  properties: {
    ipConfigurations: [
      { name: 'configuration', properties: {
          subnet: {
            id: subnetId
          }
          publicIPAddress: {
            id: bastionIP.id
          }
        }
      }
    ]
  }
}
