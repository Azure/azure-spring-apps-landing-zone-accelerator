targetScope = 'subscription'

@description('The Azure Region in which to deploy the Spring Apps Landing Zone Accelerator')
param location string
param namePrefix string
param tags object = {}

resource networkRg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${namePrefix}-network-spoke-rg'
  location: location
  tags: tags
}
