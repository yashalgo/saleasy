#!/usr/bin/env bash
set -euo pipefail

# Test Azure OpenAI deployment with SalesVoice prompts
# Usage: ./test-openai.sh [--endpoint URL] [--key KEY]

RG="salesvoice-prod"

# Get credentials from Azure if not provided
ENDPOINT="${1:-$(az cognitiveservices account show --name salesvoice-openai --resource-group $RG --query properties.endpoint -o tsv)}"
API_KEY="${2:-$(az cognitiveservices account keys list --name salesvoice-openai --resource-group $RG --query key1 -o tsv)}"
DEPLOYMENT="gpt-4o-mini"
API_VERSION="2024-10-21"

URL="${ENDPOINT}openai/deployments/${DEPLOYMENT}/chat/completions?api-version=${API_VERSION}"

echo "=== Azure OpenAI Deployment Test ==="
echo "Endpoint:   $ENDPOINT"
echo "Deployment: $DEPLOYMENT"
echo ""

# ─── Test 1: Basic connectivity ───────────────────────────────────────────────

echo "--- Test 1: Basic Connectivity ---"
RESPONSE=$(curl -s -w "\n%{http_code}\n%{time_total}" "$URL" \
  -H "Content-Type: application/json" \
  -H "api-key: $API_KEY" \
  -d '{
    "messages": [{"role": "user", "content": "Say hello in one word."}],
    "max_tokens": 10
  }')

HTTP_CODE=$(echo "$RESPONSE" | tail -1)
LATENCY=$(echo "$RESPONSE" | tail -2 | head -1)
BODY=$(echo "$RESPONSE" | head -n -2)

if [[ "$HTTP_CODE" == "200" ]]; then
  echo "PASS: HTTP 200, latency ${LATENCY}s"
else
  echo "FAIL: HTTP $HTTP_CODE"
  echo "$BODY"
  exit 1
fi
echo ""

# ─── Test 2: Hindi-English code-switched transcript ───────────────────────────

echo "--- Test 2: Hindi-English Sales Transcript Analysis ---"
START=$(date +%s%N)
RESPONSE=$(curl -s -w "\n%{http_code}" "$URL" \
  -H "Content-Type: application/json" \
  -H "api-key: $API_KEY" \
  -d '{
    "messages": [
      {"role": "system", "content": "You are a sales call analysis engine. Given a transcript of a sales conversation (may contain Hindi-English code-switching), extract the following in JSON format:\n\n1. summary: 2-3 sentence summary of the conversation\n2. key_topics: array of topics discussed (max 5)\n3. sentiment: overall sentiment (positive/neutral/negative)\n4. sentiment_confidence: confidence score 0.0-1.0\n5. action_items: array of follow-up actions identified\n6. customer_objections: array of objections raised by the customer\n7. next_steps: what should happen next\n\nRespond ONLY with valid JSON, no markdown."},
      {"role": "user", "content": "Salesperson: Good morning sir, I wanted to discuss our new insurance plan. Customer: Haan, bataiye kya hai plan mein? Salesperson: Sir, ye plan covers health and life both, premium is just 500 rupees per month. Customer: Thoda zyada hai, koi discount milega? Salesperson: Sir, if you take annual plan, 2 months free milenge. Customer: Okay, sochta hoon, kal batata hoon. Salesperson: Sure sir, main kal call karunga. Aapko brochure WhatsApp pe bhej deta hoon."}
    ],
    "temperature": 0.2,
    "max_tokens": 800,
    "response_format": {"type": "json_object"}
  }')
END=$(date +%s%N)

HTTP_CODE=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | head -n -1)
ELAPSED=$(( (END - START) / 1000000 ))

if [[ "$HTTP_CODE" == "200" ]]; then
  echo "PASS: HTTP 200, latency ${ELAPSED}ms"
  # Extract and display the content
  CONTENT=$(echo "$BODY" | python3 -c "import sys,json; print(json.dumps(json.loads(json.loads(sys.stdin.read())['choices'][0]['message']['content']), indent=2))" 2>/dev/null || echo "$BODY")
  echo "Response:"
  echo "$CONTENT"

  # Extract token usage
  USAGE=$(echo "$BODY" | python3 -c "import sys,json; u=json.loads(sys.stdin.read())['usage']; print(f'Input: {u[\"prompt_tokens\"]}, Output: {u[\"completion_tokens\"]}, Total: {u[\"total_tokens\"]}')" 2>/dev/null || echo "Could not parse usage")
  echo ""
  echo "Token usage: $USAGE"
else
  echo "FAIL: HTTP $HTTP_CODE"
  echo "$BODY"
fi
echo ""

# ─── Test 3: Content filter check ─────────────────────────────────────────────

echo "--- Test 3: Content Filter (aggressive sales language) ---"
RESPONSE=$(curl -s -w "\n%{http_code}" "$URL" \
  -H "Content-Type: application/json" \
  -H "api-key: $API_KEY" \
  -d '{
    "messages": [
      {"role": "system", "content": "Summarize this sales call in 2 sentences."},
      {"role": "user", "content": "Salesperson: Sir, ye last offer hai, kal se price badh jayega. Aapko aaj hi lena hoga nahi to deal khatam. Customer: Aap force mat karo, mujhe time chahiye. Salesperson: Sir main force nahi kar raha, but ye genuine deadline hai. Customer: Theek hai, but mujhe 2 din chahiye. Salesperson: Maximum kal tak, uske baad main kuch nahi kar paunga."}
    ],
    "max_tokens": 200
  }')

HTTP_CODE=$(echo "$RESPONSE" | tail -1)
if [[ "$HTTP_CODE" == "200" ]]; then
  echo "PASS: Aggressive sales language not filtered"
else
  echo "WARNING: HTTP $HTTP_CODE — may need to adjust content filter thresholds"
  echo "$RESPONSE" | head -n -1
fi
echo ""

echo "=== All Tests Complete ==="
