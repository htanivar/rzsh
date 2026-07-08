#!/bin/bash
# ravi-test/consume.sh
# Orchestrates steps 1 to 6 for each config URL found in myconfig.txt.
# Automatically starts a mock server if none is running on port 1717.

set -euo pipefail

# Ensure scripts have execute permissions
chmod +x scripts/01-myconfig/getConfig.sh
chmod +x scripts/02-ssh/getJwt.sh
chmod +x scripts/03-vault/jwtLogin.sh
chmod +x scripts/03-vault/getSecret.sh
chmod +x scripts/03-vault/postSecret.sh
chmod +x scripts/03-vault/postRotate.sh

# Resolve paths relative to project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

CONFIG_FILE="${1:-ravi-test/myconfig.txt}"
EVIDENCE_FILE="ravi-test/evidence.md"

if [ ! -f "$CONFIG_FILE" ]; then
  # Fallback check for "my config.txt" (with space) or root
  if [ -f "ravi-test/my config.txt" ]; then
    CONFIG_FILE="ravi-test/my config.txt"
  elif [ -f "myconfig.txt" ]; then
    CONFIG_FILE="myconfig.txt"
  else
    echo "Error: Configuration file not found at $CONFIG_FILE" >&2
    exit 1
  fi
fi

echo "=========================================================="
echo "Starting test suite orchestration..."
echo "Config file: $CONFIG_FILE"
echo "Evidence file: $EVIDENCE_FILE"
echo "=========================================================="

# Check if mock server needs to be started
MOCK_SERVER_PID=""
if ! curl -s --connect-timeout 1 http://localhost:1717/ &>/dev/null; then
  echo "No service detected on port 1717. Starting mock server..."
  python3 ravi-test/mock_server.py &
  MOCK_SERVER_PID=$!
  # Allow the server a moment to bind
  sleep 1.5
  echo "Mock server started in background (PID: $MOCK_SERVER_PID)"
else
  echo "Service already running on port 1717. Using existing service."
fi

# Ensure cleanup of mock server on exit
cleanup() {
  if [ -n "$MOCK_SERVER_PID" ]; then
    echo "Shutting down mock server (PID: $MOCK_SERVER_PID)..."
    kill "$MOCK_SERVER_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT

# Initialize evidence file
cat <<EOF > "$EVIDENCE_FILE"
# Test Execution Evidence

Generated on: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
Configuration Source: \`$CONFIG_FILE\`

---
EOF

SUCCESS_COUNT=0
TOTAL_COUNT=0

# Read URLs line by line, ignoring empty lines and comments
while IFS= read -r URL || [ -n "$URL" ]; do
  # Trim whitespace
  URL=$(echo "$URL" | xargs)
  [ -z "$URL" ] && continue
  [[ "$URL" =~ ^# ]] && continue

  TOTAL_COUNT=$((TOTAL_COUNT + 1))
  echo -e "\n[Config $TOTAL_COUNT] Processing URL: $URL"

  # Initialize iteration variables
  CONFIG_PAYLOAD=""
  ROLE_NAME=""
  AUTH_URL=""
  JWT=""
  LOGIN_RESP=""
  CLIENT_TOKEN=""
  VAULT_ADDR=""
  GET_SECRET_RESP=""
  POST_SECRET_RESP=""
  ROTATE_RESP=""
  STEP_STATUS="SUCCESS"
  FAILURE_REASON=""

  # Step 1: Get Config
  echo "  1. Fetching config..."
  if CONFIG_PAYLOAD=$(./scripts/01-myconfig/getConfig.sh "$URL" 2>&1); then
    ROLE_NAME=$(echo "$CONFIG_PAYLOAD" | jq -r '.ROLE_NAME')
    AUTH_URL=$(echo "$CONFIG_PAYLOAD" | jq -r '.AUTH_URL')
  else
    STEP_STATUS="FAILED"
    FAILURE_REASON="Step 1 (getConfig.sh) failed:\n$CONFIG_PAYLOAD"
  fi

  # Step 2: Get JWT Token
  if [ "$STEP_STATUS" = "SUCCESS" ]; then
    echo "  2. Getting machine identity JWT..."
    if ! JWT=$(./scripts/02-ssh/getJwt.sh 2>/dev/null); then
      STEP_STATUS="FAILED"
      FAILURE_REASON="Step 2 (getJwt.sh) failed"
    fi
  fi

  # Step 3: Vault Login
  if [ "$STEP_STATUS" = "SUCCESS" ]; then
    echo "  3. Executing Vault JWT login..."
    if LOGIN_RESP=$(./scripts/03-vault/jwtLogin.sh "$AUTH_URL" "$ROLE_NAME" "$JWT" 2>&1); then
      # Strip out any stderr warnings or messages in LOGIN_RESP if any,
      # but standard jwtLogin.sh prints the full JSON to stdout.
      # Step 4 & 5: Validate response and extract client token
      CLIENT_TOKEN=$(echo "$LOGIN_RESP" | tail -n 1 | jq -r 'if .auth.data.client_token then .auth.data.client_token elif .auth.client_token then .auth.client_token else empty end')
      
      # Extract Vault address from AUTH_URL (strip API path prefix)
      VAULT_ADDR=$(echo "$AUTH_URL" | sed -E 's#/(v1/)?auth/jwt/login.*##')
    else
      STEP_STATUS="FAILED"
      FAILURE_REASON="Step 3/4/5 (jwtLogin.sh) failed:\n$LOGIN_RESP"
    fi
  fi

  # Step 6: Vault Secret Actions (GET, POST, POST Rotate)
  if [ "$STEP_STATUS" = "SUCCESS" ]; then
    SECRET_PATH="secret/data/$ROLE_NAME"

    echo "  6a. Issuing GET call for secret..."
    if ! GET_SECRET_RESP=$(./scripts/03-vault/getSecret.sh "$VAULT_ADDR" "$CLIENT_TOKEN" "$SECRET_PATH" 2>&1); then
      STEP_STATUS="FAILED"
      FAILURE_REASON="Step 6a (getSecret.sh) failed:\n$GET_SECRET_RESP"
    fi
  fi

  if [ "$STEP_STATUS" = "SUCCESS" ]; then
    echo "  6b. Issuing POST call to create/update secret..."
    PAYLOAD=$(jq -n --arg role "$ROLE_NAME" '{data: {role_assigned: $role, updated_by: "test-script"}}')
    if ! POST_SECRET_RESP=$(./scripts/03-vault/postSecret.sh "$VAULT_ADDR" "$CLIENT_TOKEN" "$SECRET_PATH" "$PAYLOAD" 2>&1); then
      STEP_STATUS="FAILED"
      FAILURE_REASON="Step 6b (postSecret.sh) failed:\n$POST_SECRET_RESP"
    fi
  fi

  if [ "$STEP_STATUS" = "SUCCESS" ]; then
    echo "  6c. Issuing POST call to rotate token..."
    if ! ROTATE_RESP=$(./scripts/03-vault/postRotate.sh "$VAULT_ADDR" "$CLIENT_TOKEN" 2>&1); then
      STEP_STATUS="FAILED"
      FAILURE_REASON="Step 6c (postRotate.sh) failed:\n$ROTATE_RESP"
    fi
  fi

  # Mask sensitive information (JWT and client token) in evidence logging
  MASKED_JWT="[REDACTED]"
  if [ -n "$JWT" ] && [ "${#JWT}" -gt 25 ]; then
    MASKED_JWT="${JWT:0:10}...[REDACTED]...${JWT: -10}"
  fi

  MASKED_TOKEN="[REDACTED]"
  if [ -n "$CLIENT_TOKEN" ] && [ "${#CLIENT_TOKEN}" -gt 15 ]; then
    MASKED_TOKEN="${CLIENT_TOKEN:0:8}...[REDACTED]...${CLIENT_TOKEN: -4}"
  fi

  # Build evidence output for this iteration
  cat <<EOF >> "$EVIDENCE_FILE"
## Configuration $TOTAL_COUNT: \`$URL\`

* **Status:** $STEP_STATUS
$( [ "$STEP_STATUS" = "FAILED" ] && echo "* **Reason:** $FAILURE_REASON" )
* **Role Name:** \`$ROLE_NAME\`
* **Vault Address:** \`$VAULT_ADDR\`

### Step 1: Retrieve Configuration JSON
- **Command:** \`scripts/01-myconfig/getConfig.sh "$URL"\`
- **Output:**
\`\`\`json
$(echo "$CONFIG_PAYLOAD" | jq '.' 2>/dev/null || echo "$CONFIG_PAYLOAD")
\`\`\`

### Step 2: Retrieve Machine Identity JWT
- **Command:** \`scripts/02-ssh/getJwt.sh\`
- **Output:**
\`\`\`
$MASKED_JWT
\`\`\`

### Step 3, 4 & 5: Vault Authentication & Validation
- **Command:** \`scripts/03-vault/jwtLogin.sh "$AUTH_URL" "$ROLE_NAME" "[JWT_TOKEN]"\`
- **Extracted Vault Client Token:** \`$MASKED_TOKEN\`
- **Response Payload:**
\`\`\`json
$(echo "$LOGIN_RESP" | jq '.' 2>/dev/null || echo "$LOGIN_RESP")
\`\`\`

### Step 6: Vault CRUD Operations
#### GET Secret
- **Command:** \`scripts/03-vault/getSecret.sh "$VAULT_ADDR" "[TOKEN]" "$SECRET_PATH"\`
- **Response:**
\`\`\`json
$(echo "$GET_SECRET_RESP" | jq '.' 2>/dev/null || echo "$GET_SECRET_RESP")
\`\`\`

#### POST Secret
- **Command:** \`scripts/03-vault/postSecret.sh "$VAULT_ADDR" "[TOKEN]" "$SECRET_PATH" "[PAYLOAD]"\`
- **Response:**
\`\`\`json
$(echo "$POST_SECRET_RESP" | jq '.' 2>/dev/null || echo "$POST_SECRET_RESP")
\`\`\`

#### POST Rotate
- **Command:** \`scripts/03-vault/postRotate.sh "$VAULT_ADDR" "[TOKEN]"\`
- **Response:**
\`\`\`json
$(echo "$ROTATE_RESP" | jq '.' 2>/dev/null || echo "$ROTATE_RESP")
\`\`\`

---
EOF

  if [ "$STEP_STATUS" = "SUCCESS" ]; then
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    echo "[Config $TOTAL_COUNT] SUCCESS"
  else
    echo "[Config $TOTAL_COUNT] FAILED"
  fi

done < "$CONFIG_FILE"

echo -e "\n=========================================================="
echo "Test suite finished."
echo "Successfully completed: $SUCCESS_COUNT / $TOTAL_COUNT"
echo "Evidence log has been saved to: $EVIDENCE_FILE"
echo "=========================================================="

if [ "$SUCCESS_COUNT" -eq "$TOTAL_COUNT" ]; then
  exit 0
else
  exit 1
fi
