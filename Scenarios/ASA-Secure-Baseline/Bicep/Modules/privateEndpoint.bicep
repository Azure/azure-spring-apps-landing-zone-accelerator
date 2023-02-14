param dnsResourceGroupName string
param dnsZoneName string
param groupId string
param location string
param networkResourceGroupName string
param privateEndpointName string
param subnetName string
param serviceResourceId string
param tags object
param vnetName string

var subscriptionId = subscription().subscriptionId
var subnetId = resourceId(subscriptionId, networkResourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
var dnsZoneId = resourceId(subscriptionId, dnsResourceGroupName, 'Microsoft.Network/privateDnsZones', dnsZoneName )

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-07-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: serviceResourceId
          groupIds: [
            groupId
          ]
        }
      }
    ]
  }
  tags: tags
}

resource privateDnsZoneConfig 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-07-01' = {
  parent: privateEndpoint
  name: 'dnsgroupname'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: dnsZoneName
        properties: {
          privateDnsZoneId: dnsZoneId
        }
      }
    ]
  }
}

output id string = privateEndpoint.id
