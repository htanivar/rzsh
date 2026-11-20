#!/usr/bin/env zsh
# examples/19_cache_example.sh
# Breadcrumb: README.md -> GLOSSARY.md -> docs/19-cache.md -> examples/19_cache_example.sh -> tests/19-cache.test.sh
# Demonstrates organized secrets/token caching under .secrets.d with TTL, JWT auto-expiry, and login deduplication.
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

if [[ -z "${RZSH_DIR:-}" ]]; then
  printf '[WARN] RZSH_DIR is not set. Please set export RZSH_DIR="%s" in your environment (e.g., ~/.zshrc).\n' "${0:A:h:h}" >&2
  export RZSH_DIR="${0:A:h:h}"
fi

source "${RZSH_DIR}/config/config.sh"
init_config
init_logging

# Use an isolated temporary .secrets.d directory for this demo
demo_secrets="/tmp/rzsh_secrets_demo_$$"
trap 'rm -rf "${demo_secrets}"' EXIT
cache_init "${demo_secrets}"

log_section "1. Store & Retrieve Secrets by App/Env"
cache_set "payments-api/dev/api_key" "dev-key-12345" 3600
cache_set "payments-api/prod/api_key" "prod-key-99999" 3600
log_info "Dev API key: $(cache_get 'payments-api/dev/api_key')"
log_info "Prod API key TTL: $(cache_ttl 'payments-api/prod/api_key')s"

log_section "2. Auto-Detect JWT Expiry"
now=$(date +%s)
jwt_tok=$(jwt_generate "{\"sub\":\"svc-runner\",\"exp\":$((now + 120))}" "demo-secret")
cache_set "auth-service/staging/jwt" "${jwt_tok}"
log_info "JWT cached with auto-detected TTL: $(cache_ttl 'auth-service/staging/jwt')s"

log_section "3. Avoid Repeated Logins with cache_get_or_set"
login_calls=0
perform_login() {
  local env_name="$1"
  (( login_calls++ ))
  log_info "Performing login request #${login_calls} for ${env_name}..." >&2
  echo "session-token-${env_name}-${login_calls}"
}

tok1=$(cache_get_or_set "orders-api/prod/session" 300 perform_login "prod")
tok2=$(cache_get_or_set "orders-api/prod/session" 300 perform_login "prod")
log_info "First call token:  ${tok1}"
log_info "Second call token: ${tok2} (login_calls=${login_calls})"

log_section "4. List & Clean Up"
cache_list
cache_remove "payments-api/dev/api_key"
cache_clear "orders-api"
log_info "Remaining cached entries:"
cache_list
