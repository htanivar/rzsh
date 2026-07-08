#!/bin/bash
# scripts/03-vault/getSecret.sh
# Retrieves a secret from Vault using the Vault client token.

set -euo pipefail

VAULT_ADDR="${1:-}"
TOKEN="${2:-}"
SECRET_PATH="${3:-secret/data/myconfig}"

if [ -z "$VAULT_ADDR" ] || [ -z "$TOKEN" ]; then
  echo "Error: VAULT_ADDR and TOKEN parameters are required." >&2
  echo "Usage: $0 <VAULT_ADDR> <TOKEN> [SECRET_PATH]" >&2
  exit 1
fi

# Ensure secret path doesn't have duplicate leading slash
SECRET_PATH=$(echo "$SECRET_PATH" | sed 's|^/||')

# Construct endpoint URL
# If SECRET_PATH already has v1/ prefix, don't duplicate it.
if [[ "$SECRET_PATH" =~ ^v1/ ]]; then
  ENDPOINT="${VAULT_ADDR}/${SECRET_PATH}"
else
  ENDPOINT="${VAULT_ADDR}/v1/${SECRET_PATH}"
fi

# Fetch the secret
RESPONSE=$(curl -s -f -H "X-Vault-Token: $TOKEN" "$ENDPOINT" || true)

if [ -z "$RESPONSE" ]; then
  echo "Error: Failed to fetch secret from $ENDPOINT" >&2
  exit 1
fi

# Validate response JSON
if ! echo "$RESPONSE" | jq -e '.' &>/dev/null; then
  echo "Error: Response is not valid JSON." >&2
  echo "Raw response: $RESPONSE" >&2
  exit 1
fi

echo "$RESPONSE"
