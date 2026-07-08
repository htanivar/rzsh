# tests/06-http.test.sh

# Source helpers, config, and target script
local my_dir="${${(%):-%x}:A:h}"
source "${my_dir}/test_helpers.sh"
source "${my_dir}/../config/config.sh"
source "${my_dir}/../functions/06-http.sh"

init_config

# Mock curl function to avoid external dependency issues
curl() {
  local arg
  local is_post=0
  local is_put=0
  local is_patch=0
  local is_delete=0
  local url=""
  
  for arg in "$@"; do
    if [[ "${arg}" == "POST" ]]; then
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
  done

  if (( is_post == 1 )); then
    printf '{"success":true,"method":"POST"}\n201'
  elif (( is_put == 1 )); then
    printf '{"success":true,"method":"PUT"}\n200'
  elif (( is_patch == 1 )); then
    printf '{"success":true,"method":"PATCH"}\n200'
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

run_test test_http_get
run_test test_http_post
run_test test_http_put
run_test test_http_patch
run_test test_http_delete
run_test test_http_get_body
run_test test_is_json_response
run_test test_extract_json_field
run_test test_http_get_with_retry

exit $(( TESTS_FAILED > 0 ? 1 : 0 ))
