#!/usr/bin/env zsh
# scripts/03-vault/postRotate.sh
# Renews/rotates Vault client token or secrets via framework functions.

# Resolve PROJECT_ROOT if not set
if [[ -z "${PROJECT_ROOT:-}" ]]; then
  export PROJECT_ROOT="${0:A:h:h:h}"
fi

# Source framework config and functions
source "${PROJECT_ROOT}/config/config.sh"
init_config

VAULT_ADDR="${1:-}"
TOKEN="${2:-}"
ROTATE_PATH="${3:-auth/token/renew-self}"

validate_required "${VAULT_ADDR}" "VAULT_ADDR parameter is required" || error_exit "Missing VAULT_ADDR"
validate_required "${TOKEN}" "TOKEN parameter is required" || error_exit "Missing TOKEN"

# Remove leading slash if present in ROTATE_PATH
rotate_path="${ROTATE_PATH#/}"

# Construct endpoint URL
if [[ "${rotate_path}" == v1/* ]]; then
  endpoint="${VAULT_ADDR}/${rotate_path}"
else
  endpoint="${VAULT_ADDR}/v1/${rotate_path}"
fi

headers="X-Vault-Token: ${TOKEN}
Content-Type: application/json"

# Call the rotate/renewal endpoint
res=$(http_post "${endpoint}" "{}" "${headers}")
http_status=$(check_status_code "${res}")
body=$(http_get_body "${res}")

# Check HTTP status code
if [[ "${http_status}" -ne 200 ]]; then
  error_exit "Failed to perform rotation/renewal at ${endpoint} (HTTP Status: ${http_status}). Response: ${body}"
fi

# Validate response is valid JSON
validate_json "${body}" || error_exit "Response is not valid JSON"

echo "${body}"
