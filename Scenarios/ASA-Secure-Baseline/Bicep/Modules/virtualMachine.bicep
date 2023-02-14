@secure()
param adminPassword string
param adminUserName string
@description('Base64 encocded string to be run at VM startup')
param initScriptBase64 string = ''
@description('location for all resources')
param location string = resourceGroup().location
param networkResourceGroupName string
param subnetName string
param tags object
param vmName string
@description('Size of the virtual machine.')
param vmSize string
param vnetName string

var windowsImageDetails = {
  publisher: 'MicrosoftWindowsServer'
  offer: 'WindowsServer'
  sku: '2022-Datacenter'
  version: 'latest'
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
  tags: tags
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
      customData: (!empty(initScriptBase64) ? initScriptBase64 : null)
    }
    storageProfile: {
      imageReference: windowsImageDetails
      osDisk: {
        name: '${vmName}-os-disk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
      dataDisks: [ ]
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
  tags: tags
}

output id string = vm.id
output privateIPAddress string = nic.properties.ipConfigurations[0].properties.privateIPAddress
