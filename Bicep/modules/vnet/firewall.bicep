param fwname string
param location string
param tags object
param hubSharedServicesCidr string
param spokeAppSubnetCidr string
param spokeRuntimeSubnetCidr string
param azfwSubnetId string
param azfwPipId string
param diagnosticname string
param laworkspaceId string

resource firewall 'Microsoft.Network/azureFirewalls@2020-11-01' = {
  name: fwname
  location: location
  tags: tags
//  zones: [
//    '1'
//  ]
  properties: {
    networkRuleCollections: [
      {
        name: 'VmAppAccess'
        properties: {
          priority: 100
          action: {
            type: 'Allow'
          }
          rules: [
            {
              name: 'AllowVMAppAccess'
              description: 'Allows VM in hub to call web Spring Apps direct'
              protocols: [
                'TCP'
              ]
              sourceAddresses: [
                hubSharedServicesCidr
              ]
              destinationAddresses: [
                spokeAppSubnetCidr
              ]
              destinationPorts: [
                '80'
                '443'
              ]
            }
          ]
        }
      }
      {
        name: 'VmInternetAccess'
        properties: {
          priority: 101
          action: {
            type: 'Allow'
          }
          rules: [
            {
              name: 'AllowVMAppAccess'
              description: 'Allows VM access to the web'
              protocols: [
                'TCP'
              ]
              sourceAddresses: [
                hubSharedServicesCidr
              ]
              destinationAddresses: [
                '*'
              ]
              destinationPorts: [
                '80'
                '443'
              ]
            }
            {
              name: 'AllowKMSActivation'
              description: 'Allows VM acess to KMS servers'
              protocols: [
                'TCP'
              ]
              sourceAddresses: [
                hubSharedServicesCidr
              ]
              destinationFqdns: [
                'kms.core.windows.net'
              ]
              destinationPorts: [
                '1688'
              ]
            }
          ]
        }
      }
      {
        name: 'SpringAppsAccess'
        properties: {
          priority: 102
          action: {
            type: 'Allow'
          }
          rules: [
            {
              name: 'SpringMgmt'
              description: 'Allows access to Spring Apps Management plane'
              protocols: [
                'TCP'
              ]
              sourceAddresses: [
                spokeRuntimeSubnetCidr
                spokeAppSubnetCidr
              ]
              destinationAddresses: [
                'AzureCloud'
              ]
              destinationPorts: [
                '443'
              ]
            }
            {
              name: 'KubernetesMgmtTcp'
              description: 'Allows underlining Kubernetes cluster management for TCP traffic'
              protocols: [
                'TCP'
              ]
              sourceAddresses: [
                spokeRuntimeSubnetCidr
                spokeAppSubnetCidr
              ]
              destinationAddresses: [
                'AzureCloud'
              ]
              destinationPorts: [
                '9000'
              ]
            }
            {
              name: 'KubernetesMgmtUdp'
              description: 'Allows underlining Kubernetes cluster management for UDP traffic'
              protocols: [
                'UDP'
              ]
              sourceAddresses: [
                spokeRuntimeSubnetCidr
                spokeAppSubnetCidr
              ]
              destinationAddresses: [
                'AzureCloud'
              ]
              destinationPorts: [
                '1194'
              ]
            }
            {
              name: 'AzureContainerRegistery'
              description: 'Allows access to Azure Container Registery'
              protocols: [
                'TCP'
              ]
              sourceAddresses: [
                spokeRuntimeSubnetCidr
                spokeAppSubnetCidr
              ]
              destinationAddresses: [
                'AzureContainerRegistry'
              ]
              destinationPorts: [
                '443'
              ]
            }
            {
              name: 'AzureStorage'
              description: 'Allows access to Azure File Storage'
              protocols: [
                'TCP'
              ]
              sourceAddresses: [
                spokeRuntimeSubnetCidr
                spokeAppSubnetCidr
              ]
              destinationAddresses: [
                'Storage'
              ]
              destinationPorts: [
                '445'
              ]
            }
            {
              name: 'NtpQuery'
              description: 'Allows access of nodes for NTP to Ubuntu time servers'
              protocols: [
                'UDP'
              ]
              sourceAddresses: [
                spokeRuntimeSubnetCidr
                spokeAppSubnetCidr
              ]
              destinationAddresses: [
                '*'
              ]
              destinationPorts: [
                '123'
              ]
            }
          ]
        }
      }
    ]
    applicationRuleCollections: [
      {
        name: 'AllowSpringAppsWebAccess'
        properties: {
          priority: 100
          action: {
            type: 'Allow'
          }
          rules: [
            {
              name: 'AllowAks'
              description: 'Allow access for Azure Kubernetes Service'
              sourceAddresses: [
                spokeRuntimeSubnetCidr
                spokeAppSubnetCidr
              ]
              protocols: [
                {
                  protocolType: 'Https'
                  port: 443
                }
              ]
              fqdnTags: [
                'AzureKubernetesService'
              ]
            }
            {
              name: 'AllowKubMgmt'
              description: 'Allow access for Kubernetes Cluster Management'
              sourceAddresses: [
                spokeRuntimeSubnetCidr
                spokeAppSubnetCidr
              ]
              protocols: [
                {
                  protocolType: 'Https'
                  port: 443
                }
              ]
              targetFqdns: [
                '*.azmk8s.io'
                'management.azure.com'
              ]
            }
            {
              name: 'AllowMCR'
              description: 'Allow access to Microsoft Container Registry'
              sourceAddresses: [
                spokeRuntimeSubnetCidr
                spokeAppSubnetCidr
              ]
              protocols: [
                {
                  protocolType: 'Https'
                  port: 443
                }
              ]
              targetFqdns: [
                'mcr.microsoft.com'
              ]
            }
            {
              name: 'AllowMCRStorage'
              description: 'Allow access to Microsoft Container Registry storage backed by CDN'
              sourceAddresses: [
                spokeRuntimeSubnetCidr
                spokeAppSubnetCidr
              ]
              protocols: [
                {
                  protocolType: 'Https'
                  port: 443
                }
              ]
              targetFqdns: [
                '*.cdn.mscr.io'
                '*.data.mcr.microsoft.com'
              ]
            }
            {
              name: 'AllowAzureAd'
              description: 'Allow access to Azure AD for authentication'
              sourceAddresses: [
                spokeRuntimeSubnetCidr
                spokeAppSubnetCidr
              ]
              protocols: [
                {
                  protocolType: 'Https'
                  port: 443
                }
              ]
              targetFqdns: [
                'login.microsoftonline.com'
              ]
            }
            {
              name: 'AllowMSPackRepo'
              description: 'Allow access to Microsoft package repository'
              sourceAddresses: [
                spokeRuntimeSubnetCidr
                spokeAppSubnetCidr
              ]
              protocols: [
                {
                  protocolType: 'Https'
                  port: 443
                }
              ]
              targetFqdns: [
                'packages.microsoft.com'
                'acs-mirror.azureedge.net'
              ]
            }
            {
              name: 'AllowGitHub'
              description: 'Allow GitHub'
              sourceAddresses: [
                spokeRuntimeSubnetCidr
                spokeAppSubnetCidr
              ]
              protocols: [
                {
                  protocolType: 'Https'
                  port: 443
                }
              ]
              targetFqdns: [
                'github.com'
              ]
            }
            {
              name: 'AllowDocker'
              description: 'Allow Docker'
              sourceAddresses: [
                spokeRuntimeSubnetCidr
                spokeAppSubnetCidr
              ]
              protocols: [
                {
                  protocolType: 'Https'
                  port: 443
                }
              ]
              targetFqdns: [
                '*.docker.io'
                '*.docker.com'
              ]
            }
            {
              name: 'AllowSnapcraft'
              description: 'Allow Snapcraft'
              sourceAddresses: [
                spokeRuntimeSubnetCidr
                spokeAppSubnetCidr
              ]
              protocols: [
                {
                  protocolType: 'Https'
                  port: 443
                }
              ]
              targetFqdns: [
                'api.snapcraft.io'
              ]
            }
            {
              name: 'AllowClamAv'
              description: 'Allow ClamAv'
              sourceAddresses: [
                spokeRuntimeSubnetCidr
                spokeAppSubnetCidr
              ]
              protocols: [
                {
                  protocolType: 'Https'
                  port: 443
                }
              ]
              targetFqdns: [
                'database.clamav.net'
              ]
            }
            {
              name: 'UbuntuMisc'
              description: 'Allow Ubuntu Misc'
              sourceAddresses: [
                spokeRuntimeSubnetCidr
                spokeAppSubnetCidr
              ]
              protocols: [
                {
                  protocolType: 'Https'
                  port: 443
                }
              ]
              targetFqdns: [
                'motd.ubuntu.com'
              ]
            }
            {
              name: 'MsCrls'
              description: 'Allows access to Microsoft CRL distribution points'
              sourceAddresses: [
                spokeRuntimeSubnetCidr
                spokeAppSubnetCidr
              ]
              protocols: [
                {
                  protocolType: 'Http'
                  port: 80
                }
              ]
              targetFqdns: [
                'crl.microsoft.com'
                'mscrl.microsoft.com'
              ]
            }
            {
              name: 'AllowDigiCerty'
              description: 'Allows access to Microsoft CRL distribution points'
              sourceAddresses: [
                spokeRuntimeSubnetCidr
                spokeAppSubnetCidr
              ]
              protocols: [
                {
                  protocolType: 'Http'
                  port: 80
                }
              ]
              targetFqdns: [
                'crl3.digicert.com'
                'crl4.digicert.com'
              ]
            }
          ]
        }
      }
    ]
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: azfwSubnetId
          }
          publicIPAddress: {
            id: azfwPipId
          }
        }
      }
    ]
    threatIntelMode: 'Alert'
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }
    additionalProperties: {
       'Network.DNS.EnableProxy': 'true'
    }
  }
}

resource fwdiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: diagnosticname
  scope: firewall
  properties: {
    logs: [
      {
        category: 'AzureFirewallApplicationRule'
        enabled: true
      }
      {
        category: 'AzureFirewallNetworkRule'
        enabled: true
      }
      {
        category: 'AzureFirewallDnsProxy'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
    workspaceId: laworkspaceId
  }
}


output fwPrivateIP string = firewall.properties.ipConfigurations[0].properties.privateIPAddress
output fwName string = firewall.name
