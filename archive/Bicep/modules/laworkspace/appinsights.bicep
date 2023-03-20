param name string
param location string
param kind string
param tags object

resource appInsights 'Microsoft.Insights/components@2015-05-01' = {
  name: name
  location: location
  kind: kind
  tags: tags
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Bluefield'
    Request_Source: 'rest'
  }
}

output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
