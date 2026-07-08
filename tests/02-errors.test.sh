# tests/02-errors.test.sh

# Source helpers, config, and target script
local my_dir="${${(%):-%x}:A:h}"
source "${my_dir}/test_helpers.sh"
source "${my_dir}/../config/config.sh"
source "${my_dir}/../functions/02-errors.sh"

init_config

test_error_exit_status() {
  # We run error_exit in a subshell and check its exit code
  ( error_exit "test error" 42 )
  local exit_code=$?
  assert_equals 42 "${exit_code}" "error_exit should exit with code 42"
}

test_error_exit_cleanup() {
  local temp_file="${my_dir}/temp_test_cleanup.txt"
  touch "${temp_file}"
  TEMP_FILES+=("${temp_file}")
  
  ( error_exit "cleanup test" 1 )
  
  assert_false "[[ -f \"${temp_file}\" ]]" "TEMP_FILES should be deleted after error_exit"
}

run_test test_error_exit_status
run_test test_error_exit_cleanup

exit $(( TESTS_FAILED > 0 ? 1 : 0 ))
