#!/bin/bash
# scripts/03-vault/postSecret.sh
# Writes or updates a secret in Vault using the Vault client token.

set -euo pipefail

VAULT_ADDR="${1:-}"
TOKEN="${2:-}"
SECRET_PATH="${3:-secret/data/myconfig}"
PAYLOAD="${4:-}"

if [ -z "$VAULT_ADDR" ] || [ -z "$TOKEN" ]; then
  echo "Error: VAULT_ADDR and TOKEN parameters are required." >&2
  echo "Usage: $0 <VAULT_ADDR> <TOKEN> [SECRET_PATH] [PAYLOAD_JSON]" >&2
  exit 1
fi

# Default payload if not provided (KV v2 requires a "data" wrapper)
if [ -z "$PAYLOAD" ]; then
  PAYLOAD='{"data": {"test_key": "test_value", "updated_at": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"}}'
fi

# Ensure secret path doesn't have duplicate leading slash
SECRET_PATH=$(echo "$SECRET_PATH" | sed 's|^/||')

# Construct endpoint URL
if [[ "$SECRET_PATH" =~ ^v1/ ]]; then
  ENDPOINT="${VAULT_ADDR}/${SECRET_PATH}"
else
  ENDPOINT="${VAULT_ADDR}/v1/${SECRET_PATH}"
fi

# Write the secret
RESPONSE=$(curl -s -f -X POST \
  -H "X-Vault-Token: $TOKEN" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  "$ENDPOINT" || true)

if [ -z "$RESPONSE" ]; then
  echo "Error: Failed to write secret to $ENDPOINT" >&2
  exit 1
fi

# Validate response JSON
if ! echo "$RESPONSE" | jq -e '.' &>/dev/null; then
  echo "Error: Response is not valid JSON." >&2
  echo "Raw response: $RESPONSE" >&2
  exit 1
fi

echo "$RESPONSE"
