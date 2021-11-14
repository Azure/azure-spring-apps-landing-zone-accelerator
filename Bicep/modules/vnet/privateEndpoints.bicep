param name string
param location string
param subnetId string
param plConnName string
param resourceId string
param groupIds string

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: name
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: plConnName
        properties: {
          privateLinkServiceId: resourceId
          groupIds: [
            groupIds
          ]
        }
      }
    ]
  }
}

output privateEndpointName string = privateEndpoint.name
