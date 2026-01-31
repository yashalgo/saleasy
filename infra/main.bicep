// SalesVoice Azure Infrastructure — Main Orchestrator
// Deploys all Azure resources for the SalesVoice platform
// Region: Central India (Pune) for all resources

targetScope = 'subscription'

// ─── Parameters ───────────────────────────────────────────────────────────────

@description('Azure region for all resources')
param location string = 'centralindia'

@description('Environment name')
@allowed(['production', 'staging'])
param environment string = 'production'

@description('Email addresses for alert notifications')
param alertEmailAddresses array

@description('Azure OpenAI model deployment TPM rate limit (in thousands)')
param openaiTpmRateLimit int = 80

@description('Azure OpenAI region override — use if GPT-4o Mini is not available in Central India')
param openaiRegion string = location

@description('Deploy Azure AI Speech evaluation resource')
param deploySpeechEval bool = true

@description('Deploy staging slot for Function App')
param deployStagingSlot bool = true

// ─── Tags ─────────────────────────────────────────────────────────────────────

var commonTags = {
  project: 'salesvoice'
  environment: environment
  'cost-center': 'azure-credits'
  'managed-by': 'bicep'
}

// ─── Resource Group ───────────────────────────────────────────────────────────

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'salesvoice-prod'
  location: location
  tags: commonTags
}

// ─── Budget & Cost Alerts (subscription-scoped) ──────────────────────────────

module budgets 'modules/budgets.bicep' = {
  name: 'budgets-deployment'
  scope: rg
  params: {
    alertEmailAddresses: alertEmailAddresses
    tags: commonTags
  }
}

// ─── Key Vault ────────────────────────────────────────────────────────────────

module keyVault 'modules/keyvault.bicep' = {
  name: 'keyvault-deployment'
  scope: rg
  params: {
    location: location
    tags: commonTags
  }
}

// ─── Azure OpenAI ─────────────────────────────────────────────────────────────

module openai 'modules/openai.bicep' = {
  name: 'openai-deployment'
  scope: rg
  params: {
    location: openaiRegion
    tpmRateLimit: openaiTpmRateLimit
    keyVaultName: keyVault.outputs.keyVaultName
    tags: commonTags
  }
}

// ─── Storage Account & Queues ─────────────────────────────────────────────────

module storage 'modules/storage.bicep' = {
  name: 'storage-deployment'
  scope: rg
  params: {
    location: location
    tags: commonTags
  }
}

// ─── Log Analytics & Application Insights ─────────────────────────────────────

module monitoring 'modules/monitoring.bicep' = {
  name: 'monitoring-deployment'
  scope: rg
  params: {
    location: location
    alertEmailAddresses: alertEmailAddresses
    tags: commonTags
  }
}

// ─── Azure Functions ──────────────────────────────────────────────────────────

module functions 'modules/functions.bicep' = {
  name: 'functions-deployment'
  scope: rg
  params: {
    location: location
    storageAccountName: storage.outputs.storageAccountName
    appInsightsConnectionString: monitoring.outputs.appInsightsConnectionString
    appInsightsInstrumentationKey: monitoring.outputs.appInsightsInstrumentationKey
    keyVaultUri: keyVault.outputs.keyVaultUri
    openaiEndpoint: openai.outputs.openaiEndpoint
    openaiDeploymentName: openai.outputs.deploymentName
    deployStagingSlot: deployStagingSlot
    tags: commonTags
  }
}

// Grant Function App access to Key Vault
module keyVaultAccess 'modules/keyvault-access.bicep' = {
  name: 'keyvault-access-deployment'
  scope: rg
  params: {
    keyVaultName: keyVault.outputs.keyVaultName
    functionAppPrincipalId: functions.outputs.functionAppPrincipalId
  }
}

// ─── Azure AI Speech (Evaluation Only) ────────────────────────────────────────

module speechEval 'modules/speech.bicep' = if (deploySpeechEval) {
  name: 'speech-eval-deployment'
  scope: rg
  params: {
    location: location
    keyVaultName: keyVault.outputs.keyVaultName
    tags: commonTags
  }
}

// ─── Outputs ──────────────────────────────────────────────────────────────────

output resourceGroupName string = rg.name
output openaiEndpoint string = openai.outputs.openaiEndpoint
output openaiDeploymentName string = openai.outputs.deploymentName
output functionAppUrl string = functions.outputs.functionAppUrl
output functionAppName string = functions.outputs.functionAppName
output appInsightsName string = monitoring.outputs.appInsightsName
output keyVaultUri string = keyVault.outputs.keyVaultUri
output storageAccountName string = storage.outputs.storageAccountName
