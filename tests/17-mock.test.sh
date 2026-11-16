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

test_mock_command_output_and_exit_code() {
  mock_command "sample_cmd" "mocked output" 42
  local out
  out=$(sample_cmd --flag val)
  local rc=$?

  assert_equals "mocked output" "${out}" "Mock should return configured stdout"
  assert_equals "42" "${rc}" "Mock should return configured exit code"
  assert_equals "1" "$(mock_get_call_count "sample_cmd")" "Call count should be 1"
  assert_equals "--flag val" "$(mock_get_last_args "sample_cmd")" "Last args should be recorded"

  mock_restore "sample_cmd"
}

test_mock_was_called_and_restore_function() {
  _orig_helper_fn() {
    echo "real"
  }

  mock_command "_orig_helper_fn" "stubbed" 0
  assert_equals "stubbed" "$(_orig_helper_fn)" "Mocked function should return stubbed output"
  assert_true "mock_was_called '_orig_helper_fn'" "mock_was_called should succeed when called"
  assert_true "mock_was_called '_orig_helper_fn' 1" "mock_was_called should match exact count 1"
  assert_false "mock_was_called '_orig_helper_fn' 2" "mock_was_called should fail for wrong count"

  mock_restore "_orig_helper_fn"
  assert_equals "real" "$(_orig_helper_fn)" "Original Zsh function should be restored"
  unfunction "_orig_helper_fn" 2>/dev/null || true
}

test_mock_http_response_and_restore_all() {
  mock_http_response '{"status":"ok"}' 201
  local res
  res=$(http_get "https://example.com/status")
  assert_equals "201" "$(check_status_code "${res}")" "mock_http_response should set status code 201"
  assert_equals '{"status":"ok"}' "$(http_get_body "${res}")" "mock_http_response should set body"
  assert_true "mock_was_called 'curl' 1" "curl mock should record 1 call"

  mock_restore_all
  assert_equals "0" "$(mock_get_call_count "curl")" "mock_restore_all should clear call counts"
}

test_mock_command_invalid_name() {
  assert_false "mock_command 'bad name!' 'out' 0" "Invalid command name should return 1"
}

run_test test_mock_command_output_and_exit_code
run_test test_mock_was_called_and_restore_function
run_test test_mock_http_response_and_restore_all
run_test test_mock_command_invalid_name

exit $(( TESTS_FAILED > 0 ? 1 : 0 ))
