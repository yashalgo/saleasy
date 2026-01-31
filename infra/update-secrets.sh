#!/usr/bin/env bash
set -euo pipefail

# Update Key Vault secrets with real values
# Usage: ./update-secrets.sh

VAULT="salesvoice-vault"

echo "=== Update SalesVoice Key Vault Secrets ==="
echo "Vault: $VAULT"
echo ""
echo "Enter values for each secret. Press Enter to skip (keep current value)."
echo ""

update_secret() {
  local name="$1"
  local desc="$2"
  echo -n "$desc [$name]: "
  read -rs value
  echo ""
  if [[ -n "$value" ]]; then
    az keyvault secret set --vault-name "$VAULT" --name "$name" --value "$value" -o none
    echo "  Updated."
  else
    echo "  Skipped."
  fi
}

update_secret "groq-api-key" "Groq API Key"
update_secret "supabase-url" "Supabase URL"
update_secret "supabase-service-key" "Supabase Service Role Key"
update_secret "r2-endpoint" "Cloudflare R2 Endpoint"
update_secret "r2-access-key-id" "R2 Access Key ID"
update_secret "r2-secret-access-key" "R2 Secret Access Key"

echo ""
echo "=== Done ==="
echo "Restart the Function App to pick up new secrets:"
echo "  az functionapp restart --name salesvoice-pipeline --resource-group salesvoice-prod"
