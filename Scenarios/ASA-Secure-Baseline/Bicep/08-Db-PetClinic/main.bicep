@description('The MySql Administrator Login Name')
param admninistratorLogin string

@description('The name of the database to be used for the Pet Clinic app')
param databaseName string

@description('The Azure Region in which to deploy the Spring Apps Landing Zone Accelerator')
param location string

@description('IP CIDR Block for the MySql Subnet')
param mysqlSubnetAddressPrefix string

@description('The common prefix used when naming resources')
param namePrefix string

param privateZonesRgName string = 'rg-${namePrefix}-PRIVATEZONES'

@description('Name of the RG that has the spoke VNET')
param spokeVnetName string = 'vnet-${namePrefix}-${location}-SPOKE'

@description('Azure Resource Tags')
param tags object = {}

@description('Timestamp value used to group and uniquely identify a given deployment')
param timeStamp string = utcNow('yyyyMMddHHmm')

var randomSufix = substring(uniqueString(timeStamp), 0, 4)

resource vnet 'Microsoft.Network/virtualNetworks@2022-09-01' existing = {
  name: spokeVnetName
}

resource snet 'Microsoft.Network/virtualNetworks/subnets@2022-09-01' = {
  parent: vnet
  name: 'snet-mysql'
  properties: {
    addressPrefix: mysqlSubnetAddressPrefix
    delegations: [
      {
        name: 'mysql'
        properties: {
          serviceName: 'Microsoft.DBforMySQL/flexibleServers'
        }
      }
    ]
    serviceEndpoints: [
      {
        service: 'Microsoft.Storage'
      }
    ]
  }
}

resource spokeVnet 'Microsoft.Network/virtualNetworks@2022-09-01' existing = {
  name: spokeVnetName
}

// Private DNS zone for MySql
module privateZoneMySql '../Modules/privateDnsZone.bicep' = {
  name: '${timeStamp}-private-dns-mysql'
  scope: resourceGroup(privateZonesRgName)
  params: {
    tags: tags
    zoneName: 'private.mysql.database.azure.com'
  }
}

module spokeVnetSpringAppsZoneLink '../Modules/virtualNetworkLink.bicep' = {
  name: '${timeStamp}-private-dns-spoke-link-mysql'
  scope: resourceGroup(privateZonesRgName)
  dependsOn: [
    privateZoneMySql
  ]
  params: {
    vnetName: spokeVnetName
    vnetId: spokeVnet.id
    zoneName: 'private.mysql.database.azure.com'
    autoRegistration: false
  }
}

module mySql '../Modules/mySql.bicep' = {
  name: '${timeStamp}-mysql'
  scope: resourceGroup(privateZonesRgName)
  dependsOn: [
    privateZoneMySql
    spokeVnetSpringAppsZoneLink
  ]
  params: {
    admninistratorLogin: admninistratorLogin
    location: location
    databaseName: databaseName
    name: '${namePrefix}-mysql-${randomSufix}'
    privateDnsZoneResourceId: privateZoneMySql.outputs.id
    subnetId: snet.id
    tags: tags
  }
}
