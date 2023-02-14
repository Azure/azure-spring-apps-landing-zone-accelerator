targetScope = 'subscription'


/******************************/
/*         PARAMETERS         */
/******************************/
@description('Azure Bastion Subnet Address Space')
param azureBastionSubnetSpace string

@description('Hub VNET Prefix')
param hubVnetAddressPrefixes string

@description('Name of the hub VNET. Leave blank if you need one created')
param hubVnetName string = 'vnet-${namePrefix}-${location}-HUB'

@description('Name of the RG that has the hub VNET. Leave blank if you need one created')
param hubVnetResourceGroupName string = 'rg-${namePrefix}-HUB'

@description('The Azure Region in which to deploy the Spring Apps Landing Zone Accelerator')
param location string

@description('The common prefix used when naming resources')
param namePrefix string

@description('Azure Resource Tags')
param tags object = {}

@description('Timestamp value used to group and uniquely identify a given deployment')
param timeStamp string = utcNow('yyyyMMddHHmm')


/******************************/
/*     RESOURCES & MODULES    */
/******************************/
resource hubVnetRg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: hubVnetResourceGroupName
  location: location
  tags: tags
}

module hubVnet '../Modules/vnet.bicep' = {
  name: '${timeStamp}-${hubVnetName}'
  scope: resourceGroup(hubVnetRg.name)
  params: {
    name: hubVnetName
    location: location
    addressPrefixes: [
      hubVnetAddressPrefixes
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
    ]
    tags: tags
  }
}

// NSG for Azure Bastion subnet
module azureBastionNsg '../Modules/nsg.bicep' = {
  name: '${timeStamp}-${namePrefix}-nsg-bastion'
  scope: resourceGroup(hubVnetRg.name)
  params: {
    name: 'bastion-nsg'
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
  name: '${timeStamp}-bastion-${namePrefix}'
  scope: resourceGroup(hubVnetRg.name)
  params: {
    name: 'bastion-${namePrefix}-${substring(uniqueString(timeStamp), 0, 4)}'
    location: location
    subnetId: '${hubVnet.outputs.id}/subnets/AzureBastionSubnet'
    tags: tags
  }
}
