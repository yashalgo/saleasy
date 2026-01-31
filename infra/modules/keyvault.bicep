// Azure Key Vault for secrets management

@description('Azure region')
param location string

@description('Resource tags')
param tags object

// ─── Key Vault ────────────────────────────────────────────────────────────────

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: 'salesvoice-vault'
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: false
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    accessPolicies: [] // Access policies added separately via keyvault-access module
  }
}

// ─── Placeholder Secrets (to be updated with real values) ─────────────────────
// These create the secret entries so Key Vault references in Function App don't
// fail on first deploy. Partner/Yash should update values after deployment.

var placeholderSecrets = [
  'groq-api-key'
  'supabase-url'
  'supabase-service-key'
  'r2-endpoint'
  'r2-access-key-id'
  'r2-secret-access-key'
]

resource secrets 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = [
  for secretName in placeholderSecrets: {
    parent: keyVault
    name: secretName
    properties: {
      value: 'PLACEHOLDER-UPDATE-ME'
    }
  }
]

// ─── Outputs ──────────────────────────────────────────────────────────────────

output keyVaultName string = keyVault.name
output keyVaultUri string = keyVault.properties.vaultUri
