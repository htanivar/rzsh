#!/usr/bin/env zsh
# tests/17-mock.test.sh
# Breadcrumb: README.md -> GLOSSARY.md -> docs/17-mock.md -> examples/17_mock_example.sh -> tests/17-mock.test.sh
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

my_dir="${${(%):-%x}:A:h}"
if [[ -z "${RZSH_DIR:-}" ]]; then
  printf '[WARN] RZSH_DIR is not set. Please set export RZSH_DIR="%s" in your environment (e.g., ~/.zshrc).\n' "${my_dir:h}" >&2
  export RZSH_DIR="${my_dir:h}"
fi
source "${RZSH_DIR}/tests/test_helpers.sh"
source "${RZSH_DIR}/config/config.sh"
source "${RZSH_DIR}/functions/17-mock.sh"

init_config

test_mock_primitives() {
  local s
  s=$(mock_string 10 "pre_")
  assert_equals "14" "${#s}" "mock_string should honor prefix + length"
  assert_true '[[ "${s}" =~ ^pre_[A-Za-z]{10}$ ]]' "mock_string should be alphabetic after prefix"

  local alnum
  alnum=$(mock_alphanumeric 20)
  assert_equals "20" "${#alnum}" "mock_alphanumeric should have length 20"
  assert_true '[[ "${alnum}" =~ ^[A-Za-z0-9]{20}$ ]]' "mock_alphanumeric should only contain A-Za-z0-9"

  local pw
  pw=$(mock_password 16 1)
  assert_equals "16" "${#pw}" "mock_password should have length 16"
  assert_true '[[ "${pw}" =~ [A-Z] && "${pw}" =~ [a-z] && "${pw}" =~ [0-9] ]]' "mock_password should contain upper, lower, and digit"

  local num
  num=$(mock_int 10 20)
  assert_true '(( num >= 10 && num <= 20 ))' "mock_int should be within [10, 20]"

  local b
  b=$(mock_bool)
  assert_true '[[ "${b}" == "true" || "${b}" == "false" ]]' "mock_bool should be true or false"
}

test_mock_identifiers_and_secrets() {
  local uid
  uid=$(mock_uuid)
  assert_true '[[ "${uid}" =~ ^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$ ]]' "mock_uuid should match UUID v4 format"

  local mail
  mail=$(mock_email "acme.test")
  assert_true '[[ "${mail}" =~ ^user_[a-z0-9]+@acme\.test$ ]]' "mock_email should use custom domain"

  local ph
  ph=$(mock_phone)
  assert_true '[[ "${ph}" =~ ^[+]1-555-[0-9]{3}-[0-9]{4}$ ]]' "mock_phone should match +1-555-XXX-XXXX"

  local jwt
  jwt=$(mock_jwt "alice" "admin")
  assert_true '[[ "${jwt}" =~ ^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$ ]]' "mock_jwt should have 3 base64url segments"

  local vtok
  vtok=$(mock_vault_token "hvs." 24)
  assert_true '[[ "${vtok}" =~ ^hvs\.[A-Za-z0-9]{24}$ ]]' "mock_vault_token should match hvs.<24 alnum>"
}

test_mock_arrays_and_json() {
  local -a items
  mock_array 4 "items" "int"
  assert_equals "4" "${#items[@]}" "mock_array should generate 4 elements"
  assert_true '[[ "${items[1]}" =~ ^[0-9]+$ ]]' "mock_array int items should be numeric"
  assert_false "mock_array 3 '123-bad' 'string'" "mock_array should reject invalid array names"

  local nested
  nested=$(mock_nested_array 2 3 "int")
  assert_true '[[ "${nested}" =~ ^\[\[[0-9]+,[0-9]+,[0-9]+\],\[[0-9]+,[0-9]+,[0-9]+\]\]$ ]]' "mock_nested_array should produce 2x3 int JSON matrix"

  if command -v jq >/dev/null 2>&1; then
    local j_nested j_user
    j_nested=$(mock_json 2 3)
    assert_true 'jq -e ".nested.field_1 and .matrix" >/dev/null <<< "${j_nested}"' "mock_json depth=2 should produce valid nested JSON"

    j_user=$(mock_json_user)
    assert_true 'jq -e ".id and .username and .email and .token and .meta.created_at" >/dev/null <<< "${j_user}"' "mock_json_user should produce valid user JSON"
  fi
}

test_mock_command_and_http_stubbing() {
  mock_command "sample_cmd" "mocked output" 42
  local out
  out=$(sample_cmd --flag val)
  local rc=$?
  assert_equals "mocked output" "${out}" "Mock should return configured stdout"
  assert_equals "42" "${rc}" "Mock should return configured exit code"
  assert_equals "1" "$(mock_get_call_count "sample_cmd")" "Call count should be 1"
  assert_equals "--flag val" "$(mock_get_last_args "sample_cmd")" "Last args should be recorded"

  mock_http_response '{"status":"ok"}' 201
  local res
  res=$(http_get "https://example.com/status")
  assert_equals "201" "$(check_status_code "${res}")" "mock_http_response should set status code 201"
  assert_true "mock_was_called 'curl' 1" "curl mock should record 1 call"

  mock_restore_all
  assert_equals "0" "$(mock_get_call_count "curl")" "mock_restore_all should clear call counts"
}

run_test test_mock_primitives
run_test test_mock_identifiers_and_secrets
run_test test_mock_arrays_and_json
run_test test_mock_command_and_http_stubbing

exit $(( TESTS_FAILED > 0 ? 1 : 0 ))
