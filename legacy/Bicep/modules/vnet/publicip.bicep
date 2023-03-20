param publicipName string
param publicipsku object
param publicipproperties object
param location string = resourceGroup().location
param tags object

resource publicip 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: publicipName
  tags: tags
  location: location
  sku: publicipsku
  properties: publicipproperties
}
output publicipId string = publicip.id
