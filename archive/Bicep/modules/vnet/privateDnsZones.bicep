param name string

resource privateDnsZones 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: name
  location: 'global'
}

output privateDNSZoneName string = privateDnsZones.name
output privateDNSZoneId string = privateDnsZones.id
