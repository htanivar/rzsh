#!/usr/bin/env zsh
# tests/19-cache.test.sh
# Breadcrumb: README.md -> GLOSSARY.md -> docs/19-cache.md -> examples/19_cache_example.sh -> tests/19-cache.test.sh
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

my_dir="${${(%):-%x}:A:h}"
if [[ -z "${RZSH_DIR:-}" ]]; then
  printf '[WARN] RZSH_DIR is not set. Please set export RZSH_DIR="%s" in your environment (e.g., ~/.zshrc).\n' "${my_dir:h}" >&2
  export RZSH_DIR="${my_dir:h}"
fi
source "${RZSH_DIR}/tests/test_helpers.sh"
source "${RZSH_DIR}/config/config.sh"
source "${RZSH_DIR}/functions/13-jwt.sh"
source "${RZSH_DIR}/functions/19-cache.sh"

init_config

_make_secrets_dir() {
  local d="/tmp/rzsh_cache_test_$$"
  mkdir -p "${d}"
  echo "${d}"
}

test_cache_set_get_and_organized_paths() {
  local d=$(_make_secrets_dir)
  cache_init "${d}" >/dev/null

  assert_true "cache_set 'app1/prod/token' 'secret-abc' 300 >/dev/null 2>&1" "Organized key should store"
  local got
  got=$(cache_get "app1/prod/token")
  assert_equals "secret-abc" "${got}" "Retrieved secret should match stored value"
  assert_true "cache_has 'app1/prod/token'" "cache_has should return 0 for valid entry"

  # Verify file exists under organized path and has 600 permissions
  assert_true "[[ -f '${d}/app1/prod/token.json' ]]" "Entry file should exist at organized path"
  local perms
  perms=$(stat -c '%a' "${d}/app1/prod/token.json" 2>/dev/null || stat -f '%Lp' "${d}/app1/prod/token.json")
  assert_equals "600" "${perms}" "Secret file should have 600 permissions"

  # Reject path traversal keys
  assert_false "cache_set '../escape' 'bad' 60 >/dev/null 2>&1" "Path traversal key should be rejected"
  assert_false "cache_set '/abs/key' 'bad' 60 >/dev/null 2>&1" "Absolute key should be rejected"

  rm -rf "${d}"
}

test_cache_ttl_and_expiry() {
  local d=$(_make_secrets_dir)
  cache_init "${d}" >/dev/null

  # Persistent entry (ttl=0)
  cache_set "svc/dev/static" "static-val" 0
  assert_equals "0" "$(cache_ttl 'svc/dev/static')" "Persistent entry should report TTL 0"

  # Positive TTL entry
  cache_set "svc/prod/temp" "temp-val" 120
  local rem
  rem=$(cache_ttl "svc/prod/temp")
  assert_true "(( rem > 0 && rem <= 120 ))" "Remaining TTL should be between 1 and 120"

  # Force expiry by writing an entry with expires_at in the past
  local past=$(( $(date +%s) - 10 ))
  jq -n --arg k "svc/prod/expired" --arg v "old-val" --argjson exp "${past}" \
    '{key: $k, value: $v, created_at: 1000, expires_at: $exp, ttl: 10}' > "${d}/svc/prod/expired.json"

  assert_false "cache_has 'svc/prod/expired'" "Expired entry should fail cache_has"
  assert_false "cache_get 'svc/prod/expired' >/dev/null 2>&1" "Expired entry should fail cache_get"
  assert_true "[[ ! -f '${d}/svc/prod/expired.json' ]]" "Expired entry should be cleaned up on access"

  rm -rf "${d}"
}

test_cache_jwt_auto_expiry() {
  local d=$(_make_secrets_dir)
  cache_init "${d}" >/dev/null
  local now=$(date +%s)

  local valid_jwt
  valid_jwt=$(jwt_generate "{\"sub\":\"u1\",\"exp\":$((now + 300))}" "test-secret")
  cache_set "auth/prod/jwt" "${valid_jwt}"

  local rem
  rem=$(cache_ttl "auth/prod/jwt")
  assert_true "(( rem > 0 && rem <= 300 ))" "JWT exp claim should auto-populate TTL"
  assert_equals "${valid_jwt}" "$(cache_get 'auth/prod/jwt')" "Valid JWT should be retrieved"

  local expired_jwt
  expired_jwt=$(jwt_generate "{\"sub\":\"u1\",\"exp\":$((now - 60))}" "test-secret")
  cache_set "auth/prod/old_jwt" "${expired_jwt}"
  assert_false "cache_get 'auth/prod/old_jwt' >/dev/null 2>&1" "Expired JWT should not be returned"

  rm -rf "${d}"
}

test_cache_remove_clear_and_prune() {
  local d=$(_make_secrets_dir)
  cache_init "${d}" >/dev/null

  cache_set "appA/dev/k1" "v1" 300
  cache_set "appA/prod/k2" "v2" 300
  cache_set "appB/prod/k3" "v3" 300

  # Remove single key
  assert_true "cache_remove 'appA/dev/k1'" "cache_remove should succeed for existing key"
  assert_false "cache_has 'appA/dev/k1'" "Removed key should no longer exist"
  assert_false "cache_remove 'appA/dev/k1'" "Removing missing key should return 1"
  assert_true "[[ ! -d '${d}/appA/dev' ]]" "Empty parent directory should be pruned"

  # Clear prefix
  assert_true "cache_clear 'appA'" "cache_clear prefix should succeed"
  assert_false "cache_has 'appA/prod/k2'" "Cleared prefix key should be gone"
  assert_true "cache_has 'appB/prod/k3'" "Other app key should remain untouched"

  # Prune expired entries
  local past=$(( $(date +%s) - 5 ))
  mkdir -p "${d}/appB/staging"
  jq -n --arg k "appB/staging/exp1" --arg v "vexp" --argjson exp "${past}" \
    '{key: $k, value: $v, created_at: 1000, expires_at: $exp, ttl: 5}' > "${d}/appB/staging/exp1.json"

  local pruned
  pruned=$(cache_prune)
  assert_equals "1" "${pruned}" "cache_prune should report 1 pruned entry"
  assert_true "cache_has 'appB/prod/k3'" "Valid entry should survive prune"

  # Full clear
  assert_true "cache_clear >/dev/null 2>&1" "Full cache_clear should succeed"
  assert_false "cache_has 'appB/prod/k3'" "All entries should be gone after full clear"

  rm -rf "${d}"
}

test_cache_list_hides_values() {
  local d=$(_make_secrets_dir)
  cache_init "${d}" >/dev/null

  cache_set "billing/prod/secret_key" "super-secret-value-xyz" 300
  cache_set "billing/dev/static_key" "another-secret-value" 0

  local listing
  listing=$(cache_list "billing")
  assert_true "[[ '${listing}' == *'billing/prod/secret_key'* ]]" "List should include prod key"
  assert_true "[[ '${listing}' == *'billing/dev/static_key'* ]]" "List should include dev key"
  assert_true "[[ '${listing}' == *'persistent'* ]]" "List should show persistent status"
  assert_false "[[ '${listing}' == *'super-secret-value-xyz'* ]]" "List must never print secret values"

  rm -rf "${d}"
}

test_cache_get_or_set_reduces_logins() {
  local d=$(_make_secrets_dir)
  cache_init "${d}" >/dev/null
  local count_file="${d}/login_count.txt"
  echo "0" > "${count_file}"

  _mock_login() {
    local c=$(<"${count_file}")
    c=$(( c + 1 ))
    echo "${c}" > "${count_file}"
    echo "jwt-token-run-${c}"
  }

  local t1 t2
  t1=$(cache_get_or_set "orders/prod/jwt" 300 _mock_login)
  t2=$(cache_get_or_set "orders/prod/jwt" 300 _mock_login)

  assert_equals "jwt-token-run-1" "${t1}" "First call should invoke login and return token"
  assert_equals "jwt-token-run-1" "${t2}" "Second call should return cached token"
  assert_equals "1" "$(<"${count_file}")" "Login callback should only be called once"

  rm -rf "${d}"
}

run_test test_cache_set_get_and_organized_paths
run_test test_cache_ttl_and_expiry
run_test test_cache_jwt_auto_expiry
run_test test_cache_remove_clear_and_prune
run_test test_cache_list_hides_values
run_test test_cache_get_or_set_reduces_logins

exit $(( TESTS_FAILED > 0 ? 1 : 0 ))
