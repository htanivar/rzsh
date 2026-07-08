#!/bin/bash
# scripts/03-vault/postRotate.sh
# Renews/rotates Vault client token or secrets.

set -euo pipefail

VAULT_ADDR="${1:-}"
TOKEN="${2:-}"
ROTATE_PATH="${3:-auth/token/renew-self}"

if [ -z "$VAULT_ADDR" ] || [ -z "$TOKEN" ]; then
  echo "Error: VAULT_ADDR and TOKEN parameters are required." >&2
  echo "Usage: $0 <VAULT_ADDR> <TOKEN> [ROTATE_PATH]" >&2
  exit 1
fi

# Ensure rotate path doesn't have duplicate leading slash
ROTATE_PATH=$(echo "$ROTATE_PATH" | sed 's|^/||')

# Construct endpoint URL
if [[ "$ROTATE_PATH" =~ ^v1/ ]]; then
  ENDPOINT="${VAULT_ADDR}/${ROTATE_PATH}"
else
  ENDPOINT="${VAULT_ADDR}/v1/${ROTATE_PATH}"
fi

# Call the rotate/renewal endpoint
RESPONSE=$(curl -s -f -X POST \
  -H "X-Vault-Token: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{}' \
  "$ENDPOINT" || true)

if [ -z "$RESPONSE" ]; then
  echo "Error: Failed to perform rotation/renewal at $ENDPOINT" >&2
  exit 1
fi

# Validate response JSON
if ! echo "$RESPONSE" | jq -e '.' &>/dev/null; then
  echo "Error: Response is not valid JSON." >&2
  echo "Raw response: $RESPONSE" >&2
  exit 1
fi

echo "$RESPONSE"
