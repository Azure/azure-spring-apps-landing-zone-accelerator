
param appSubnetId string
param location string
param name string
param serviceCidr string
param serviceRuntimeSubnetId string
param tags object

resource springApps 'Microsoft.AppPlatform/Spring@2022-12-01' = {
  name: name
  location: location
  properties: {
    networkProfile: {
      appNetworkResourceGroup: '${name}-apps-rg'
      appSubnetId: appSubnetId
      serviceRuntimeNetworkResourceGroup: '${name}-runtime-rg'
      serviceRuntimeSubnetId: serviceRuntimeSubnetId
      serviceCidr: serviceCidr
    }
  }
  sku: {
    name: 'S0'
    tier: 'Standard'
  }
  tags: tags
}
