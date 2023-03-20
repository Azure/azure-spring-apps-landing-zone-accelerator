param privateDNSZoneId string
param privateEndpointName string

resource privateDNSZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = {
  name: '${privateEndpointName}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDNSZoneId
        }
      }
    ]
  }
}
