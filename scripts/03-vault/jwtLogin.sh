#!/usr/bin/env zsh
# scripts/03-vault/jwtLogin.sh
# Performs HashiCorp Vault JWT authentication using (AUTH_URL, ROLE, JWT) and outputs the client_token.
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  cat << 'EOF'
Usage: jwtLogin.sh <AUTH_URL> <ROLE> <JWT>

Arguments:
  AUTH_URL   HashiCorp Vault JWT login endpoint URL (e.g. https://vault.example.com/v1/auth/jwt/login)
  ROLE       Vault JWT auth role name
  JWT        Signed JWT token string

Output:
  Prints the Vault client_token to stdout on success; exits non-zero on failure.
EOF
  exit 0
fi

# Advise if RZSH_DIR is not set, and fallback to local framework directory
if [[ -z "${RZSH_DIR:-}" ]]; then
  printf '[WARN] RZSH_DIR is not set. Please set export RZSH_DIR="%s" in your environment (e.g., ~/.zshrc).\n' "${0:A:h:h:h}" >&2
  export RZSH_DIR="${0:A:h:h:h}"
fi

# Source framework config and functions via RZSH_DIR
source "${RZSH_DIR}/config/config.sh"
init_config

if (( $# != 3 )); then
  error_exit "Usage: jwtLogin.sh <AUTH_URL> <ROLE> <JWT> (expected 3 arguments, got $#)"
fi

AUTH_URL="${1:-}"
ROLE_NAME="${2:-}"
JWT="${3:-}"

validate_required "${AUTH_URL}" "AUTH_URL parameter is required" || error_exit "Missing AUTH_URL"
validate_required "${ROLE_NAME}" "ROLE parameter is required" || error_exit "Missing ROLE"
validate_required "${JWT}" "JWT parameter is required" || error_exit "Missing JWT"

# Construct the Vault JWT login payload
payload='{}'
payload=$(json_set_value "${payload}" ".jwt" "${JWT}")
payload=$(json_set_value "${payload}" ".role" "${ROLE_NAME}")

headers="Content-Type: application/json"

# Perform POST request to Vault
res=$(http_post "${AUTH_URL}" "${payload}" "${headers}")
http_status=$(check_status_code "${res}")
body=$(http_get_body "${res}")

# Check HTTP status code
if [[ ! "${http_status}" =~ ^[0-9]+$ ]] || (( http_status != 200 )); then
  error_exit "Vault login request failed with status: ${http_status}. Response: ${body}"
fi

# Validate response is valid JSON
validate_json "${body}" || error_exit "Response is not valid JSON"

# Extract Vault client token from auth.client_token (or auth.data.client_token)
client_token=$(json_get_value "${body}" ".auth.client_token // .auth.data.client_token // empty")
validate_required "${client_token}" "Missing client token in login response" || error_exit "Invalid response structure"

log_info "Vault JWT login succeeded for role '${ROLE_NAME}'." >&2
echo "${client_token}"
