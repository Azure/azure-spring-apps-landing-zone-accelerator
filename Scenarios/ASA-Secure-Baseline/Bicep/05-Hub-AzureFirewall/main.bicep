targetScope = 'subscription'

/******************************/
/*         PARAMETERS         */
/******************************/

@description('Name of the Azure Firewall. Specify this value in the parameters.json file to override this default.')
param azureFirewallName string

@description('IP CIDR Block for the Azure Firewall Subnet')
param azureFirewallSubnetPrefix string

@description('Boolean value indicating whether or not to deploy the Azure Firewall.')
param deployFirewall bool

@description('Name of the hub VNET. Specify this value in the parameters.json file to override this default.')
param hubVnetName string

@description('Name of the resource group that contains the hub VNET. Specify this value in the parameters.json file to override this default.')
param hubVnetRgName string

@description('The Azure Region in which to deploy the Spring Apps Landing Zone Accelerator')
param location string

@description('IP CIDR Block for the Shared Subnet')
param sharedSubnetPrefix string

@description('IP CIDR Block for the Spring Apps Subnet')
param springAppsSubnetPrefix string

@description('IP CIDR Block for the Spring Apps Runtime Subnet')
param springAppsRuntimeSubnetPrefix string

@description('Azure Resource Tags')
param tags object
@description('Timestamp value used to group and uniquely identify a given deployment')
param timeStamp string

/******************************/
/*     RESOURCES & MODULES    */
/******************************/
module azfwSubnet '../Modules/subnet.bicep' = if(deployFirewall) {
  name: '${timeStamp}-azfwSubnet'
  scope: resourceGroup(hubVnetRgName)
  params: {
    addressPrefix: azureFirewallSubnetPrefix
    vnetName: hubVnetName
    name: 'AzureFirewallSubnet'
  }
}

module azfw '../Modules/azfw.bicep' = if (deployFirewall) {
  name: '${timeStamp}-azfw'
  scope: resourceGroup(hubVnetRgName)
  params: {
    name: azureFirewallName
    privateTrafficPrefixes: azureFirewallSubnetPrefix
    fireWallSubnetName: 'AzureFirewallSubnet'
    location: location
    hubVnetName: hubVnetName
    networkRules: [
      {
        name: 'SpringAppsRefArchNetworkRules'
        properties: {
          action: { type: 'Allow' }
          priority: 100
          rules: [
            {
              name: 'AllowVMAppAccess'
              sourceAddresses: [
                sharedSubnetPrefix
              ]
              destinationAddresses: [
                springAppsSubnetPrefix
              ]
              destinationPorts: [
                '80'
                '443'
              ]
              protocols: [
                'TCP'
              ]
            }
            {
              name: 'AllowAllWebAccess'
              sourceAddresses: [
                sharedSubnetPrefix
              ]
              destinationAddresses: [
                '*'
              ]
              destinationPorts: [
                '80'
                '443'
              ]
              protocols: [
                'TCP'
              ]
            }
            {
              name: 'AllowKMSActivation'
              sourceAddresses: [
                sharedSubnetPrefix
              ]
              destinationAddresses: [
                '*'
              ]
              destinationPorts: [
                '1688'
              ]
              protocols: [
                'TCP'
              ]
            }
            {
              name: 'SpringMgmt'
              sourceAddresses: [
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
              ]
              destinationAddresses: [
                'AzureCloud'
              ]
              destinationPorts: [
                '443'
              ]
              protocols: [
                'TCP'
              ]
            }
            {
              name: 'KubernetesMgmtTcp'
              sourceAddresses: [
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
              ]
              destinationAddresses: [
                'AzureCloud'
              ]
              destinationPorts: [
                '9000'
              ]
              protocols: [
                'TCP'
              ]
            }
            {
              name: 'KubernetesMgmtUdp'
              sourceAddresses: [
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
              ]
              destinationAddresses: [
                'AzureCloud'
              ]
              destinationPorts: [
                '1194'
              ]
              protocols: [
                'UDP'
              ]
            }

            {
              name: 'AzureContainerRegistery'
              sourceAddresses: [
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
              ]
              destinationAddresses: [
                'AzureContainerRegistry'
              ]
              destinationPorts: [
                '443'
              ]
              protocols: [
                'TCP'
              ]
            }
            {
              name: 'AzureStorage'
              sourceAddresses: [
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
              ]
              destinationAddresses: [
                'Storage'
              ]
              destinationPorts: [
                '445'
              ]
              protocols: [
                'TCP'
              ]
            }
            {
              name: 'NtpQuery'
              sourceAddresses: [
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
              ]
              destinationAddresses: [
                '*'
              ]
              destinationPorts: [
                '123'
              ]
              protocols: [
                'UDP'
              ]
            }
          ]
        }
      }
    ]
    applicationRules: [
      {
        name: 'SpringAppsApplicationRules'
        properties: {
          action: {
            type: 'Allow'
          }
          priority: 100
          rules: [
            {
              name: 'AllowAks'
              sourceAddresses: [
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
              ]
              fqdnTags: [
                'AzureKubernetesService'
              ]
            }
            {
              name: 'AllowKubMgmt'
              sourceAddresses: [
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
              ]
              targetFqdns: [
                '*.azmk8s.io'
                substring(environment().resourceManager, 8, length(environment().resourceManager) - 9) //This strips off the protocol and trailing slash and is to eliminate the linter failure on hard coded special domains
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
            }
            {
              name: 'AllowMCR'
              sourceAddresses: [
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
              ]
              targetFqdns: [
                'mcr.microsoft.com'
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
            }
            {
              name: 'AllowMCRStorage'
              sourceAddresses: [
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
              ]
              targetFqdns: [
                '*.cdn.mscr.io'
                '*.data.mcr.microsoft.com'
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
            }
            {
              name: 'AllowAzureAd'
              sourceAddresses: [
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
              ]
              targetFqdns: [
                substring(environment().authentication.loginEndpoint, 8, length(environment().authentication.loginEndpoint) - 9) //This strips off the protocol and trailing slash and is to eliminate the linter failure on hard coded special domains
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
            }
            {
              name: 'AllowMSPackRepo'
              sourceAddresses: [
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
              ]
              targetFqdns: [
                'packages.microsoft.com'
                'acs-mirror.azureedge.net'
                '*.azureedge.net'
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
            }
            {
              name: 'AllowGitHub'
              sourceAddresses: [
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
              ]
              targetFqdns: [
                'github.com'
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
            }
            {
              name: 'AllowDocker'
              sourceAddresses: [
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
              ]
              targetFqdns: [
                '*.docker.io'
                '*.docker.com'
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]

            }
            {
              name: 'AllowSnapcraft'
              sourceAddresses: [
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
              ]
              targetFqdns: [
                'api.snapcraft.io'
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
            }
            {
              name: 'AllowClamAv'
              sourceAddresses: [
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
              ]
              targetFqdns: [
                'database.clamav.net'
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
            }
            {
              name: 'Allow*UbuntuMisc'
              sourceAddresses: [
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
              ]
              targetFqdns: [
                'motd.ubuntu.com'
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
            }
            {
              name: 'MsCrls'
              sourceAddresses: [
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
              ]
              targetFqdns: [
                'crl.microsoft.com'
                'mscrl.microsoft.com'
              ]
              protocols: [
                {
                  port: 80
                  protocolType: 'Http'
                }
              ]
            }
            {
              name: 'AllowDigiCerty'
              sourceAddresses: [
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
              ]
              targetFqdns: [
                'crl3.digicert.com'
                'crl4.digicert.com'
              ]
              protocols: [
                {
                  port: 80
                  protocolType: 'Http'
                }
              ]
            }
          ]
        }
      }
      {
        name: 'AllowAcmeFitnessInstall'
        properties: {
          action: {
            type: 'Allow'
          }
          priority: 800
          rules: [
            {
              name: 'nuget'
              sourceAddresses: [
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
              ]
              targetFqdns: [
                'api.nuget.org'
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
            }
            {
              name: 'pypi'
              sourceAddresses: [
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
              ]
              targetFqdns: [
                'pypi.org'
                'files.pythonhosted.org'
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
            }
            {
              name: 'npm'
              sourceAddresses: [
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
              ]
              targetFqdns: [
                'registry.npmjs.org'
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
            }
            {
              name: 'gradle'
              sourceAddresses: [
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
              ]
              targetFqdns: [
                '*.gradle.org'
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
            }
            {
              name: 'maven'
              sourceAddresses: [
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
              ]
              targetFqdns: [
                'repo.maven.apache.org'
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
            }
            {
              name: 'jfrog-jcenter'
              sourceAddresses: [
                springAppsSubnetPrefix
                springAppsRuntimeSubnetPrefix
              ]
              targetFqdns: [
                'jcenter.bintray.com'
              ]
              protocols: [
                {
                  port: 443
                  protocolType: 'Https'
                }
              ]
            }
          ]
        }
      }
    ]
    tags: tags
  }
}

output privateIp string = deployFirewall ? azfw.outputs.privateIp : ''
