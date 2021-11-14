param name string
param networkrg string

resource springcloudlb 'Microsoft.Network/loadBalancers@2020-05-01' existing = {
  name: 'kubernetes-internal'
  scope: resourceGroup(networkrg)
}

resource arecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: name
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: springcloudlb.properties.frontendIPConfigurations[0].properties.privateIPAddress
      }
    ]
  }
}
