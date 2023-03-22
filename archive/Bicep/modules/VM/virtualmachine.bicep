param subnetId string
param location string
param tags object
param virtualMachineSize string
param vmName string
param adminUserName string
@secure()
param adminPassword string
param workspaceId string
param workspaceKey string

resource vmNic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: 'vmNic'
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}

resource jumpbox 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: 'jumpbox'
  location: resourceGroup().location
  properties: {
    osProfile: {
      computerName: vmName
      adminUsername: adminUserName
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
      }
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmNic.id
        }
      ]
    }
  }
}

resource vmOMSExt 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = {
  name: '${jumpbox.name}/OMSExtension'
  location: location
  properties: {
    publisher: 'Microsoft.EnterpriseCloud.Monitoring'
    type: 'MicrosoftMonitoringAgent'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    settings: {
      workspaceId: workspaceId
    }
    protectedSettings: {
      workspaceKey: workspaceKey
    }
  }
}

resource vmCustomScriptExt 'Microsoft.Compute/virtualMachines/extensions@2019-07-01' = {
  name: '${jumpbox.name}/Microsoft.Azure.customScriptVmExt'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.9'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
           'https://raw.githubusercontent.com/Azure/azure-spring-apps-landing-zone-accelerator/main/archive/terraform/greenfield-deployment/scripts/DeployDeveloperConfig.ps1',
           'https://raw.githubusercontent.com/Azure/azure-spring-apps-landing-zone-accelerator/main/archive/petclinic/deployPetClinicApp.ps1',
           'https://raw.githubusercontent.com/Azure/azure-spring-apps-landing-zone-accelerator/main/archive/petclinic/deployPetClinicApp.sh'

      ]
    }
    protectedSettings: {
      commandToExecute: 'powershell.exe -Command \'./DeployDeveloperConfig.ps1; exit 0;\''
    }
  }
}

resource vmNetworExt 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = {
  name: '${jumpbox.name}/Microsoft.Azure.NetworkWatcher'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.NetworkWatcher'
    type: 'NetworkWatcherAgentWindows'
    typeHandlerVersion: '1.4'
    autoUpgradeMinorVersion: true
  }
}

output vmPrivateIpAddress string = vmNic.properties.ipConfigurations[0].properties.privateIPAddress
