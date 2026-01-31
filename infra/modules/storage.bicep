// Storage Account + Queue Storage for pipeline

@description('Azure region')
param location string

@description('Resource tags')
param tags object

// ─── Storage Account ──────────────────────────────────────────────────────────

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: 'salesvoicestorage'
  location: location
  tags: tags
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
  }
}

// ─── Queue Service ────────────────────────────────────────────────────────────

resource queueService 'Microsoft.Storage/storageAccounts/queueServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
}

// ─── Pipeline Queues ──────────────────────────────────────────────────────────

var queueNames = [
  'call-uploaded'
  'call-transcribed'
  'call-failed'
  'notification-batch'
]

resource queues 'Microsoft.Storage/storageAccounts/queueServices/queues@2023-05-01' = [
  for name in queueNames: {
    parent: queueService
    name: name
  }
]

// ─── Outputs ──────────────────────────────────────────────────────────────────

output storageAccountName string = storageAccount.name
output storageAccountId string = storageAccount.id
