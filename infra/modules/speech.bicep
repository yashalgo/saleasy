// Azure AI Speech — Hindi Evaluation (one-time, delete after eval)

@description('Azure region')
param location string

@description('Key Vault name to store API key')
param keyVaultName string

@description('Resource tags')
param tags object

// ─── Speech Service ───────────────────────────────────────────────────────────

resource speech 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: 'salesvoice-speech-eval'
  location: location
  kind: 'SpeechServices'
  tags: union(tags, {
    purpose: 'evaluation-only'
    'delete-after': 'evaluation-complete'
  })
  sku: {
    name: 'S0'
  }
  properties: {
    customSubDomainName: 'salesvoice-speech-eval'
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
    }
  }
}

// ─── Store Key in Key Vault ───────────────────────────────────────────────────

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource speechKeySecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'azure-speech-key'
  properties: {
    value: speech.listKeys().key1
  }
}

// ─── Outputs ──────────────────────────────────────────────────────────────────

output speechEndpoint string = speech.properties.endpoint
output speechRegion string = location
output speechResourceName string = speech.name
