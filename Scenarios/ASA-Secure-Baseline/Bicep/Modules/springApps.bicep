
param appSubnetId string
param appNetworkResourceGroup string
param location string
param name string
param serviceCidr string
param serviceRuntimeNetworkResourceGroup string
param serviceRuntimeSubnetId string
param tags object

resource springApps 'Microsoft.AppPlatform/Spring@2022-12-01' = {
  name: name
  location: location
  properties: {
    networkProfile: {
      appNetworkResourceGroup: appNetworkResourceGroup
      appSubnetId: appSubnetId
      serviceRuntimeNetworkResourceGroup: serviceRuntimeNetworkResourceGroup
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
