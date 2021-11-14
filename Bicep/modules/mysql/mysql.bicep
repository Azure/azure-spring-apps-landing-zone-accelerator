param name string
param location string
param tags object
param adminUser string
@secure()
param adminPwd string

resource mysql 'Microsoft.DBForMySQL/servers@2017-12-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    createMode: 'Default'
    version: '5.7'
    administratorLogin: adminUser
    administratorLoginPassword: adminPwd
    sslEnforcement: 'Disabled'
    storageProfile: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
      storageMB: 51200
    }
  }
  sku: {
    capacity: 2
    family: 'Gen5'
    name: 'GP_Gen5_2'
    size: '51200'
    tier: 'GeneralPurpose'
  }
}

output mysqlId string = mysql.id
