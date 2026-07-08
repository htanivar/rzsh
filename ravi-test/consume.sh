#!/usr/bin/env zsh
# ravi-test/consume.sh
# Orchestrates steps 1 to 6 for each config URL found in myconfig.txt.
# Automatically starts a mock server if none is running on port 1717.
# Uses framework functions exclusively.

# Resolve PROJECT_ROOT if not set
if [[ -z "${PROJECT_ROOT:-}" ]]; then
  export PROJECT_ROOT="${0:A:h:h}"
fi

# Source framework config and functions
source "${PROJECT_ROOT}/config/config.sh"
init_config

CONFIG_FILE="${1:-ravi-test/myconfig.txt}"
EVIDENCE_FILE="ravi-test/evidence.md"

if ! validate_file_exists "${CONFIG_FILE}"; then
  # Fallback checks
  if validate_file_exists "ravi-test/my config.txt"; then
    CONFIG_FILE="ravi-test/my config.txt"
  elif validate_file_exists "myconfig.txt"; then
    CONFIG_FILE="myconfig.txt"
  else
    error_exit "Configuration file not found at ${CONFIG_FILE}"
  fi
fi

# Ensure scripts have execute permissions using framework utility function
file_set_permissions "${PROJECT_ROOT}/scripts/01-myconfig/getConfig.sh" "755"
file_set_permissions "${PROJECT_ROOT}/scripts/02-ssh/getJwt.sh" "755"
file_set_permissions "${PROJECT_ROOT}/scripts/03-vault/jwtLogin.sh" "755"
file_set_permissions "${PROJECT_ROOT}/scripts/03-vault/getSecret.sh" "755"
file_set_permissions "${PROJECT_ROOT}/scripts/03-vault/postSecret.sh" "755"
file_set_permissions "${PROJECT_ROOT}/scripts/03-vault/postRotate.sh" "755"

log_info "=========================================================="
log_info "Starting test suite orchestration..."
log_info "Config file: ${CONFIG_FILE}"
log_info "Evidence file: ${EVIDENCE_FILE}"
log_info "=========================================================="

# Check if mock server needs to be started
MOCK_SERVER_PID=""
if ! res=$(http_get "http://localhost:1717/" 2>/dev/null) || [[ -z "${res}" ]]; then
  log_info "No service detected on port 1717. Starting mock server..."
  python3 ravi-test/mock_server.py &
  MOCK_SERVER_PID=$!
  sleep 1.5
  log_info "Mock server started in background (PID: ${MOCK_SERVER_PID})"
else
  log_info "Service already running on port 1717. Using existing service."
fi

# Ensure cleanup of mock server on exit
cleanup() {
  if [[ -n "${MOCK_SERVER_PID}" ]]; then
    log_info "Shutting down mock server (PID: ${MOCK_SERVER_PID})..."
    kill "${MOCK_SERVER_PID}" 2>/dev/null || true
  fi
}
trap cleanup EXIT

# Initialize evidence file using file_write
init_header="# Test Execution Evidence

Generated on: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
Configuration Source: \`${CONFIG_FILE}\`

---
"
file_write "${EVIDENCE_FILE}" "${init_header}"

SUCCESS_COUNT=0
TOTAL_COUNT=0

# Read URLs line by line using native Zsh array splitting
local -a urls
urls=( ${(f)"$(cat ${CONFIG_FILE})"} )

for URL in "${urls[@]}"; do
  # Trim whitespace using str_trim
  URL=$(str_trim "${URL}")
  [[ -z "${URL}" ]] && continue
  [[ "${URL}" == "#"* ]] && continue

  TOTAL_COUNT=$((TOTAL_COUNT + 1))
  log_info "Processing URL: ${URL}"

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
  log_info "  1. Fetching config..."
  if CONFIG_PAYLOAD=$("${PROJECT_ROOT}/scripts/01-myconfig/getConfig.sh" "${URL}"); then
    ROLE_NAME=$(json_get_value "${CONFIG_PAYLOAD}" ".ROLE_NAME")
    AUTH_URL=$(json_get_value "${CONFIG_PAYLOAD}" ".AUTH_URL")
  else
    STEP_STATUS="FAILED"
    FAILURE_REASON="Step 1 (getConfig.sh) failed. Check logs."
  fi

  # Step 2: Get JWT Token
  if [[ "${STEP_STATUS}" == "SUCCESS" ]]; then
    log_info "  2. Getting machine identity JWT..."
    if ! JWT=$("${PROJECT_ROOT}/scripts/02-ssh/getJwt.sh" 2>/dev/null); then
      STEP_STATUS="FAILED"
      FAILURE_REASON="Step 2 (getJwt.sh) failed. Check logs."
    fi
  fi

  # Step 3: Vault Login
  if [[ "${STEP_STATUS}" == "SUCCESS" ]]; then
    log_info "  3. Executing Vault JWT login..."
    if LOGIN_RESP=$("${PROJECT_ROOT}/scripts/03-vault/jwtLogin.sh" "${AUTH_URL}" "${ROLE_NAME}" "${JWT}"); then
      CLIENT_TOKEN=$(json_get_value "${LOGIN_RESP}" ".auth.client_token // .auth.data.client_token // empty")
      
      # Extract Vault address from AUTH_URL using str_replace (pre-defined function)
      VAULT_ADDR=$(str_replace "${AUTH_URL}" "/v1/auth/jwt/login" "")
      VAULT_ADDR=$(str_replace "${VAULT_ADDR}" "/auth/jwt/login" "")
    else
      STEP_STATUS="FAILED"
      FAILURE_REASON="Step 3/4/5 (jwtLogin.sh) failed. Check logs."
    fi
  fi

  # Step 6: Vault Secret Actions (GET, POST, POST Rotate)
  if [[ "${STEP_STATUS}" == "SUCCESS" ]]; then
    SECRET_PATH="secret/data/${ROLE_NAME}"

    log_info "  6a. Issuing GET call for secret..."
    if ! GET_SECRET_RESP=$("${PROJECT_ROOT}/scripts/03-vault/getSecret.sh" "${VAULT_ADDR}" "${CLIENT_TOKEN}" "${SECRET_PATH}"); then
      STEP_STATUS="FAILED"
      FAILURE_REASON="Step 6a (getSecret.sh) failed. Check logs."
    fi
  fi

  if [[ "${STEP_STATUS}" == "SUCCESS" ]]; then
    log_info "  6b. Issuing POST call to create/update secret..."
    local post_payload='{}'
    post_payload=$(json_set_value "${post_payload}" ".data.role_assigned" "${ROLE_NAME}")
    post_payload=$(json_set_value "${post_payload}" ".data.updated_by" "test-script")

    if ! POST_SECRET_RESP=$("${PROJECT_ROOT}/scripts/03-vault/postSecret.sh" "${VAULT_ADDR}" "${CLIENT_TOKEN}" "${SECRET_PATH}" "${post_payload}"); then
      STEP_STATUS="FAILED"
      FAILURE_REASON="Step 6b (postSecret.sh) failed. Check logs."
    fi
  fi

  if [[ "${STEP_STATUS}" == "SUCCESS" ]]; then
    log_info "  6c. Issuing POST call to rotate token..."
    if ! ROTATE_RESP=$("${PROJECT_ROOT}/scripts/03-vault/postRotate.sh" "${VAULT_ADDR}" "${CLIENT_TOKEN}"); then
      STEP_STATUS="FAILED"
      FAILURE_REASON="Step 6c (postRotate.sh) failed. Check logs."
    fi
  fi

  # Mask sensitive information using pre-defined string functions
  masked_jwt="[REDACTED]"
  if [[ -n "${JWT}" ]]; then
    len=$(str_length "${JWT}")
    if (( len > 25 )); then
      first=$(str_substring "${JWT}" 0 10)
      last=$(str_substring "${JWT}" $(( len - 10 )) 10)
      masked_jwt="${first}...[REDACTED]...${last}"
    fi
  fi

  masked_token="[REDACTED]"
  if [[ -n "${CLIENT_TOKEN}" ]]; then
    len=$(str_length "${CLIENT_TOKEN}")
    if (( len > 15 )); then
      first=$(str_substring "${CLIENT_TOKEN}" 0 8)
      last=$(str_substring "${CLIENT_TOKEN}" $(( len - 4 )) 4)
      masked_token="${first}...[REDACTED]...${last}"
    fi
  fi

  # Build evidence output for this iteration
  evidence_block="## Configuration ${TOTAL_COUNT}: \`${URL}\`

* **Status:** ${STEP_STATUS}
$( [[ "${STEP_STATUS}" == "FAILED" ]] && echo "* **Reason:** ${FAILURE_REASON}" )
* **Role Name:** \`${ROLE_NAME}\`
* **Vault Address:** \`${VAULT_ADDR}\`

### Step 1: Retrieve Configuration JSON
- **Command:** \`scripts/01-myconfig/getConfig.sh \"${URL}\"\`
- **Output:**
\`\`\`json
$(json_beautify "${CONFIG_PAYLOAD}" 2>/dev/null || echo "${CONFIG_PAYLOAD}")
\`\`\`

### Step 2: Retrieve Machine Identity JWT
- **Command:** \`scripts/02-ssh/getJwt.sh\`
- **Output:**
\`\`\`
${masked_jwt}
\`\`\`

### Step 3, 4 & 5: Vault Authentication & Validation
- **Command:** \`scripts/03-vault/jwtLogin.sh \"${AUTH_URL}\" \"${ROLE_NAME}\" \"[JWT_TOKEN]\"\`
- **Extracted Vault Client Token:** \`${masked_token}\`
- **Response Payload:**
\`\`\`json
$(json_beautify "${LOGIN_RESP}" 2>/dev/null || echo "${LOGIN_RESP}")
\`\`\`

### Step 6: Vault CRUD Operations
#### GET Secret
- **Command:** \`scripts/03-vault/getSecret.sh \"${VAULT_ADDR}\" \"[TOKEN]\" \"${SECRET_PATH}\"\`
- **Response:**
\`\`\`json
$(json_beautify "${GET_SECRET_RESP}" 2>/dev/null || echo "${GET_SECRET_RESP}")
\`\`\`

#### POST Secret
- **Command:** \`scripts/03-vault/postSecret.sh \"${VAULT_ADDR}\" \"[TOKEN]\" \"${SECRET_PATH}\" \"[PAYLOAD]\"\`
- **Response:**
\`\`\`json
$(json_beautify "${POST_SECRET_RESP}" 2>/dev/null || echo "${POST_SECRET_RESP}")
\`\`\`

#### POST Rotate
- **Command:** \`scripts/03-vault/postRotate.sh \"${VAULT_ADDR}\" \"[TOKEN]\"\`
- **Response:**
\`\`\`json
$(json_beautify "${ROTATE_RESP}" 2>/dev/null || echo "${ROTATE_RESP}")
\`\`\`

---
"
  # Write evidence block using file_append
  file_append "${EVIDENCE_FILE}" "${evidence_block}"

  if [[ "${STEP_STATUS}" == "SUCCESS" ]]; then
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    log_info "[Config ${TOTAL_COUNT}] SUCCESS"
  else
    log_info "[Config ${TOTAL_COUNT}] FAILED"
  fi
done

log_info "=========================================================="
log_info "Test suite finished."
log_info "Successfully completed: ${SUCCESS_COUNT} / ${TOTAL_COUNT}"
log_info "Evidence log has been saved to: ${EVIDENCE_FILE}"
log_info "=========================================================="

if [[ "${SUCCESS_COUNT}" -eq "${TOTAL_COUNT}" ]]; then
  exit 0
else
  exit 1
fi
