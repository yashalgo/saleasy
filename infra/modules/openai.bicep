// Azure OpenAI Service + GPT-4o Mini Deployment

@description('Azure region')
param location string

@description('TPM rate limit in thousands')
param tpmRateLimit int

@description('Key Vault name to store API key')
param keyVaultName string

@description('Resource tags')
param tags object

// ─── Azure OpenAI Resource ────────────────────────────────────────────────────

resource openai 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: 'salesvoice-openai'
  location: location
  kind: 'OpenAI'
  tags: tags
  sku: {
    name: 'S0'
  }
  properties: {
    customSubDomainName: 'salesvoice-openai'
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
    }
  }
}

// ─── GPT-4o Mini Model Deployment ─────────────────────────────────────────────

resource gpt4oMiniDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = {
  parent: openai
  name: 'gpt-4o-mini'
  sku: {
    name: 'Standard'
    capacity: tpmRateLimit
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4o-mini'
      version: '2024-07-18'
    }
    raiPolicyName: 'Microsoft.DefaultV2'
  }
}

// ─── Store API Key in Key Vault ───────────────────────────────────────────────

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource openaiKeySecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'azure-openai-key'
  properties: {
    value: openai.listKeys().key1
  }
}

// ─── Outputs ──────────────────────────────────────────────────────────────────

output openaiEndpoint string = openai.properties.endpoint
output openaiResourceName string = openai.name
output deploymentName string = gpt4oMiniDeployment.name
