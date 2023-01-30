param autoRegistration bool
param vnetId string
param vnetName string
param zoneName string

resource virtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  name: '${zoneName}/${vnetName}-link'
  location: 'global'
  properties: {
    registrationEnabled: autoRegistration
    virtualNetwork: {
      id: vnetId
    }
  }
}
