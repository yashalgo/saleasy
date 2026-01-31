# SalesVoice Azure Infrastructure (Bicep IaC)

Automated provisioning of all Azure resources for SalesVoice using Bicep templates.

## What Gets Deployed

| Resource | Name | Purpose |
|----------|------|---------|
| Resource Group | `salesvoice-prod` | Container for all resources |
| Azure OpenAI | `salesvoice-openai` | GPT-4o Mini for call analysis |
| Function App | `salesvoice-pipeline` | Serverless processing pipeline |
| Storage Account | `salesvoicestorage` | Function state + queue storage |
| Queue Storage | 4 queues | Pipeline stage triggers |
| Application Insights | `salesvoice-insights` | Observability & alerting |
| Log Analytics | `salesvoice-logs` | Log aggregation |
| Key Vault | `salesvoice-vault` | Secrets management |
| AI Speech (optional) | `salesvoice-speech-eval` | Hindi transcription evaluation |
| Budgets | 2 budgets | Cost alerts at 10/50/80% + monthly cap |

## Prerequisites

1. **Azure CLI** installed: `brew install azure-cli` (macOS)
2. **Azure OpenAI access approved**: Apply at https://aka.ms/oai/access
3. **Logged in**: `az login`
4. **Subscription with $1000 credits** selected

## Quick Start

```bash
cd infra

# Preview what will be created (no changes made)
./deploy.sh --what-if

# Deploy everything
./deploy.sh

# Deploy without speech evaluation resource
./deploy.sh --no-speech
```

## Post-Deployment Steps

### 1. Update Key Vault Secrets
Yash needs to provide the external service keys:

```bash
./update-secrets.sh
```

Or manually:
```bash
az keyvault secret set --vault-name salesvoice-vault --name groq-api-key --value 'YOUR_KEY'
az keyvault secret set --vault-name salesvoice-vault --name supabase-url --value 'YOUR_URL'
az keyvault secret set --vault-name salesvoice-vault --name supabase-service-key --value 'YOUR_KEY'
az keyvault secret set --vault-name salesvoice-vault --name r2-endpoint --value 'YOUR_ENDPOINT'
az keyvault secret set --vault-name salesvoice-vault --name r2-access-key-id --value 'YOUR_KEY'
az keyvault secret set --vault-name salesvoice-vault --name r2-secret-access-key --value 'YOUR_KEY'
```

### 2. Test Azure OpenAI
```bash
./test-openai.sh
```

### 3. Deploy Function App Code
```bash
func azure functionapp publish salesvoice-pipeline
```

### 4. After Speech Evaluation
```bash
./teardown-speech-eval.sh
```

## File Structure

```
infra/
├── main.bicep              # Orchestrator — deploys all modules
├── main.bicepparam         # Parameter values
├── modules/
│   ├── openai.bicep        # Azure OpenAI + GPT-4o Mini deployment
│   ├── functions.bicep     # Function App + App Service Plan
│   ├── storage.bicep       # Storage Account + Queue Storage
│   ├── monitoring.bicep    # App Insights + Log Analytics + Alerts
│   ├── keyvault.bicep      # Key Vault + placeholder secrets
│   ├── keyvault-access.bicep # Key Vault access policy for Function App
│   ├── speech.bicep        # Azure AI Speech (evaluation only)
│   └── budgets.bicep       # Cost budgets & alerts
├── deploy.sh               # Deployment script
├── test-openai.sh          # OpenAI deployment validation
├── update-secrets.sh       # Interactive secret updater
├── teardown-speech-eval.sh # Delete speech eval resource
└── README.md               # This file
```

## Cost Estimates

| Service | Pre-launch | MVP (1K agents) | Full scale |
|---------|-----------|-----------------|------------|
| Azure OpenAI | $5-10 | $25-35 | $61 |
| Functions + Storage | $0-5 | $10-15 | $15-25 |
| App Insights | $0-2 | $3-5 | $5-10 |
| Key Vault | $0 | ~$1 | ~$1 |
| **Total/month** | **$5-17** | **$39-56** | **$82-97** |

$1000 credits last approximately 10-14 months.

## GPT-4o Mini Region Note

If GPT-4o Mini is not available in `centralindia`, update `openaiRegion` in `main.bicepparam`:
```
param openaiRegion = 'eastus'  // or 'swedencentral'
```
Check availability: https://learn.microsoft.com/en-us/azure/ai-services/openai/concepts/models
