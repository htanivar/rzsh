#!/usr/bin/env zsh
# tests/06-http.test.sh
# Breadcrumb: README.md -> GLOSSARY.md -> docs/06-http.md -> examples/06_http_example.sh -> tests/06-http.test.sh
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

# Source helpers, config, and target script via RZSH_DIR
my_dir="${${(%):-%x}:A:h}"
if [[ -z "${RZSH_DIR:-}" ]]; then
  printf '[WARN] RZSH_DIR is not set. Please set export RZSH_DIR="%s" in your environment (e.g., ~/.zshrc).\n' "${my_dir:h}" >&2
  export RZSH_DIR="${my_dir:h}"
fi
source "${RZSH_DIR}/tests/test_helpers.sh"
source "${RZSH_DIR}/config/config.sh"
source "${RZSH_DIR}/functions/06-http.sh"

init_config

# Mock curl function to avoid external dependency issues
curl() {
  local arg
  local prev=""
  local is_post=0
  local is_put=0
  local is_patch=0
  local is_delete=0
  local data=""
  local url=""
  
  for arg in "$@"; do
    if [[ "${prev}" == "-d" ]]; then
      data="${arg}"
    elif [[ "${arg}" == "POST" ]]; then
      is_post=1
    elif [[ "${arg}" == "PUT" ]]; then
      is_put=1
    elif [[ "${arg}" == "PATCH" ]]; then
      is_patch=1
    elif [[ "${arg}" == "DELETE" ]]; then
      is_delete=1
    elif [[ "${arg}" =~ ^https?:// ]]; then
      url="${arg}"
    fi
    prev="${arg}"
  done

  if (( is_post == 1 )); then
    printf '{"success":true,"method":"POST","received":%s}\n201' "${data:-null}"
  elif (( is_put == 1 )); then
    printf '{"success":true,"method":"PUT","received":%s}\n200' "${data:-null}"
  elif (( is_patch == 1 )); then
    printf '{"success":true,"method":"PATCH","received":%s}\n200' "${data:-null}"
  elif (( is_delete == 1 )); then
    printf '{"success":true,"method":"DELETE"}\n204'
  elif [[ "${url}" == *"retry"* ]]; then
    # Mock retry count simulation using a temporary file
    local state_file="${PROJECT_ROOT}/logs/mock_retry_state"
    if [[ ! -f "${state_file}" ]]; then
      touch "${state_file}"
      printf '{"error":"temporary"}\n500'
    else
      rm -f "${state_file}"
      printf '{"success":true}\n200'
    fi
  else
    printf '{"success":true,"method":"GET"}\n200'
  fi
}

test_http_get() {
  local res
  res=$(http_get "https://example.com/get")
  local code
  code=$(check_status_code "${res}")
  assert_equals "200" "${code}" "GET request status should be 200"
}

test_http_post() {
  local res
  res=$(http_post "https://example.com/post" '{"data":"test"}')
  local code
  code=$(check_status_code "${res}")
  assert_equals "201" "${code}" "POST request status should be 201"
}

test_http_put() {
  local res
  res=$(http_put "https://example.com/put" '{"data":"test"}')
  local code
  code=$(check_status_code "${res}")
  assert_equals "200" "${code}" "PUT request status should be 200"
}

test_http_patch() {
  local res
  res=$(http_patch "https://example.com/patch" '{"data":"test"}')
  local code
  code=$(check_status_code "${res}")
  assert_equals "200" "${code}" "PATCH request status should be 200"
}

test_http_delete() {
  local res
  res=$(http_delete "https://example.com/delete")
  local code
  code=$(check_status_code "${res}")
  assert_equals "204" "${code}" "DELETE request status should be 204"
}

test_is_json_response() {
  local res
  res=$(http_get "https://example.com/get")
  assert_true "is_json_response '${res}'" "Mock response should be valid JSON"
}

test_extract_json_field() {
  local json='{"user":{"id":42,"name":"Alice"}}'
  local val
  val=$(extract_json_field "${json}" ".user.name")
  assert_equals "Alice" "${val}" "Should extract name Alice"
}

test_http_get_with_retry() {
  rm -f "${PROJECT_ROOT}/logs/mock_retry_state"
  local res
  res=$(http_get_with_retry "https://example.com/retry" 3)
  local code
  code=$(check_status_code "${res}")
  assert_equals "200" "${code}" "Retry should eventually succeed with 200"
  rm -f "${PROJECT_ROOT}/logs/mock_retry_state"
}

test_http_get_body() {
  local mock_res=$'{"status":"ok"}\n200'
  local body
  body=$(http_get_body "${mock_res}")
  assert_equals '{"status":"ok"}' "${body}" "http_get_body should strip the status code last line"
}

test_http_json_file_payload() {
  local payload_file="${PROJECT_ROOT}/logs/test_payload.json"
  mkdir -p "${PROJECT_ROOT}/logs"
  printf '{"username":"ravi","environment":"production"}' > "${payload_file}"

  # 1. Passing .json file path directly
  local res
  res=$(http_post "https://example.com/post" "${payload_file}" "Content-Type: application/json")
  local body
  body=$(http_get_body "${res}")
  local user
  user=$(extract_json_field "${body}" ".received.username")
  assert_equals "ravi" "${user}" "http_post should read JSON payload from file path"

  # 2. Passing @file.json syntax
  res=$(http_put "https://example.com/put" "@${payload_file}" "Content-Type: application/json")
  body=$(http_get_body "${res}")
  local env_val
  env_val=$(extract_json_field "${body}" ".received.environment")
  assert_equals "production" "${env_val}" "http_put should read JSON payload from @file path"

  rm -f "${payload_file}"
}

test_http_default_headers_config() {
  assert_equals "application/json" "${HTTP_CONTENT_TYPE}" "Default HTTP_CONTENT_TYPE should be application/json"
  assert_equals "application/json" "${HTTP_ACCEPT}" "Default HTTP_ACCEPT should be application/json"
  assert_true '[[ "${HTTP_DEFAULT_HEADERS}" == *"Content-Type: application/json"* ]]' "HTTP_DEFAULT_HEADERS should include Content-Type key and value"
  assert_true '[[ "${HTTP_DEFAULT_HEADERS}" == *"Accept: application/json"* ]]' "HTTP_DEFAULT_HEADERS should include Accept key and value"

  # Test env var overrides for Bearer & Vault headers in a fresh zsh process
  local sub_out
  sub_out=$(
    HTTP_AUTH_TOKEN="test-jwt-123" \
    HTTP_VAULT_TOKEN="hvs.vault-abc" \
    HTTP_VAULT_REQUEST="true" \
    zsh -c "source '${RZSH_DIR}/config/config.sh' && init_config && http_build_headers"
  )
  assert_true '[[ "${sub_out}" == *"Authorization: Bearer test-jwt-123"* ]]' "Should build Authorization Bearer header from HTTP_AUTH_TOKEN"
  assert_true '[[ "${sub_out}" == *"X-Vault-Token: hvs.vault-abc"* ]]' "Should build X-Vault-Token header from HTTP_VAULT_TOKEN"
  assert_true '[[ "${sub_out}" == *"X-Vault-Request: true"* ]]' "Should build X-Vault-Request header from HTTP_VAULT_REQUEST"
}

test_http_header_builder() {
  # Save and restore HTTP_DEFAULT_HEADERS
  local saved_headers="${HTTP_DEFAULT_HEADERS}"

  http_set_default_header "Authorization" "Bearer my-token"
  http_set_default_header "X-Vault-Request" "true"

  local auth_val
  auth_val=$(http_get_default_header "authorization")
  assert_equals "Bearer my-token" "${auth_val}" "http_get_default_header should support case-insensitive lookup"

  local built
  built=$(http_build_headers "content-type: text/plain" "X-Custom: abc")
  assert_true '[[ "${built}" == *"content-type: text/plain"* ]]' "Override header should replace default Content-Type"
  assert_true '[[ "${built}" == *"Accept: application/json"* ]]' "Default Accept header should remain"
  assert_true '[[ "${built}" == *"Authorization: Bearer my-token"* ]]' "Default Authorization header should be included"
  assert_true '[[ "${built}" == *"X-Vault-Request: true"* ]]' "Default X-Vault-Request header should be included"
  assert_true '[[ "${built}" == *"X-Custom: abc"* ]]' "Extra custom header should be included"

  # Ensure original Content-Type was not duplicated
  local ct_count
  ct_count=$(printf '%s\n' "${built}" | grep -ci "^content-type:")
  assert_equals "1" "${ct_count}" "Overridden header should appear only once"

  http_unset_default_header "X-Vault-Request"
  built=$(http_build_headers)
  assert_false '[[ "${built}" == *"X-Vault-Request"* ]]' "http_unset_default_header should remove X-Vault-Request"

  http_clear_default_headers
  built=$(http_build_headers)
  assert_equals "" "${built}" "http_clear_default_headers should clear all default headers"

  HTTP_DEFAULT_HEADERS="${saved_headers}"
}

run_test test_http_get
run_test test_http_post
run_test test_http_put
run_test test_http_patch
run_test test_http_delete
run_test test_http_get_body
run_test test_http_json_file_payload
run_test test_is_json_response
run_test test_extract_json_field
run_test test_http_get_with_retry
run_test test_http_default_headers_config
run_test test_http_header_builder

exit $(( TESTS_FAILED > 0 ? 1 : 0 ))
