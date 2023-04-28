targetScope = 'subscription'

/******************************/
/*         PARAMETERS         */
/******************************/

@description('The MySql Administrator Login Name')
param admninistratorLogin string

@secure()
@description('The MySql Administrator Password')
param administratorLoginPassword string

@description('Name of the resource group that contains the Spring Apps instance. Specify this value in the parameters.json file to override this default.')
param appResourceGroupName string = 'rg-${namePrefix}-APPS'

@description('The name of the database to be used for the Pet Clinic app')
param databaseName string

@description('The Azure Region in which to deploy the Spring Apps Landing Zone Accelerator')
param location string

@description('The name of the MySql Server. Specify this value in the parameters.json file to override this default.')
param mySqlName string = '${namePrefix}-mysql-${substring(uniqueString(timeStamp), 0, 4)}'

@description('IP CIDR Block for the MySql Subnet')
param mysqlSubnetAddressPrefix string

@description('The common prefix used when naming resources')
param namePrefix string

@description('Name of the resource group that contains the private DNS zones. Specify this value in the parameters.json file to override this default.')
param privateZonesRgName string = 'rg-${namePrefix}-PRIVATEZONES'

@description('Network Security Group name for the MySql subnet. Specify this value in the parameters.json file to override this default.')
param snetMySqlNsg string = 'snet-mysql-nsg'

@description('Name of the resource group that contains the spoke VNET. Specify this value in the parameters.json file to override this default.')
param spokeRgName string = 'rg-${namePrefix}-SPOKE'

@description('Name of the RG that has the spoke VNET')
param spokeVnetName string = 'vnet-${namePrefix}-${location}-SPOKE'

@description('Azure Resource Tags')
param tags object = {}

@description('Timestamp value used to group and uniquely identify a given deployment')
param timeStamp string = utcNow('yyyyMMddHHmm')

resource spokeVnet 'Microsoft.Network/virtualNetworks@2022-09-01' existing = {
  name: spokeVnetName
  scope: resourceGroup(spokeRgName)
}

module mySqlNsg '../Modules/nsg.bicep' = {
  name: '${timeStamp}-nsg-snet-mysql'
  scope: resourceGroup(spokeRgName)
  params: {
    name: snetMySqlNsg
    location: location
    securityRules: [
      {
        name: 'AllowCorpnet'
        properties: {
          priority: 2700
          direction: 'Inbound'
          access: 'Allow'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'CorpNetPublic'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowSAW'
        properties: {
          priority: 2701
          direction: 'Inbound'
          access: 'Allow'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'CorpNetSaw'
          destinationAddressPrefix: '*'
        }
      }
    ]
    tags: tags
  }
}

module subnet '../Modules/subnet.bicep' = {
  name: '${timeStamp}-snet-mysql'
  scope: resourceGroup(spokeRgName)
  params: {
    addressPrefix: mysqlSubnetAddressPrefix
    name: 'snet-mysql'
    vnetName: spokeVnetName
    networkSecurityGroup: {
      id: mySqlNsg.outputs.id
    }
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
  scope: resourceGroup(appResourceGroupName)
  dependsOn: [
    privateZoneMySql
    spokeVnetSpringAppsZoneLink
  ]
  params: {
    admninistratorLogin: admninistratorLogin
    administratorLoginPassword: administratorLoginPassword
    location: location
    databaseName: databaseName
    name: mySqlName
    privateDnsZoneResourceId: privateZoneMySql.outputs.id
    subnetId: subnet.outputs.id
    tags: tags
  }
}

//TODO - MySql Service Connections 

//TODO - ASA App Instance Creation
