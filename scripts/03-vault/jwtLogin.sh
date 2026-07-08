#!/bin/bash
# scripts/03-vault/jwtLogin.sh
# Performs Vault JWT authentication and validates the response structure.

set -euo pipefail

AUTH_URL="${1:-}"
ROLE_NAME="${2:-}"
JWT="${3:-}"

if [ -z "$AUTH_URL" ] || [ -z "$ROLE_NAME" ] || [ -z "$JWT" ]; then
  echo "Error: AUTH_URL, ROLE_NAME, and JWT parameters are required." >&2
  echo "Usage: $0 <AUTH_URL> <ROLE_NAME> <JWT>" >&2
  exit 1
fi

# Ensure jq is installed
if ! command -v jq &>/dev/null; then
  echo "Error: jq is required but not installed." >&2
  exit 1
fi

# Construct the payload
PAYLOAD=$(jq -n \
  --arg jwt "$JWT" \
  --arg role "$ROLE_NAME" \
  '{jwt: $jwt, role: $role}')

# Make the POST request to Vault
# Standard Vault login is POST /v1/auth/jwt/login
# Note: we use curl -s -f. If it fails, we capture the status.
RESPONSE=$(curl -s -f -X POST -H "Content-Type: application/json" -d "$PAYLOAD" "$AUTH_URL" || true)

if [ -z "$RESPONSE" ]; then
  echo "Error: Vault login request failed or returned empty response." >&2
  exit 1
fi

# Validate JSON structure
if ! echo "$RESPONSE" | jq -e '.' &>/dev/null; then
  echo "Error: Response is not valid JSON." >&2
  echo "Raw response: $RESPONSE" >&2
  exit 1
fi

# Validate Vault authentication response structure.
# Vault login typically returns an object with a top-level "auth" field containing "client_token".
# The user specifies: validate "auth.data.client_token" or "auth.client_token".
# Let's extract and check both paths.
CLIENT_TOKEN=$(echo "$RESPONSE" | jq -r 'if .auth.data.client_token then .auth.data.client_token elif .auth.client_token then .auth.client_token else empty end')

if [ -z "$CLIENT_TOKEN" ] || [ "$CLIENT_TOKEN" = "null" ]; then
  echo "Error: Login response validation failed. Missing client_token in auth/auth.data." >&2
  echo "Response structure was: $(echo "$RESPONSE" | jq -c '.')" >&2
  exit 1
fi

# If we reached here, the structure is valid!
echo "Validation Success: Valid Vault Login response structure detected." >&2
echo "$RESPONSE"
