# tests/01-logs.test.sh

# Source helpers, config, and target script
local my_dir="${${(%):-%x}:A:h}"
source "${my_dir}/test_helpers.sh"
source "${my_dir}/../config/config.sh"
source "${my_dir}/../functions/01-logs.sh"

init_config

# Set up test log dir
export LOG_DIR="${my_dir}/test_logs"
rm -rf "${LOG_DIR}"

test_init_logging() {
  assert_true "init_logging" "init_logging should succeed"
  assert_true "[[ -n \"${CURRENT_LOG_FILE}\" ]]" "CURRENT_LOG_FILE should be set"
  assert_true "[[ -f \"${CURRENT_LOG_FILE}\" ]]" "CURRENT_LOG_FILE should exist"
}

test_log_levels() {
  init_logging
  # Set log level to WARN
  export LOG_LEVEL="WARN"
  
  # Capturing stderr output
  local output
  output=$(log_info "this should not be printed" 2>&1)
  assert_equals "" "${output}" "INFO log should be filtered under WARN level"
  
  output=$(log_warn "this should be printed" 2>&1)
  assert_true "[[ \"\${output}\" == *\"[WARN]\"* ]]" "WARN log should be printed"
  assert_true "[[ \"\${output}\" == *\"this should be printed\"* ]]" "Log should contain message"
}

test_log_steps() {
  init_logging
  log_steps "First Step"
  log_steps "Second Step"
  assert_equals 2 "${LOG_STEPS_COUNT}" "Steps count should be incremented to 2"
}

test_log_command() {
  init_logging
  log_command "echo 'hello test command'"
  local log_content
  log_content=$(cat "${CURRENT_LOG_FILE}")
  assert_true "[[ \"\${log_content}\" == *\"hello test command\"* ]]" "Command output should be logged to file"
}

test_log_section() {
  init_logging
  log_section "My Test Section"
  local log_content
  log_content=$(cat "${CURRENT_LOG_FILE}")
  assert_true "[[ \"\${log_content}\" == *\"My Test Section\"* ]]" "Section header should be logged"
}

run_test test_init_logging
run_test test_log_levels
run_test test_log_steps
run_test test_log_command
run_test test_log_section

# Cleanup
rm -rf "${LOG_DIR}"

# Exit with failure if any test failed
exit $(( TESTS_FAILED > 0 ? 1 : 0 ))
