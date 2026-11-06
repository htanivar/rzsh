#!/usr/bin/env zsh
# tests/02-errors.test.sh
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

# Source helpers, config, and target script via RZSH_DIR
my_dir="${${(%):-%x}:A:h}"
if [[ -z "${RZSH_DIR:-}" ]]; then
  printf '[WARN] RZSH_DIR is not set. Please set export RZSH_DIR="%s" in your environment (e.g., ~/.zshrc).\n' "${my_dir:h}" >&2
  export RZSH_DIR="${my_dir:h}"
fi
source "${RZSH_DIR}/tests/test_helpers.sh"
source "${RZSH_DIR}/config/config.sh"
source "${RZSH_DIR}/functions/02-errors.sh"

init_config

test_error_exit_status() {
  # Run error_exit in a subshell (capturing expected error output) and check its exit code
  ( error_exit "test error" 42 >/dev/null 2>&1 )
  local exit_code=$?
  assert_equals 42 "${exit_code}" "error_exit should exit with code 42"
}

test_error_exit_cleanup() {
  local temp_file="${my_dir}/temp_test_cleanup.txt"
  touch "${temp_file}"
  register_temp_file "${temp_file}"
  
  ( error_exit "cleanup test" 1 >/dev/null 2>&1 )
  
  assert_false "[[ -f \"${temp_file}\" ]]" "TEMP_FILES should be deleted after error_exit"
}

test_register_and_cleanup() {
  local temp1="${my_dir}/temp1.txt"
  local temp2="${my_dir}/temp2.txt"
  touch "${temp1}" "${temp2}"
  
  register_temp_file "${temp1}"
  register_temp_file "${temp2}"
  
  # Verify duplicate registration does not double entry
  register_temp_file "${temp1}"
  assert_equals 2 "${#TEMP_FILES}" "Duplicate registration should be ignored"
  
  cleanup_temp_files >/dev/null 2>&1
  
  assert_false "[[ -f \"${temp1}\" ]]" "temp1 should be deleted by cleanup"
  assert_false "[[ -f \"${temp2}\" ]]" "temp2 should be deleted by cleanup"
  assert_equals 0 "${#TEMP_FILES}" "TEMP_FILES array should be cleared"
}

run_test test_error_exit_status
run_test test_error_exit_cleanup
run_test test_register_and_cleanup

exit $(( TESTS_FAILED > 0 ? 1 : 0 ))
