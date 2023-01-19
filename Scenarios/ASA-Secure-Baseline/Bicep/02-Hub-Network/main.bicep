targetScope = 'subscription'

@description('Azure Bastion Subnet Address Space')
param azureBastionSubnetSpace string
@description('Hub VNET Prefix')
param hubVnetAddressSpace string
@description('The Azure Region in which to deploy the Spring Apps Landing Zone Accelerator')
param location string
@description('The common prefix used when naming resources')
param namePrefix string
@description('Spring Apps Subnet Address Space')
param springAppsSubnetSpace string
param tags object = {}
@description('Timestamp value used to group and uniquely identify a given deployment')
param timeStamp string = utcNow('yyyyMMddHHmm')

resource networkRg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${namePrefix}-network-hub-rg'
  location: location
  tags: tags
}

module vnet '../Modules/vnet.bicep' = {
  name: '${timeStamp}-${namePrefix}-vnet-hub'
  scope: resourceGroup(networkRg.name)
  params: {
    vnetName: '${namePrefix}-vnet-hub'
    location: location
    addressSpaces: [
      hubVnetAddressSpace
    ]
    subnets: [
      {
        name: 'AzureBastionSubnet' //Note: this name must remain this value and cannot be customized for Azure Bastion to deploy correctly
        properties: {
          addressPrefix: azureBastionSubnetSpace
          networkSecurityGroup: {
            id: azureBastionNsg.outputs.id
          }
        }
      }
      {
        name: 'spring-apps' //Note: this name must remain this value and cannot be customized for Azure Bastion to deploy correctly
        properties: {
          addressPrefix: springAppsSubnetSpace
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
  name: '${timeStamp}-${namePrefix}-nsg-bastion'
  scope: resourceGroup(networkRg.name)
  params: {
    name: '${namePrefix}-nsg-bastion'
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
          destinationPortRange: '*'
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

// NSG for Spring Apps subnet
//TODO: Determine final NSG rules for the Spring Apps subnet
module springAppsNsg '../Modules/nsg.bicep' = {
  name: '${timeStamp}-${namePrefix}-nsg-spring-apps'
  scope: resourceGroup(networkRg.name)
  params: {
    name: '${namePrefix}-nsg-spring-apps'
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
          destinationPortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
        }
      }
    ]
    tags: tags
  }
}
