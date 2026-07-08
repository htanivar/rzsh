#!/usr/bin/env zsh
# scripts/03-vault/postSecret.sh
# Writes or updates a secret in Vault using the Vault client token via framework functions.

# Resolve PROJECT_ROOT if not set
if [[ -z "${PROJECT_ROOT:-}" ]]; then
  export PROJECT_ROOT="${0:A:h:h:h}"
fi

# Source framework config and functions
source "${PROJECT_ROOT}/config/config.sh"
init_config

VAULT_ADDR="${1:-}"
TOKEN="${2:-}"
SECRET_PATH="${3:-secret/data/myconfig}"
PAYLOAD="${4:-}"

validate_required "${VAULT_ADDR}" "VAULT_ADDR parameter is required" || error_exit "Missing VAULT_ADDR"
validate_required "${TOKEN}" "TOKEN parameter is required" || error_exit "Missing TOKEN"

# Default payload if not provided (KV v2 requires a "data" wrapper)
if [[ -z "${PAYLOAD}" ]]; then
  local data_obj='{}'
  data_obj=$(json_set_value "${data_obj}" ".test_key" "test_value")
  
  local now_ts
  now_ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  data_obj=$(json_set_value "${data_obj}" ".updated_at" "${now_ts}")
  
  PAYLOAD='{}'
  PAYLOAD=$(json_set_value "${PAYLOAD}" ".data" "${data_obj}")
fi

# Remove leading slash if present in SECRET_PATH
secret_path="${SECRET_PATH#/}"

# Construct endpoint URL
if [[ "${secret_path}" == v1/* ]]; then
  endpoint="${VAULT_ADDR}/${secret_path}"
else
  endpoint="${VAULT_ADDR}/v1/${secret_path}"
fi

headers="X-Vault-Token: ${TOKEN}
Content-Type: application/json"

# Write the secret
res=$(http_post "${endpoint}" "${PAYLOAD}" "${headers}")
http_status=$(check_status_code "${res}")
body=$(http_get_body "${res}")

# Check HTTP status code
if [[ "${http_status}" -ne 200 ]]; then
  error_exit "Failed to write secret to ${endpoint} (HTTP Status: ${http_status}). Response: ${body}"
fi

# Validate response is valid JSON
validate_json "${body}" || error_exit "Response is not valid JSON"

echo "${body}"
