param fireWallSubnetName string
param hubVnetName string
param location string
param name string
param networkRules array = []
@description('By default, Azure Firewall will not SNAT RFC 1918 private addresses. Use this field to remove this behavior with a comma-delmimited list of CIDR blocks.')
param privateTrafficPrefixes string = ''
param tags object

resource publicIp 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: 'azure-firewall-ip'
  location: location
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
  }
  tags: tags
}

resource fwl 'Microsoft.Network/azureFirewalls@2020-06-01' = {
  name: name
  location: location
  properties: {
    ipConfigurations: [
      {
        name: '${name}-ipconf'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', hubVnetName, fireWallSubnetName)
          }
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
    networkRuleCollections: ( (!empty(networkRules)) ? networkRules : null )
    additionalProperties: {
      'Network.SNAT.PrivateRanges': ( (!empty(privateTrafficPrefixes)) ? privateTrafficPrefixes : 'IANAPrivateRanges' )
    }
  }
  tags: tags
}

output privateIp string = fwl.properties.ipConfigurations[0].properties.privateIPAddress
