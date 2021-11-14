param bastionpipId string
param subnetId string

resource bastion 'Microsoft.Network/bastionHosts@2021-02-01' = {
  name: 'bastion'
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'bastionConfig'
        properties: {
          publicIPAddress: {
            id: bastionpipId
          }
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}
