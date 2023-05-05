targetScope = 'subscription'

/******************************/
/*         PARAMETERS         */
/******************************/
@description('Azure Bastion Subnet Address Space')
param azureBastionSubnetPrefix string

@description('Bastion Name. Specify this value in the parameters.json file to override this default.')
param bastionName string

@description('Network Security Group name for the Bastion subnet. Specify this value in the parameters.json file to override this default.')
param bastionNsgName string

@description('IP CIDR Block for the Hub VNET')
param hubVnetAddressPrefix string

@description('Name of the hub VNET. Specify this value in the parameters.json file to override this default.')
param hubVnetName string

@description('Name of the resource group that contains the hub VNET. Specify this value in the parameters.json file to override this default.')
param hubVnetRgName string

@description('The Azure Region in which to deploy the Spring Apps Landing Zone Accelerator')
param location string

@description('Azure Resource Tags')
param tags object

@description('Timestamp value used to group and uniquely identify a given deployment')
param timeStamp string

/******************************/
/*     RESOURCES & MODULES    */
/******************************/
resource hubVnetRg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: hubVnetRgName
  location: location
  tags: tags
}

module hubVnet '../Modules/vnet.bicep' = {
  name: '${timeStamp}-hub-vnet'
  scope: resourceGroup(hubVnetRg.name)
  params: {
    name: hubVnetName
    addressPrefixes: [
      hubVnetAddressPrefix
    ]
    location: location
    subnets: [
      {
        name: 'AzureBastionSubnet' //Note: this name must remain this value and cannot be customized for Azure Bastion to deploy correctly
        properties: {
          addressPrefix: azureBastionSubnetPrefix
          networkSecurityGroup: {
            id: azureBastionNsg.outputs.id
          }
        }
      }
    ]
    tags: tags
  }
}

// NSG for Azure Bastion subnet
module azureBastionNsg '../Modules/nsg.bicep' = {
  name: '${timeStamp}-nsg-bastion'
  scope: resourceGroup(hubVnetRg.name)
  params: {
    name: bastionNsgName
    location: location
    securityRules: [
      {
        name: 'AllowHTTPSInbound'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowGatewayManagerInbound'
        properties: {
          priority: 200
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'GatewayManager'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowAzureLBInbound'
        properties: {
          priority: 300
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowBastionHostCommunication'
        properties: {
          priority: 400
          direction: 'Inbound'
          access: 'Allow'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRanges: [
            '5701'
            '8080'
          ]
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
      {
        name: 'AllowRdpSshOutbound'
        properties: {
          priority: 100
          direction: 'Outbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: [
            '22'
            '3389'
          ]
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
      {
        name: 'AllowBastionHostCommunicationOutbound'
        properties: {
          priority: 110
          direction: 'Outbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: [
            '5701'
            '8080'
          ]
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
      {
        name: 'AllowAzureCloudOutbound'
        properties: {
          priority: 120
          direction: 'Outbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'AzureCloud'
        }
      }
      {
        name: 'AllowGetSessionInformation'
        properties: {
          priority: 130
          direction: 'Outbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Internet'
        }
      }
    ]
    tags: tags
  }
}

module azureBastion '../Modules/bastion.bicep' = {
  name: '${timeStamp}-bastion'
  scope: resourceGroup(hubVnetRg.name)
  params: {
    name: bastionName
    location: location
    subnetId: '${hubVnet.outputs.id}/subnets/AzureBastionSubnet'
    tags: tags
  }
}

output hubVnetId string = hubVnet.outputs.id
