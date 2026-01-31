# Azure Setup — Partner Instructions

SalesVoice Azure infrastructure is automated via Bicep templates in `/infra`. This document covers the few manual steps you need to do before and after running the deploy script.

**Region:** Central India (Pune) for everything.
**Budget:** $1000 in Azure credits.

---

## Prerequisites

1. **Azure CLI** installed: `brew install azure-cli` (macOS) or [install guide](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
2. **Logged in:** `az login`
3. **Correct subscription** selected (the one with $1000 credits):
   ```bash
   az account list -o table
   az account set --subscription "YOUR_SUBSCRIPTION_NAME"
   ```

---

## Step 1: Request Azure OpenAI Access

This is the only step that takes time (1-2 business days).

1. Go to https://aka.ms/oai/access
2. Fill out the form:
   - **Use case:** "AI-powered sales call analytics platform. GPT-4o Mini generates summaries, extracts topics, sentiment, and action items from transcribed Hindi-English sales conversations. ~5000 calls/day. India-based SaaS."
   - **Models requested:** GPT-4o Mini
   - **Expected usage:** ~10M tokens/day input, ~2M tokens/day output
3. Wait for approval email before proceeding to Step 3.

---

## Step 2: Check GPT-4o Mini Region Availability

Verify GPT-4o Mini is available in `centralindia`:
https://learn.microsoft.com/en-us/azure/ai-services/openai/concepts/models

If **not available** in Central India, edit `infra/main.bicepparam` and change:
```
param openaiRegion = 'eastus'  // or 'swedencentral'
```

---

## Step 3: Add Alert Email Addresses

Edit `infra/main.bicepparam` and add email addresses:
```
param alertEmailAddresses = [
  'your-email@example.com'
  'yash-email@example.com'
]
```

---

## Step 4: Deploy

```bash
cd infra

# Preview what will be created (no changes made)
./deploy.sh --what-if

# Deploy everything
./deploy.sh
```

This single command creates:
- Resource group (`salesvoice-prod`)
- Azure OpenAI + GPT-4o Mini deployment (80K TPM)
- Function App (Node.js 20, Linux, Consumption plan) + staging slot
- Storage Account + 4 pipeline queues
- Application Insights + Log Analytics (90-day retention)
- 4 alert rules (error rate, latency, circuit breaker, stuck orchestrations)
- Key Vault with managed identity access for the Function App
- Azure AI Speech evaluation resource
- Budget alerts ($1000 total at 10/50/80%, $120/month at 90%)
- All resources tagged with `project: salesvoice`

---

## Step 5: Update Key Vault Secrets

Yash will provide the external service keys. Run:

```bash
./update-secrets.sh
```

Or set them individually:
```bash
az keyvault secret set --vault-name salesvoice-vault --name groq-api-key --value 'KEY'
az keyvault secret set --vault-name salesvoice-vault --name supabase-url --value 'URL'
az keyvault secret set --vault-name salesvoice-vault --name supabase-service-key --value 'KEY'
az keyvault secret set --vault-name salesvoice-vault --name r2-endpoint --value 'ENDPOINT'
az keyvault secret set --vault-name salesvoice-vault --name r2-access-key-id --value 'KEY'
az keyvault secret set --vault-name salesvoice-vault --name r2-secret-access-key --value 'KEY'
```

---

## Step 6: Test Azure OpenAI

```bash
./test-openai.sh
```

This runs 3 tests:
1. Basic connectivity
2. Hindi-English code-switched sales transcript analysis (the actual prompt template)
3. Content filter check with aggressive sales language

If content filters block legitimate sales transcripts, go to Azure OpenAI Studio → Content filters → create a custom filter with `High` thresholds. Do not disable filtering entirely.

---

## Step 7: Share Credentials with Yash

The deploy script prints all of these at the end. Share securely (password manager or encrypted channel, **not** email/Slack):

| Credential | How to get it |
|------------|---------------|
| Azure OpenAI Endpoint | Printed by deploy script |
| Azure OpenAI Key | `az keyvault secret show --vault-name salesvoice-vault --name azure-openai-key --query value -o tsv` |
| App Insights Connection String | Printed by deploy script |
| Function App URL | Printed by deploy script |
| Storage Account Connection String | `az storage account show-connection-string --name salesvoicestorage -o tsv` |
| Key Vault URI | Printed by deploy script |

---

## Step 8: Speech Evaluation (Separate Task)

This is a one-time evaluation of Azure Speech vs Groq for Hindi-English transcription. Budget cap: $50.

1. **Collect 100 audio samples** (M4A/AAC, mono, 64kbps) with manually typed ground truth transcripts:
   - 30 Hindi-dominant
   - 20 English-dominant
   - 30 code-switched (50/50)
   - 10 low audio quality
   - 10 short calls (<5 min)

2. **Run batch transcription** using the Speech API key from Key Vault:
   ```bash
   az keyvault secret show --vault-name salesvoice-vault --name azure-speech-key --query value -o tsv
   ```
   Use locale `hi-IN` with language identification candidates `["hi-IN", "en-IN"]`.

3. **Compile a comparison spreadsheet** with columns: Sample ID, Category, Duration, Azure Transcript, Groq Transcript, Ground Truth, Azure WER, Groq WER, Azure Latency, Groq Latency.

4. **Share results with Yash.**

5. **Delete the speech resource** when done:
   ```bash
   ./teardown-speech-eval.sh
   ```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| OpenAI returns 429 (rate limited) | Increase TPM: Azure portal → `salesvoice-openai` → Deployments → `gpt-4o-mini` → Edit |
| OpenAI returns 400 (content filtered) | Azure OpenAI Studio → Content filters → raise thresholds to `High` |
| Function App cold start >10s | Normal for Consumption plan. Switch to Flex Consumption if it becomes a problem |
| App Insights shows no data | Verify `APPLICATIONINSIGHTS_CONNECTION_STRING` in Function App config, restart app |
| Costs higher than expected | Cost Management → filter by resource group `salesvoice-prod`. Most likely cause: longer transcripts = more tokens |
