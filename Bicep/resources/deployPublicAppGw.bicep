param applicationGatewayName string = 'appGW01'
param appGWPublicIpAddressName string = 'appGW01-PIP'

@description('Base64 value of a PFX certificate file used by the Application Gateway Listener')
@secure()
param https_data string

@description('Password of the PFX certificate file used by the Application Gateway listener')
@secure()
param https_password string

@description('backend URL of Azure Spring Cloud Application')
param backendPoolFQDN string

@description('The tags that will be associated to the VM')
param tags object = {
  environment: 'lab'
}

var hubVnetName = 'vnet-hub'
var appGatewaySubnetName = 'snet-agw'
var location = resourceGroup().location

resource appGatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: '${hubVnetName}/${appGatewaySubnetName}'
}

resource applicationGateway 'Microsoft.Network/applicationGateways@2019-11-01' = {
  name: applicationGatewayName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
      capacity: 2
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: appGatewaySubnet.id
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIp'
        properties: {
          publicIPAddress: {
            id: appGWPublicIpAddress.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_443'
        properties: {
          port: 443
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'backend-pool'
        properties: {
          backendAddresses: [
            {
              fqdn: backendPoolFQDN
            }
          ]
        }
      }
    ]
    sslCertificates: [
      {
        name: 'mySSLCert'
        properties: {
          data: https_data
          password: https_password
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'backend-httpsetting'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 20
          pickHostNameFromBackendAddress: true
        }
      }
    ]
    httpListeners: [
      {
        name: 'myapp-listener-https'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'appGwPublicFrontendIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_443')
          }
          protocol: 'Https'
          sslCertificate: {
            id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', applicationGatewayName, 'mySSLCert')
          }
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'myapp-Rule'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'myapp-listener-https')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, 'backend-pool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'backend-httpsetting')
          }
        }
      }
    ]
    enableHttp2: false
    probes: []
    webApplicationFirewallConfiguration: {
      enabled: true
      firewallMode: 'Detection'
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.0'
    }
  }
}

resource appGWPublicIpAddress 'Microsoft.Network/publicIPAddresses@2019-02-01' = {
  name: appGWPublicIpAddressName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}
