@description('Your tenant ID')
param tenantId string

@description('The object ID of the Azure Spring Cloud Resource Provider service principal')
param springCloudPrincipalObjectId string

@description('The object ID of the security principal that will have permissions over the Key Vault instance')
param keyVaultAdminObjectId string

@description('Administrator name for VMs that are created')
param vmAdminUsername string

@description('Password for the VMs that are created')
@secure()
param vmAdminPassword string

@description('The tags that will be associated to the VM')
param tags object = {
  environment: 'lab'
}

@description('A new GUID used to identify the role assignment for the virtual network')
param roleGuidVnetName string = newGuid()

@description('A new GUID used to identify the role assignment for the route table')
param roleGuidRuntimeRouteTableName string = newGuid()

@description('A new GUID used to identify the role assignment for the route table')
param roleGuidAppRouteTableName string = newGuid()

// Variables
var springCloudSkuName = 'S0'
var springCloudSkuTier = 'Standard'
var vmSku = 'Standard_DS2_v2'
var keyVaultSku = 'Standard'
var ddosStandardProtection = false
var logAnalyticsRetention = 30
var keyVaultPermissions = {
  keys: keyPermissions
  secrets: secretsPermissions
  certificates: certPermissions
}
var keyPermissions = [
  'list'
  'encrypt'
  'decrypt'
  'wrapKey'
  'unwrapKey'
  'sign'
  'verify'
  'get'
  'create'
  'update'
  'import'
  'backup'
  'restore'
  'recover'
]
var secretsPermissions = [
  'list'
  'get'
  'set'
  'backup'
  'restore'
  'recover'
]
var certPermissions = [
  'backup'
  'create'
  'get'
  'getissuers'
  'import'
  'list'
  'listissuers'
  'managecontacts'
  'manageissuers'
  'recover'
  'restore'
  'setissuers'
  'update'
]
var location = resourceGroup().location
var hubVnetName = 'vnet-hub'
var spokeVnetName = 'vnet-spoke'
var hubCidr = '10.0.0.0/16'
var spokeCidr = '10.1.0.0/16'
var GatewaySubnet = {
    name: 'GatewaySubnet'
    properties: {
        addressPrefix: '10.0.0.0/24'
    }
}
var AzureFirewallSubnet = {
    name: 'AzureFirewallSubnet'
    properties: {
        addressPrefix: '10.0.1.0/24'
    }
}
var AzureBastionSubnet = {
    name: 'AzureBastionSubnet'
    properties: {
        addressPrefix: '10.0.2.0/24'
    }
}
var appGatewaySubnetName = {
    name: 'snet-agw'
    properties: {
        addressPrefix: '10.0.3.0/24'
    }
}
var hubSharedServicesCidr = '10.0.4.0/24'
var supportSubnet = {
  name: supportSubnetName
  properties: {
      addressPrefix: '10.1.2.0/24'
      privateEndpointNetworkPolicies: 'Disabled'
  }
}
var dataSubnet = {
  name: dataSubnetName
  properties: {
      addressPrefix: '10.1.3.0/24'
      privateEndpointNetworkPolicies: 'Disabled'
  }
}
var spokeRuntimeSubnetCidr = '10.1.0.0/24'
var spokeAppSubnetCidr = '10.1.1.0/24'
var springCloudServiceCidrs = '10.3.0.0/16,10.4.0.0/16,10.5.0.1/16'
var sharedServicesSubnetName = 'snet-shared'
var supportSubnetName = 'snet-support'
var runtimeSubnetName = 'snet-runtime'
var appSubnetName = 'snet-app'
var dataSubnetName = 'snet-data'
var bastionPublicIpName = 'pip-bastion'
var azFirewallPublicIpName = 'pip-azfw'
var bastionName = 'bstss'
var azureFirewallName = 'fwhub'
var hubRouteTable = 'rt-hub'
var hubVmName = 'vm01'
var hubToSpokePeeringName = 'peerhubtospoke'
var spokeRuntimeRouteTable = 'rt-spokeruntime'
var spokeAppRouteTable = 'rt-spokeapp'
var spokeToHubPeeringName = 'peerspoketohub'
var laWorkspaceName = 'la-${uniqueString(subscription().id, resourceGroup().id)}'
var keyVaultName = 'kv-${uniqueString(subscription().id, resourceGroup().id)}'
var mysqlServerName = 'mysql-${uniqueString(resourceGroup().id)}'
var nsgHubShared = 'nsg-hubshared'
var nsgSpokeRuntime = 'nsg-spokeruntime'
var nsgSpokeApp = 'nsg-spokeapp'
var appInsightsName = 'appi-${uniqueString(subscription().id, resourceGroup().id)}'
var springCloudInstanceName = 'spring-${uniqueString(subscription().id, resourceGroup().id)}'
var ownerDefinitionId = '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
var appPrivateDnsZone = 'private.azuremicroservices.io'
var keyVaultPrivateDnsZone = 'privatelink.vaultcore.azure.net'
var msSqlPrivateDnsZone = 'privatelink.mysql.database.azure.com'
var uniqueKvPrivateEndpointName = substring('pl-${keyVaultName}${uniqueString(subscription().id, resourceGroup().id)}', 10)
var uniqueKvPlConnName = substring('plconn${keyVaultName}${uniqueString(subscription().id, resourceGroup().id)}', 10)
var uniqueSqlPrivateEndpointName = substring('pl-${mysqlServerName}${uniqueString(subscription().id, resourceGroup().id)}', 10)
var uniqueSqlPlConnName = substring('plconn${mysqlServerName}${uniqueString(subscription().id, resourceGroup().id)}', 10)
var appPrivateZoneLinkName = '${appPrivateDnsZone}-link'
var keyVaultPrivateZoneLinkName = '${keyVaultPrivateDnsZone}-link'
var msSqlPrivateZoneLinkName = '${msSqlPrivateDnsZone}-link'

module nsgHS 'modules/vnet/nsg.bicep' = {
  name: nsgHubShared
  params: {
    nsgLocation: location
    nsgName: nsgHubShared
    nsgTags: tags
  }
}

module nsgSA 'modules/vnet/nsg.bicep' = {
  name: nsgSpokeApp
  params: {
    nsgLocation: location
    nsgName: nsgSpokeApp
    nsgTags: tags
  }
}

module nsgSR 'modules/vnet/nsg.bicep' = {
  name: nsgSpokeRuntime
  params: {
    nsgLocation: location
    nsgName: nsgSpokeRuntime
    nsgTags: tags
  }
}

module vnetHub 'modules/vnet/vnet.bicep' = {
  name: hubVnetName
  params: {
    cidr: hubCidr
    ddosProtection: ddosStandardProtection
    location: location
    subnets: [
      {
        name: sharedServicesSubnetName
        properties: {
            addressPrefix: hubSharedServicesCidr
            networkSecurityGroup: {
                id: nsgHS.outputs.nsgId
            }
        }
      }
      GatewaySubnet
      AzureFirewallSubnet
      AzureBastionSubnet
      appGatewaySubnetName
    ]
    tags: tags
    vnetName: hubVnetName
  }
}

module vnetHubUpdate 'modules/vnet/vnet.bicep' = {
  name: 'hubVnetNameUpdate'
  params: {
    cidr: hubCidr
    ddosProtection: ddosStandardProtection
    location: location
    subnets: [
      {
        name: sharedServicesSubnetName
        properties: {
            addressPrefix: hubSharedServicesCidr
            networkSecurityGroup: {
                id: nsgHS.outputs.nsgId
            }
            routeTable: {
              id: hubrtTable.outputs.routeTableId
            }
        }
      }
      GatewaySubnet
      AzureFirewallSubnet
      AzureBastionSubnet
      appGatewaySubnetName
    ]
    tags: tags
    vnetName: hubVnetName
  }
}

module vnetSpoke 'modules/vnet/vnet.bicep' = {
  name: spokeVnetName
  params: {
    cidr: spokeCidr
    ddosProtection: ddosStandardProtection
    location: location
    subnets: [
      {
        name: runtimeSubnetName
        properties: {
            addressPrefix: spokeRuntimeSubnetCidr
            networkSecurityGroup: {
                id: nsgSR.outputs.nsgId
            }
        }
      }
      {
        name: appSubnetName
        properties: {
            addressPrefix: spokeAppSubnetCidr
            networkSecurityGroup: {
                id: nsgSA.outputs.nsgId
            }
        }
      }
      supportSubnet
      dataSubnet
    ]
    tags: tags
    vnetName: spokeVnetName
  }
}

module vnetSpokeUpdate 'modules/vnet/vnet.bicep' = {
  name: 'vnetSpokeUpdate'
  params: {
    cidr: spokeCidr
    ddosProtection: ddosStandardProtection
    location: location
    subnets: [
      {
        name: runtimeSubnetName
        properties: {
            addressPrefix: spokeRuntimeSubnetCidr
            networkSecurityGroup: {
                id: nsgSR.outputs.nsgId
            }
            routeTable: {
              id: spokeRuntimeRtTable.outputs.routeTableId
            }
        }
      }
      {
        name: appSubnetName
        properties: {
            addressPrefix: spokeAppSubnetCidr
            networkSecurityGroup: {
                id: nsgSA.outputs.nsgId
            }
            routeTable: {
              id: spokeAppRtTable.outputs.routeTableId
            }
        }
      }
      supportSubnet
      dataSubnet
    ]
    tags: tags
    vnetName: spokeVnetName
  }
}

module role 'modules/Identity/role.bicep' = {
  name: roleGuidVnetName
  params: {
    principalId: springCloudPrincipalObjectId
    roleGuid: ownerDefinitionId
    resourceName: vnetSpoke.outputs.vnetName
    resourceType: 'vnet'
  }
}

module vnetpeeringhub 'modules/vnet/vnetpeering.bicep' = {
  name: hubToSpokePeeringName
  params: {
    peeringName: hubToSpokePeeringName
    vnetName: vnetHub.outputs.vnetName
    properties: {
      allowVirtualNetworkAccess: true
      allowForwardedTraffic: true
      allowGatewayTransit: false
      remoteVirtualNetwork: {
        id: vnetSpoke.outputs.vnetId
      }
    }    
  }
}

module vnetpeeringspoke 'modules/vnet/vnetpeering.bicep' = {
  name: spokeToHubPeeringName
  params: {
    peeringName: spokeToHubPeeringName
    vnetName: vnetSpoke.outputs.vnetName
    properties: {
      allowVirtualNetworkAccess: true
      allowForwardedTraffic: true
      allowGatewayTransit: false
      remoteVirtualNetwork: {
        id: vnetHub.outputs.vnetId
      }
    }    
  }
}

module laworkspace 'modules/laworkspace/laworkspace.bicep' = {
  name: laWorkspaceName
  params: {
    laretentionDays: logAnalyticsRetention
    location: location
    name: laWorkspaceName
    tags: tags
  }
}

module appInsights 'modules/laworkspace/appinsights.bicep' = {
  name: appInsightsName
  params: {
    kind: 'web'
    location: location
    name: appInsightsName
    tags: tags
  }
}

module keyVault 'modules/keyvault/keyvault.bicep' = {
  name: keyVaultName
  params: {
    keyVaultObjectId: keyVaultAdminObjectId
    keyVaultsku: keyVaultSku
    location: location
    name: keyVaultName
    permissions: keyVaultPermissions
    tags: tags
    tenantId: tenantId
  }
}

module mySqlServer 'modules/mysql/mysql.bicep' = {
  name: mysqlServerName
  params: {
    adminPwd: vmAdminPassword
    adminUser: vmAdminUsername
    location: location
    name: mysqlServerName
    tags: tags
  }
}

module keyvaultDnsZone 'modules/vnet/privateDnsZones.bicep' = {
  name: keyVaultPrivateDnsZone
  params: {
    name: keyVaultPrivateDnsZone
  }
}

module mySqlDnsZone 'modules/vnet/privateDnsZones.bicep' = {
  name: msSqlPrivateDnsZone
  params: {
    name: msSqlPrivateDnsZone
  }
}

module appDnsZone 'modules/vnet/privateDnsZones.bicep' = {
  name: appPrivateDnsZone
  params: {
    name: appPrivateDnsZone
  }
}

resource supportSbnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: '${vnetSpoke.name}/${supportSubnetName}'
}

module kvPrivateEndpoint 'modules/vnet/privateEndpoints.bicep' = {
  name: uniqueKvPrivateEndpointName
  params: {
    groupIds: 'Vault'
    location: location
    name: uniqueKvPrivateEndpointName
    plConnName: uniqueKvPlConnName
    resourceId: keyVault.outputs.keyvaultId
    subnetId: supportSbnet.id
  }
}

module kvZoneGroup 'modules/vnet/zonegroup.bicep' = {
  name: 'kvZoneGroup'
  params: {
    privateDNSZoneId: keyvaultDnsZone.outputs.privateDNSZoneId
    privateEndpointName: kvPrivateEndpoint.outputs.privateEndpointName
  }
}

module kvPrivateZone 'modules/vnet/vnetlink.bicep' = {
  name: keyVaultPrivateZoneLinkName
  params: {
    privateDNSZoneName: keyvaultDnsZone.outputs.privateDNSZoneName
    privateZoneLinkName: keyVaultPrivateZoneLinkName
    virtualNetworkid: vnetHub.outputs.vnetId
  }
}

resource dtSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: '${vnetSpoke.name}/${dataSubnetName}'
}

module sqlPrivateEndpoint 'modules/vnet/privateEndpoints.bicep' = {
  name: uniqueSqlPrivateEndpointName
  params: {
    groupIds: 'mysqlServer'
    location: location
    name: uniqueSqlPrivateEndpointName
    plConnName: uniqueSqlPlConnName
    resourceId: mySqlServer.outputs.mysqlId
    subnetId: dtSubnet.id
  }
}

module sqlZoneGroup 'modules/vnet/zonegroup.bicep' = {
  name: 'sqlZoneGroup'
  params: {
    privateDNSZoneId: mySqlDnsZone.outputs.privateDNSZoneId
    privateEndpointName: sqlPrivateEndpoint.outputs.privateEndpointName
  }
}

module sqlPrivateZone 'modules/vnet/vnetlink.bicep' = {
  name: msSqlPrivateZoneLinkName
  params: {
    privateDNSZoneName: mySqlDnsZone.outputs.privateDNSZoneName
    privateZoneLinkName: msSqlPrivateZoneLinkName
    virtualNetworkid: vnetHub.outputs.vnetId
  }
}

module appPrivateZone 'modules/vnet/vnetlink.bicep' = {
  name: appPrivateZoneLinkName
  params: {
    privateDNSZoneName: appDnsZone.outputs.privateDNSZoneName
    privateZoneLinkName: appPrivateZoneLinkName
    virtualNetworkid: vnetHub.outputs.vnetId
  }
}

module bastionPip 'modules/vnet/publicip.bicep' = {
  name: bastionPublicIpName
  params: {
    publicipName: bastionPublicIpName
    publicipproperties: {
      publicIpAllocationMethod: 'Static'
    }
    publicipsku: {
      name: 'Standard'
    }
    tags: tags
  }
}

module firewallPip 'modules/vnet/publicip.bicep' = {
  name: azFirewallPublicIpName
  params: {
    publicipName: azFirewallPublicIpName
    publicipproperties: {
      publicIpAllocationMethod: 'Static'
    }
    publicipsku: {
      name: 'Standard'
    }
    tags: tags
  }
}

resource azfwsubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: '${vnetHub.name}/AzureFirewallSubnet'
}

module azfirewall 'modules/vnet/firewall.bicep' = {
  name: azureFirewallName
  params: {
    azfwPipId: firewallPip.outputs.publicipId
    azfwSubnetId: azfwsubnet.id
    fwname: azureFirewallName
    hubSharedServicesCidr: hubSharedServicesCidr
    location: location
    spokeAppSubnetCidr: spokeAppSubnetCidr
    spokeRuntimeSubnetCidr: spokeRuntimeSubnetCidr
    tags: tags
    diagnosticname: 'azfwDiagnostics'
    laworkspaceId: laworkspace.outputs.laworkspaceId
  }
}

module spokeRuntimeRtTable 'modules/vnet/routetables.bicep' = {
  name: spokeRuntimeRouteTable
  params: {
    location: location
    name: spokeRuntimeRouteTable
    tags: tags
    azfirewallPvtIpAddr: azfirewall.outputs.fwPrivateIP
  }
}

module spokeAppRtTable 'modules/vnet/routetables.bicep' = {
  name: spokeAppRouteTable
  params: {
    location: location
    name: spokeAppRouteTable
    tags: tags
    azfirewallPvtIpAddr: azfirewall.outputs.fwPrivateIP
  }
}

module roleAssignmentAppRt 'modules/Identity/role.bicep' = {
  name: roleGuidAppRouteTableName
  params: {
    principalId: springCloudPrincipalObjectId
    roleGuid: ownerDefinitionId
    resourceName: spokeAppRtTable.outputs.routeTableName
    resourceType: 'route'
  }
}

module roleAssignmentRuntimeRt 'modules/Identity/role.bicep' = {
  name: roleGuidRuntimeRouteTableName
  params: {
    principalId: springCloudPrincipalObjectId
    roleGuid: ownerDefinitionId
    resourceName: spokeRuntimeRtTable.outputs.routeTableName
    resourceType: 'route'
  }
}

resource appSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: '${vnetSpoke.name}/${appSubnetName}'
}

resource rtSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: '${vnetSpoke.name}/${runtimeSubnetName}'
}

module springCloud 'modules/springCloud/springcloud.bicep' = {
  name: springCloudInstanceName
  params: {
    appsubnetId: appSubnet.id
    location: location
    name: springCloudInstanceName
    rtsubnetId: rtSubnet.id
    skuName: springCloudSkuName
    skuTier: springCloudSkuTier
    springCloudServiceCidrs: springCloudServiceCidrs
    tags: tags
    workspaceId: laworkspace.outputs.laworkspaceId
    appInsightsInstrumentationKey: appInsights.outputs.appInsightsInstrumentationKey
  }
  dependsOn: [
    vnetHubUpdate
    vnetSpokeUpdate
  ]
}

module hubrtTable 'modules/vnet/routetables.bicep' = {
  name: hubRouteTable
  params: {
    location: location
    name: hubRouteTable
    tags: tags
    azfirewallPvtIpAddr: azfirewall.outputs.fwPrivateIP
  }
}

resource ssSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: '${vnetHub.name}/${sharedServicesSubnetName}'
}

module hubVM 'modules/VM/virtualmachine.bicep' = {
  name: hubVmName
  params: {
    adminPassword: vmAdminPassword
    adminUserName: vmAdminUsername
    location: location
    subnetId: ssSubnet.id
    tags: tags
    virtualMachineSize: vmSku
    vmName: hubVmName
    workspaceId: laworkspace.outputs.laworkspaceCId
    workspaceKey: laworkspace.outputs.laworkspaceKey
  }
}

resource bastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: '${vnetHub.name}/AzureBastionSubnet'
}

module bastion 'modules/VM/bastion.bicep' = {
  name: bastionName
  params: {
    bastionpipId: bastionPip.outputs.publicipId
    subnetId: bastionSubnet.id
  }
}

module arecord 'modules/vnet/arecord.bicep' = {
  name: 'arecord'
  params: {
    name: '${appPrivateDnsZone}/*'
    networkrg: springCloud.outputs.springCloudNetworkRG
  }
}
