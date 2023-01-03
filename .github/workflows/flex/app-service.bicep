param appName string
param location string
param vnetSubnetId string
param appInsightsInstrumentationKey string
param appInsightsConnectionString string
param storageConnectionString string

var SasToken = 'https://arcartifystorage.blob.core.windows.net/zipcode/silo.zip?sv=2020-04-08&st=2023-01-02T14%3A37%3A30Z&se=2023-01-03T14%3A37%3A30Z&sr=b&sp=r&sig=IofWdGEZ%2BwpuF9d%2B74IjIhhGUCUTl54Wpp2OBA%2BkLqs%3D'

resource appServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: '${appName}-plan'
  location: location
  kind: 'app'
  sku: {
    name: 'S1'
    capacity: 1
  }
}

/* resource appService 'Microsoft.Web/sites@2021-03-01' = {
  name: appName
  location: location
  kind: 'app'
  properties: {
    serverFarmId: appServicePlan.id
    virtualNetworkSubnetId: vnetSubnetId
    httpsOnly: true
    siteConfig: {
      vnetPrivatePortsCount: 2
      webSocketsEnabled: true
      netFrameworkVersion: 'v6.0'
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsightsInstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightsConnectionString
        }
        {
          name: 'ORLEANS_AZURE_STORAGE_CONNECTION_STRING'
          value: storageConnectionString
        }
      ]
      alwaysOn: true
    }
  }
}

resource appServiceSlot 'Microsoft.Web/sites/slots@2022-03-01' = {
  name: '${appName}/staging'
  location: location
  dependsOn: [
    appService
  ]
  kind: 'app'
  properties: {
    serverFarmId: appServicePlan.id
    virtualNetworkSubnetId: vnetSubnetId
    httpsOnly: true
    siteConfig: {
      vnetPrivatePortsCount: 2      
      webSocketsEnabled: true
      netFrameworkVersion: 'v6.0'
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsightsInstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightsConnectionString
        }
        {
          name: 'ORLEANS_AZURE_STORAGE_CONNECTION_STRING'
          value: storageConnectionString
        }
      ]
      alwaysOn: true
    }
  }
} */

resource appService 'Microsoft.Web/sites@2021-03-01' existing = {
  name: appName
}

resource appServiceSlot 'Microsoft.Web/sites/slots@2022-03-01' existing = {
  name: '${appName}/staging'
}

resource appServiceConfig 'Microsoft.Web/sites/config@2021-03-01' = {
  name: '${appService.name}/metadata'
  properties: {
    CURRENT_STACK: 'dotnet'
  }
}
resource appServiceSlotConfig 'Microsoft.Web/sites/slots/config@2022-03-01' = {
  name: '${appService.name}/staging/metadata'
  properties: {
    CURRENT_STACK: 'dotnet'
  }
}

resource msdeployname 'Microsoft.Web/sites/extensions@2022-03-01' = {
  name: '${appService.name}/zipdeploy'
  properties: {
    packageUri: SasToken
  }
} 

resource msdeploySlot 'Microsoft.Web/sites/slots/extensions@2022-03-01' = {
  name: '${appServiceSlot.name}/zipdeploy'
  properties: {
    packageUri: SasToken
  }
}

