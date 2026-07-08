#!/usr/bin/env zsh
# scripts/03-vault/jwtLogin.sh
# Performs Vault JWT authentication and validates the response structure using framework functions.

# Resolve PROJECT_ROOT if not set
if [[ -z "${PROJECT_ROOT:-}" ]]; then
  export PROJECT_ROOT="${0:A:h:h:h}"
fi

# Source framework config and functions
source "${PROJECT_ROOT}/config/config.sh"
init_config

AUTH_URL="${1:-}"
ROLE_NAME="${2:-}"
JWT="${3:-}"

validate_required "${AUTH_URL}" "AUTH_URL parameter is required" || error_exit "Missing AUTH_URL"
validate_required "${ROLE_NAME}" "ROLE_NAME parameter is required" || error_exit "Missing ROLE_NAME"
validate_required "${JWT}" "JWT parameter is required" || error_exit "Missing JWT"

# Construct the payload dynamically using json_set_value
payload='{}'
payload=$(json_set_value "${payload}" ".jwt" "${JWT}")
payload=$(json_set_value "${payload}" ".role" "${ROLE_NAME}")

headers="Content-Type: application/json"

# Perform POST request
res=$(http_post "${AUTH_URL}" "${payload}" "${headers}")
http_status=$(check_status_code "${res}")
body=$(http_get_body "${res}")

# Check HTTP status code
if [[ "${http_status}" -ne 200 ]]; then
  error_exit "Vault login request failed with status: ${http_status}. Response: ${body}"
fi

# Validate response is valid JSON
validate_json "${body}" || error_exit "Response is not valid JSON"

# Validate Vault client token exists in auth or auth.data
client_token=$(json_get_value "${body}" ".auth.client_token // .auth.data.client_token // empty")

validate_required "${client_token}" "Missing client token in login response" || error_exit "Invalid response structure"

log_info "Validation Success: Valid Vault Login response structure detected."
echo "${body}"
