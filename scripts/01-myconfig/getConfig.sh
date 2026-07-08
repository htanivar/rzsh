#!/bin/bash
# scripts/01-myconfig/getConfig.sh
# Retrieves the configuration JSON from the specified URL

set -euo pipefail

URL="${1:-}"

if [ -z "$URL" ]; then
  echo "Error: URL parameter is required." >&2
  echo "Usage: $0 <config_url>" >&2
  exit 1
fi

# Check if jq is installed
if ! command -v jq &>/dev/null; then
  echo "Error: jq is required but not installed." >&2
  exit 1
fi

# Make the HTTP GET call to retrieve the configuration
# If the call fails, exit with error
RESPONSE=$(curl -s -f -L -w "\n%{http_code}" "$URL")
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" -ne 200 ]; then
  echo "Error: Failed to fetch config from $URL (HTTP Status: $HTTP_CODE)" >&2
  exit 1
fi

# Validate response is valid JSON and has required keys (AUTH_URL and ROLE_NAME)
if ! echo "$BODY" | jq -e '.AUTH_URL and .ROLE_NAME' &>/dev/null; then
  echo "Error: Response is not a valid config JSON or missing AUTH_URL/ROLE_NAME. Response: $BODY" >&2
  exit 1
fi

# Output the valid JSON to stdout
echo "$BODY"
