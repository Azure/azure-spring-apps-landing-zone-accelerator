param privateDNSZoneName string
param virtualNetworkid string
param privateZoneLinkName string

resource virtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${privateDNSZoneName}/${privateZoneLinkName}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworkid
    }
  }
}
