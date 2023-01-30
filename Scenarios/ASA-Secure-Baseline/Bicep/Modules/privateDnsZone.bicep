param zoneName string

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: zoneName
  location: 'global'
}

output id string = privateDnsZone.id
