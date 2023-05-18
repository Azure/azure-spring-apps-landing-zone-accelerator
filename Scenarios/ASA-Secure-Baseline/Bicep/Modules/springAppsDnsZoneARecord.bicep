param dnsZone string
param name string
param runtimeRgName string
param ttl int

resource ilb 'Microsoft.Network/loadBalancers@2022-11-01' existing = {
  name: 'kubernetes-internal'
  scope: resourceGroup(runtimeRgName)
}

resource aRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: '${dnsZone}/${name}'
  properties: {
    aRecords: [
      {
        ipv4Address: ilb.properties.frontendIPConfigurations[0].properties.privateIPAddress
      }
    ]
    ttl: ttl
  }
}
