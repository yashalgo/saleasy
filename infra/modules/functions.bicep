// Azure Function App — SalesVoice Processing Pipeline

@description('Azure region')
param location string

@description('Storage account name for Function App')
param storageAccountName string

@description('Application Insights connection string')
param appInsightsConnectionString string

@description('Application Insights instrumentation key')
param appInsightsInstrumentationKey string

@description('Key Vault URI')
param keyVaultUri string

@description('Azure OpenAI endpoint')
param openaiEndpoint string

@description('Azure OpenAI deployment name')
param openaiDeploymentName string

@description('Deploy a staging slot')
param deployStagingSlot bool

@description('Resource tags')
param tags object

// ─── References ───────────────────────────────────────────────────────────────

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: storageAccountName
}

// ─── App Service Plan (Consumption) ───────────────────────────────────────────

resource hostingPlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: 'salesvoice-plan'
  location: location
  tags: tags
  kind: 'functionapp'
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {
    reserved: true // Linux
  }
}

// ─── Function App ─────────────────────────────────────────────────────────────

resource functionApp 'Microsoft.Web/sites@2023-12-01' = {
  name: 'salesvoice-pipeline'
  location: location
  tags: tags
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'NODE|20'
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      appSettings: [
        // Runtime settings
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${az.environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${az.environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: 'salesvoice-pipeline'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~20'
        }
        // Application Insights
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightsConnectionString
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsightsInstrumentationKey
        }
        // Azure OpenAI — key from Key Vault
        {
          name: 'AZURE_OPENAI_ENDPOINT'
          value: openaiEndpoint
        }
        {
          name: 'AZURE_OPENAI_KEY'
          value: '@Microsoft.KeyVault(SecretUri=${keyVaultUri}secrets/azure-openai-key/)'
        }
        {
          name: 'AZURE_OPENAI_DEPLOYMENT'
          value: openaiDeploymentName
        }
        {
          name: 'AZURE_OPENAI_API_VERSION'
          value: '2024-10-21'
        }
        // External service keys — referenced from Key Vault (populated later by partner)
        {
          name: 'GROQ_API_KEY'
          value: '@Microsoft.KeyVault(SecretUri=${keyVaultUri}secrets/groq-api-key/)'
        }
        {
          name: 'SUPABASE_URL'
          value: '@Microsoft.KeyVault(SecretUri=${keyVaultUri}secrets/supabase-url/)'
        }
        {
          name: 'SUPABASE_SERVICE_KEY'
          value: '@Microsoft.KeyVault(SecretUri=${keyVaultUri}secrets/supabase-service-key/)'
        }
        {
          name: 'R2_ENDPOINT'
          value: '@Microsoft.KeyVault(SecretUri=${keyVaultUri}secrets/r2-endpoint/)'
        }
        {
          name: 'R2_ACCESS_KEY_ID'
          value: '@Microsoft.KeyVault(SecretUri=${keyVaultUri}secrets/r2-access-key-id/)'
        }
        {
          name: 'R2_SECRET_ACCESS_KEY'
          value: '@Microsoft.KeyVault(SecretUri=${keyVaultUri}secrets/r2-secret-access-key/)'
        }
        {
          name: 'R2_BUCKET_NAME'
          value: 'salesvoice-audio'
        }
        {
          name: 'NODE_ENV'
          value: 'production'
        }
      ]
    }
  }
}

// ─── Staging Slot ─────────────────────────────────────────────────────────────

resource stagingSlot 'Microsoft.Web/sites/slots@2023-12-01' = if (deployStagingSlot) {
  parent: functionApp
  name: 'staging'
  location: location
  tags: tags
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'NODE|20'
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
    }
  }
}

// ─── Outputs ──────────────────────────────────────────────────────────────────

output functionAppUrl string = 'https://${functionApp.properties.defaultHostName}'
output functionAppName string = functionApp.name
output functionAppPrincipalId string = functionApp.identity.principalId
