#!/usr/bin/env zsh
# tests/16-mask.test.sh
# Breadcrumb: README.md -> GLOSSARY.md -> docs/16-mask.md -> examples/16_mask_example.sh -> tests/16-mask.test.sh
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

my_dir="${${(%):-%x}:A:h}"
if [[ -z "${RZSH_DIR:-}" ]]; then
  printf '[WARN] RZSH_DIR is not set. Please set export RZSH_DIR="%s" in your environment (e.g., ~/.zshrc).\n' "${my_dir:h}" >&2
  export RZSH_DIR="${my_dir:h}"
fi
source "${RZSH_DIR}/tests/test_helpers.sh"
source "${RZSH_DIR}/config/config.sh"
source "${RZSH_DIR}/functions/16-mask.sh"

init_config

test_mask_string() {
  assert_equals "my***********ue" "$(mask_string "my-secret-value" 2 2)" "Should mask middle characters"
  assert_equals "*****" "$(mask_string "short" 3 3)" "Short string should be fully masked"
  assert_equals "" "$(mask_string "")" "Empty string should return empty"
  assert_equals "ab###fg" "$(mask_string "abcdefg" 2 2 "#")" "Custom mask char should be used"
}

test_mask_token() {
  assert_equals "hvs.************cdef" "$(mask_token "hvs.1234567890abcdef" 4)" "Token should keep 4 chars at each end"
  assert_equals "******" "$(mask_token "abc123" 4)" "Short token should be completely masked"
}

test_mask_email() {
  assert_equals "a**********@example.com" "$(mask_email "alice.smith@example.com")" "Email local part should be masked after first char"
  assert_equals "*@example.com" "$(mask_email "a@example.com")" "Single-char local part should be masked"
}

test_mask_phone_and_card() {
  assert_equals "+*-***-***-4567" "$(mask_phone "+1-555-123-4567" 4)" "Phone should mask all but last 4 digits"
  assert_equals "****-****-****-1234" "$(mask_card "4111-1111-1111-1234" 4)" "Card should mask all but last 4 digits"
}

test_mask_json_fields() {
  if ! command -v jq >/dev/null 2>&1; then
    return 0
  fi
  local input='{"user":"alice","nested":{"token":"xyz"},"password":"secret"}'
  local out
  out=$(mask_json_fields "${input}" "token,password")
  assert_equals '{"user":"alice","nested":{"token":"***MASKED***"},"password":"***MASKED***"}' "${out}" "Sensitive JSON fields should be masked recursively"
}

test_mask_env_line() {
  assert_equals "DB_PASSWORD=***MASKED***" "$(mask_env_line "DB_PASSWORD=secret123")" "Sensitive env var should be masked"
  assert_equals "LOG_LEVEL=INFO" "$(mask_env_line "LOG_LEVEL=INFO")" "Non-sensitive env var should remain unchanged"
  assert_equals "Authorization: ***MASKED***" "$(mask_env_line "Authorization: Bearer my-token")" "Sensitive header line should be masked"
}

run_test test_mask_string
run_test test_mask_token
run_test test_mask_email
run_test test_mask_phone_and_card
run_test test_mask_json_fields
run_test test_mask_env_line

exit $(( TESTS_FAILED > 0 ? 1 : 0 ))
