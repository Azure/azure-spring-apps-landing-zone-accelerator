param name string
param location string
param tags object
param azfirewallPvtIpAddr string

resource routetable 'Microsoft.Network/routeTables@2021-02-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    routes: [
      {
        name: 'udr-default'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: azfirewallPvtIpAddr
        }
      }
    ]
    disableBgpRoutePropagation: false
  }
}

output routeTableName string = routetable.name
output routeTableId string = routetable.id
