param admninistratorLogin string
param databaseName string
param location string
param name string
param privateDnsZoneResourceId string
param subnetId string
param tags object

resource mySql 'Microsoft.DBforMySQL/flexibleServers@2021-05-01' = {
  name: name
  location: location
  properties: {
    administratorLogin: admninistratorLogin
    storage: {
      storageSizeGB: 20
      iops: 360
      autoGrow: 'Enabled'
    }
    network: {
      delegatedSubnetResourceId: subnetId
      privateDnsZoneResourceId: privateDnsZoneResourceId
    }
    version: '5.7'
  }
  sku: {
    name: 'Standard_D2ds_v4'
    tier: 'GeneralPurpose'
  }
  tags: tags
}

resource petClinicDb 'Microsoft.DBforMySQL/flexibleServers/databases@2021-05-01' = {
  parent: mySql
  name: databaseName
  properties: {
    charset: 'utf8'
    collation: 'utf8_general_ci'
  }
}

resource mySqlFirewallRule 'Microsoft.DBforMySQL/flexibleServers/firewallRules@2021-05-01' = {
  parent: mySql
  name: 'AllowAllIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}
