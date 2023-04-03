param azureFirewallSubnetSpace string
param hubVentName string
param name string

resource hubVnet 'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  name: hubVentName
}

resource azfwSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' = {
  name: name
  parent: hubVnet
  properties: {
    addressPrefix: azureFirewallSubnetSpace
  }
}
