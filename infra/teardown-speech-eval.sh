#!/usr/bin/env bash
set -euo pipefail

# Delete the Azure AI Speech evaluation resource after evaluation is complete
# This prevents accidental charges from the S0 tier resource

RG="salesvoice-prod"
RESOURCE="salesvoice-speech-eval"

echo "=== Teardown: Azure AI Speech Evaluation Resource ==="
echo "Resource: $RESOURCE"
echo "Resource Group: $RG"
echo ""
echo "WARNING: This will permanently delete the Speech Services resource."
read -p "Are you sure? (yes/no): " CONFIRM

if [[ "$CONFIRM" != "yes" ]]; then
  echo "Aborted."
  exit 0
fi

echo "Deleting $RESOURCE..."
az cognitiveservices account delete \
  --name "$RESOURCE" \
  --resource-group "$RG"

echo "Removing speech key from Key Vault..."
az keyvault secret delete \
  --vault-name salesvoice-vault \
  --name azure-speech-key 2>/dev/null || true

echo ""
echo "Done. Speech evaluation resource has been deleted."
echo "Budget saved: ~$0.36/audio hour (batch) + $1.00/audio hour (real-time)"
