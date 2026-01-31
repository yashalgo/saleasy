#!/usr/bin/env bash
set -euo pipefail

# SalesVoice Azure Infrastructure Deployment
# Prerequisites: Azure CLI (az) installed and logged in
# Usage: ./deploy.sh [--what-if] [--speech-eval] [--no-staging]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUBSCRIPTION_NAME=""
LOCATION="centralindia"
WHAT_IF=false
DEPLOY_SPEECH=true
DEPLOY_STAGING=true

# ─── Parse arguments ──────────────────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
  case $1 in
    --what-if) WHAT_IF=true; shift ;;
    --no-speech) DEPLOY_SPEECH=false; shift ;;
    --no-staging) DEPLOY_STAGING=false; shift ;;
    --subscription) SUBSCRIPTION_NAME="$2"; shift 2 ;;
    --help)
      echo "Usage: ./deploy.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --what-if        Preview changes without deploying"
      echo "  --no-speech      Skip Azure AI Speech evaluation resource"
      echo "  --no-staging     Skip Function App staging slot"
      echo "  --subscription   Azure subscription name or ID"
      echo ""
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# ─── Pre-flight checks ────────────────────────────────────────────────────────

echo "=== SalesVoice Azure Infrastructure Deployment ==="
echo ""

# Check Azure CLI
if ! command -v az &> /dev/null; then
  echo "ERROR: Azure CLI (az) is not installed."
  echo "Install: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli"
  exit 1
fi

# Check login
if ! az account show &> /dev/null; then
  echo "Not logged in. Running 'az login'..."
  az login
fi

# Set subscription if provided
if [[ -n "$SUBSCRIPTION_NAME" ]]; then
  echo "Setting subscription to: $SUBSCRIPTION_NAME"
  az account set --subscription "$SUBSCRIPTION_NAME"
fi

CURRENT_SUB=$(az account show --query "{name:name, id:id}" -o tsv)
echo "Subscription: $CURRENT_SUB"
echo ""

# ─── Collect email addresses ──────────────────────────────────────────────────

echo "Enter email addresses for alert notifications (comma-separated):"
read -r EMAILS_INPUT
IFS=',' read -ra EMAIL_ARRAY <<< "$EMAILS_INPUT"

# Build JSON array for emails
EMAIL_JSON="["
for i in "${!EMAIL_ARRAY[@]}"; do
  email=$(echo "${EMAIL_ARRAY[$i]}" | xargs) # trim whitespace
  if [[ $i -gt 0 ]]; then EMAIL_JSON+=","; fi
  EMAIL_JSON+="\"$email\""
done
EMAIL_JSON+="]"

echo ""
echo "Configuration:"
echo "  Location:       $LOCATION"
echo "  Speech eval:    $DEPLOY_SPEECH"
echo "  Staging slot:   $DEPLOY_STAGING"
echo "  Alert emails:   $EMAIL_JSON"
echo ""

# ─── Check Azure OpenAI access ────────────────────────────────────────────────

echo "NOTE: Azure OpenAI requires approved access."
echo "If you haven't applied yet, visit: https://aka.ms/oai/access"
echo "The deployment will fail for the OpenAI resource if access is not approved."
echo ""
read -p "Has Azure OpenAI access been approved? (y/n): " OPENAI_APPROVED
if [[ "$OPENAI_APPROVED" != "y" ]]; then
  echo ""
  echo "Apply for access first, then re-run this script."
  echo "The rest of the infrastructure can be deployed without OpenAI."
  echo "To deploy without OpenAI, comment out the 'openai' and 'keyVaultAccess' modules in main.bicep."
  exit 1
fi

# ─── Deploy ────────────────────────────────────────────────────────────────────

DEPLOY_CMD="az deployment sub create \
  --location $LOCATION \
  --template-file $SCRIPT_DIR/main.bicep \
  --parameters \
    location=$LOCATION \
    environment=production \
    alertEmailAddresses=$EMAIL_JSON \
    openaiTpmRateLimit=80 \
    openaiRegion=$LOCATION \
    deploySpeechEval=$DEPLOY_SPEECH \
    deployStagingSlot=$DEPLOY_STAGING \
  --name salesvoice-infra-$(date +%Y%m%d-%H%M%S)"

if $WHAT_IF; then
  echo "=== Running What-If Preview ==="
  $DEPLOY_CMD --what-if
else
  echo "=== Deploying Infrastructure ==="
  $DEPLOY_CMD --verbose

  echo ""
  echo "=== Deployment Complete ==="
  echo ""

  # ─── Print outputs ─────────────────────────────────────────────────────────

  echo "=== Resource Summary ==="
  echo ""

  RG="salesvoice-prod"

  OPENAI_ENDPOINT=$(az cognitiveservices account show \
    --name salesvoice-openai \
    --resource-group $RG \
    --query properties.endpoint -o tsv 2>/dev/null || echo "N/A")

  FUNC_URL=$(az functionapp show \
    --name salesvoice-pipeline \
    --resource-group $RG \
    --query defaultHostName -o tsv 2>/dev/null || echo "N/A")

  INSIGHTS_CONN=$(az monitor app-insights component show \
    --app salesvoice-insights \
    --resource-group $RG \
    --query connectionString -o tsv 2>/dev/null || echo "N/A")

  KV_URI=$(az keyvault show \
    --name salesvoice-vault \
    --resource-group $RG \
    --query properties.vaultUri -o tsv 2>/dev/null || echo "N/A")

  echo "Azure OpenAI Endpoint:    $OPENAI_ENDPOINT"
  echo "Azure OpenAI Deployment:  gpt-4o-mini"
  echo "Azure OpenAI API Version: 2024-10-21"
  echo "Function App URL:         https://$FUNC_URL"
  echo "App Insights Connection:  $INSIGHTS_CONN"
  echo "Key Vault URI:            $KV_URI"
  echo ""
  echo "=== Next Steps ==="
  echo "1. Update Key Vault secrets with real values (Groq, Supabase, R2 keys)"
  echo "   az keyvault secret set --vault-name salesvoice-vault --name groq-api-key --value 'YOUR_KEY'"
  echo "   az keyvault secret set --vault-name salesvoice-vault --name supabase-url --value 'YOUR_URL'"
  echo "   az keyvault secret set --vault-name salesvoice-vault --name supabase-service-key --value 'YOUR_KEY'"
  echo "   az keyvault secret set --vault-name salesvoice-vault --name r2-endpoint --value 'YOUR_ENDPOINT'"
  echo "   az keyvault secret set --vault-name salesvoice-vault --name r2-access-key-id --value 'YOUR_KEY'"
  echo "   az keyvault secret set --vault-name salesvoice-vault --name r2-secret-access-key --value 'YOUR_KEY'"
  echo ""
  echo "2. Test Azure OpenAI: ./test-openai.sh"
  echo "3. Deploy Function App code via CI/CD or 'func azure functionapp publish salesvoice-pipeline'"
  echo "4. After speech eval is done, delete the resource:"
  echo "   az cognitiveservices account delete --name salesvoice-speech-eval --resource-group $RG"
fi
