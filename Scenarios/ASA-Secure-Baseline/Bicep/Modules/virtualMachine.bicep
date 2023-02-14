param vmName string
param networkResourceGroupName string
param vnetName string
param subnetName string
param adminUserName string
@secure()
param adminPassword string
@description('Size of the virtual machine.')
param vmSize string
@description('location for all resources')
param location string = resourceGroup().location
@description('Base64 encocded string to be run at VM startup')
param initScriptBase64 string = ''

@allowed([
  'windows10'
  'linux'
])
param os string

var linuxImage = {
  publisher: 'canonical'
  offer: '0001-com-ubuntu-server-focal'
  sku: '20_04-lts-gen2'
  version: 'latest'
}

var windows10Image = {
  publisher: 'MicrosoftWindowsDesktop'
  offer: 'Windows-10'
  sku: '20h2-pro'
  version: 'latest'
}

var linuxConfiguration = {
  disablePasswordAuthentication: false
}

var subscriptionId = subscription().subscriptionId
var nicName = '${vmName}-nic'

resource nic 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId(subscriptionId, networkResourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUserName
      adminPassword: adminPassword
      linuxConfiguration: (os =~ 'linux') ? linuxConfiguration : null
      customData: ( !empty(initScriptBase64) ? initScriptBase64 : null )
    }
    storageProfile: {
      imageReference: (os =~ 'linux') ? linuxImage : windows10Image
      osDisk: {
        name: '${vmName}-os'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
      dataDisks: [
        {
          name: '${vmName}-dataDisk'
          diskSizeGB: 1023
          lun: 0
          createOption: 'Empty'
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
  }
}

output id string = vm.id
output privateIPAddress string = nic.properties.ipConfigurations[0].properties.privateIPAddress
