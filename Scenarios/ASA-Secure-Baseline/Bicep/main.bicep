targetScope = 'subscription'

/******************************/
/*         PARAMETERS         */
/******************************/

//Resource Names - Override these in the parameters.json file to match your organization's naming conventions
@description('Name of the Azure Firewall. Specify this value in the parameters.json file to override this default.')
param azureFirewallName string = 'fw-${namePrefix}'

@description('Bastion Name. Specify this value in the parameters.json file to override this default.')
param bastionName string = 'bastion-${namePrefix}-${substring(uniqueString(namePrefix), 0, 4)}'

@description('Name of the jump box. Specify this value in the parameters.json file to override this default.')
param vmName string = length('vm${namePrefix}${environment}') > 14 ? substring('vm${namePrefix}${environment}', 0, 14) : 'vm${namePrefix}${environment}'

@description('Name of the key vault. Specify this value in the parameters.json file to override this default.')
param keyVaultName string = length(namePrefix) > 16 ? 'kv-${substring(namePrefix, 0, 16)}-${substring(uniqueString(namePrefix), 0, 4)}' : 'kv-${namePrefix}-${substring(uniqueString(namePrefix), 0, 4)}'

@description('Name of the application insights instance. Specify this value in the parameters.json file to override this default.')
param appInsightsName string = '${namePrefix}-ai'

@description('Name of the log analytics workspace instance. Specify this value in the parameters.json file to override this default.')
param logAnalyticsWorkspaceName string = 'law-${namePrefix}-${substring(uniqueString(namePrefix), 0, 4)}'

@description('Name of the spring apps instance. Specify this value in the parameters.json file to override this default.')
param springAppsName string = length('${namePrefix}-${environment}') > 20 ? 'spring-${toLower(substring('${namePrefix}-${environment}', 0, 20))}-${substring(uniqueString(namePrefix), 0, 4)}' : 'spring-${toLower('${namePrefix}-${environment}')}-${substring(uniqueString(namePrefix), 0, 4)}'

//VNET Names - Override these in the parameters.json file to match your organization's naming conventions
@description('Name of the hub VNET. Specify this value in the parameters.json file to override this default.')
param hubVnetName string = 'vnet-${namePrefix}-${location}-HUB'

@description('Name of the RG that has the spoke VNET. Specify this value in the parameters.json file to override this default.')
param spokeVnetName string = 'vnet-${namePrefix}-${location}-SPOKE'

//Subnet Names - These subnets are all created in the SPOKE VNET.  Override these in the parameters.json file to match your organization's naming conventions
@description('Name of the subnet that has the jump host. Specify this value in the parameters.json file to override this default.')
param snetSharedName string = 'snet-shared'

@description('Name of the support subnet. Specify this value in the parameters.json file to override this default.')
param snetSupportName string = 'snet-support'

@description('Name of the Spring Apps Runtime subnet. Specify this value in the parameters.json file to override this default.')
param snetRuntimeName string = 'snet-runtime'

@description('Name of the Spring Apps subnet. Specify this value in the parameters.json file to override this default.')
param snetAppName string = 'snet-app'

@description('Name of the App Gateway subnet. Specify this value in the parameters.json file to override this default.')
param snetAppGwName string = 'snet-appgw'

//Resource Group Names - Override these in the parameters.json file to match your organization's naming conventions
@description('Name of the resource group that contains the spoke VNET. Specify this value in the parameters.json file to override this default.')
param spokeRgName string = 'rg-${namePrefix}-SPOKE'

@description('Name of the resource group that contains the private DNS zones. Specify this value in the parameters.json file to override this default.')
param privateZonesRgName string = 'rg-${namePrefix}-PRIVATEZONES'

@description('Name of the resource group that has the hub VNET. Specify this value in the parameters.json file to override this default.')
param hubVnetRgName string = 'rg-${namePrefix}-HUB'

@description('Name of the resource group that contains shared resources. Specify this value in the parameters.json file to override this default.')
param sharedRgName string = 'rg-${namePrefix}-SHARED'

@description('Name of the resource group that contains the Spring Apps instance. Specify this value in the parameters.json file to override this default.')
param appRgName string = 'rg-${namePrefix}-APPS'

@description('Name of the resource group that Spring Apps creates for its runtime. Specify this value in the parameters.json file to override this default.')
param serviceRuntimeNetworkResourceGroup string = '${springAppsName}-runtime-rg'

@description('Name of the resource group that Spring Apps creates for its app space. Specify this value in the parameters.json file to override this default.')
param appNetworkResourceGroup string = '${springAppsName}-apps-rg'

//Network Security Group Names - Override these in the parameters.json file to match your organization's naming conventions
@description('Network Security Group name for the Bastion subnet. Specify this value in the parameters.json file to override this default.')
param bastionNsgName string = 'bastion-nsg'

@description('Network Security Group name for the Application Gateway subnet should you chose to deploy an AppGW. Specify this value in the parameters.json file to override this default.')
param snetAppGwNsg string = 'snet-agw-nsg'

@description('Network Security Group name for the ASA app subnet. Specify this value in the parameters.json file to override this default.')
param snetAppNsg string = 'snet-app-nsg'

@description('Network Security Group name for the ASA runtime subnet. Specify this value in the parameters.json file to override this default.')
param snetRuntimeNsg string = 'snet-runtime-nsg'

@description('Network Security Group name for the shared subnet. Specify this value in the parameters.json file to override this default.')
param snetSharedNsg string = 'snet-shared-nsg'

@description('Network Security Group name for the support subnet. Specify this value in the parameters.json file to override this default.')
param snetSupportNsg string = 'snet-support-nsg'

//Route Table Names - Override these in the parameters.json file to match your organization's naming conventions
@description('Name of the default apps route table. Specify this value in the parameters.json file to override this default.')
param defaultAppsRouteName string = 'default_apps_route'

@description('Name of the default hub route table. Specify this value in the parameters.json file to override this default.')
param defaultHubRouteName string = 'default_hub_route'

@description('Name of the default runtime route table. Specify this value in the parameters.json file to override this default.')
param defaultRuntimeRouteName string = 'default_runtime_route'

@description('Name of the default shared route table. Specify this value in the parameters.json file to override this default.')
param defaultSharedRouteName string = 'default_shared_route'

//CIDR BLOCKS
@description('IP CIDR Block for the App Gateway Subnet')
param appGwSubnetPrefix string

@description('IP CIDR Block for the Azure Firewall Subnet')
param azureFirewallSubnetPrefix string

@description('P CIDR Block for the Azure Bastion Subnet')
param bastionSubnetPrefix string

@description('IP CIDR Block for the Hub VNET')
param hubVnetAddressPrefix string

@description('IP CIDR Block for the Shared Subnet')
param sharedSubnetPrefix string

@description('IP CIDR Block for the Spoke VNET')
param spokeVnetAddressPrefix string

@description('IP CIDR Block for the Spring Apps Subnet')
param springAppsSubnetPrefix string

@description('IP CIDR Block for the Spring Apps Runtime Subnet')
param springAppsRuntimeSubnetPrefix string

@description('IP CIDR Block for the Support Subnet')
param supportSubnetPrefix string

//Miscellaneous Parameters.  Override as necessary.
@description('User name for admin account on the jump host')
param adminUserName string

@description('Private IP address of the existing firewll. If this script is not configured to deploy a firewall, this value must be set')
param azureFirewallIp string = ''

@description('Boolean indicating whether or not to deploy the hub module. Set to false and override the hub module parameters if you already have one in place.')
param deployHub bool = true

@description('Boolean indicating whether or not to deploy the firewal. Set to false and override the fireawall module parameters if you already have one in place.')
param deployFirewall bool = true

@description('Boolean describing whether or not to enable soft delete on Key Vault - set to TRUE for production')
param enableKvSoftDelete bool = false

@description('The Azure Region in which to deploy the Spring Apps Landing Zone Accelerator')
param location string

@description('The common prefix used when naming resources')
param namePrefix string

@description('The Azure AD Service Principal ID of the Azure Spring Cloud Resource Provider - this value varies by tenant - use the command "az ad sp show --id e8de9221-a19c-4c81-b814-fd37c6caf9d2 --query id --output tsv" to get the value specific to your tenant')
param principalId string

@description('Azure Resource Tags')
param tags object = {}

@description('Timestamp value used to group and uniquely identify a given deployment')
param timeStamp string = utcNow('yyyyMMddHHmm')

@description('Free form value indicating opearting environment (dev | qa | perf | prod)')
param environment string

@secure()
@description('Virtual machine admin account password')
param jumpHostPassword string

@description('Name of the Key Vault secret that will store the jump host password. Specify this value in the parameters.json file to override this default.')
param jumpHostPasswordSecretName string = 'jumpHostPassword'

@description('SKU size of the jump box. Specify this value in the parameters.json file to override this default.')
param vmSize string = 'Standard_DS3_v2'

@description('The CIDR Range that will be used for the Spring Apps backend cluster')
param springAppsRuntimeCidr string

/******************************/
/*     RESOURCES & MODULES    */
/******************************/

module hub '02-Hub-Network/main.bicep' = if (deployHub) {
  name: '${timeStamp}-hub-vnet'
  params: {
    azureBastionSubnetPrefix: bastionSubnetPrefix
    azureFirewallSubnetPrefix: azureFirewallSubnetPrefix
    bastionName: bastionName
    bastionNsgName: bastionNsgName
    deployFirewall: deployFirewall
    hubVnetAddressPrefix: hubVnetAddressPrefix
    hubVnetName: hubVnetName
    hubVnetRgName: hubVnetRgName
    location: location
    tags: tags
    timeStamp: timeStamp
  }
}

module lzNetwork '03-LZ-Network/main.bicep' = {
  name: '${timeStamp}-lz-vnet'
  params: {
    appGwSubnetPrefix: appGwSubnetPrefix
    hubVnetName: hubVnetName
    hubVnetRgName: hubVnetRgName
    location: location
    principalId: principalId
    privateZonesRgName: privateZonesRgName
    sharedSubnetPrefix: sharedSubnetPrefix
    snetAppGwName: snetAppGwName
    snetAppName: snetAppName
    snetRuntimeName: snetRuntimeName
    snetSharedName: snetSharedName
    snetSupportName: snetSupportName
    snetAppGwNsg: snetAppGwNsg
    snetAppNsg: snetAppNsg
    snetRuntimeNsg: snetRuntimeNsg
    snetSharedNsg: snetSharedNsg
    snetSupportNsg: snetSupportNsg
    spokeRgName: spokeRgName
    spokeVnetAddressPrefix: spokeVnetAddressPrefix
    spokeVnetName: spokeVnetName
    springAppsRuntimeSubnetPrefix: springAppsRuntimeSubnetPrefix
    springAppsSubnetPrefix: springAppsSubnetPrefix
    supportSubnetPrefix: supportSubnetPrefix
    tags: tags
    timeStamp: timeStamp
  }
  dependsOn: [
    hub
  ]
}

module sharedResources '04-LZ-SharedResources/main.bicep' = {
  name: '${timeStamp}-shared-resources'
  params: {
    adminUserName: adminUserName
    enableKvSoftDelete: enableKvSoftDelete
    jumpHostPassword: jumpHostPassword
    jumpHostPasswordSecretName: jumpHostPasswordSecretName
    keyVaultName: keyVaultName
    location: location
    privateZonesRgName: privateZonesRgName
    sharedRgName: sharedRgName
    spokeRgName: spokeRgName
    spokeVnetName: spokeVnetName
    subnetShared: snetSharedName
    subnetSupport: snetSupportName
    tags: tags
    timeStamp: timeStamp
    vmName: vmName
    vmSize: vmSize
  }
  dependsOn: [
    lzNetwork
  ]
}

module firewall '05-Hub-AzureFirewall/main.bicep' = {
  name: '${timeStamp}-firewall'
  params: {
    azureFirewallName: azureFirewallName
    azureFirewallSubnetPrefix: azureFirewallSubnetPrefix
    deployFirewall: deployFirewall
    hubVnetName: hubVnetName
    hubVnetRgName: hubVnetRgName
    location: location
    sharedSubnetPrefix: sharedSubnetPrefix
    springAppsRuntimeSubnetPrefix: springAppsRuntimeSubnetPrefix
    springAppsSubnetPrefix: springAppsSubnetPrefix
    tags: tags
    timeStamp: timeStamp
  }
  dependsOn: [
    lzNetwork
  ]
}

module springApps '06-LZ-SpringApps-Standard/main.bicep' = {
  name: '${timeStamp}-spring-apps'
  params: {
    appGwSubnetPrefix: appGwSubnetPrefix
    appInsightsName: appInsightsName
    appNetworkResourceGroup: appNetworkResourceGroup
    appRgName: appRgName
    azureFirewallIp: deployFirewall ? firewall.outputs.privateIp : azureFirewallIp
    defaultAppsRouteName: defaultAppsRouteName
    defaultHubRouteName: defaultHubRouteName
    defaultRuntimeRouteName: defaultRuntimeRouteName
    defaultSharedRouteName: defaultSharedRouteName
    hubVnetRgName: hubVnetRgName
    location: location
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    principalId: principalId
    privateZonesRgName: privateZonesRgName
    serviceRuntimeNetworkResourceGroup: serviceRuntimeNetworkResourceGroup
    sharedRgName: sharedRgName
    sharedSubnetPrefix: sharedSubnetPrefix
    snetAppGwNsg: snetAppGwNsg
    snetAppNsg: snetAppNsg
    snetRuntimeNsg: snetRuntimeNsg
    snetSharedNsg: snetSharedNsg
    snetSupportNsg: snetSupportNsg
    spokeRgName: spokeRgName
    spokeVnetAddressPrefix: spokeVnetAddressPrefix
    spokeVnetName: spokeVnetName
    springAppsName: springAppsName
    springAppsRuntimeCidr: springAppsRuntimeCidr
    springAppsRuntimeSubnetPrefix: springAppsRuntimeSubnetPrefix
    springAppsSubnetPrefix: springAppsSubnetPrefix
    supportSubnetPrefix: supportSubnetPrefix
    tags: tags
    timeStamp: timeStamp
  }
  dependsOn: [
    sharedResources
    firewall
  ]
}
