#!/usr/bin/env zsh
# tests/16-bootstrap-template.test.sh
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

# Source helpers, config, and target script via RZSH_DIR
my_dir="${${(%):-%x}:A:h}"
if [[ -z "${RZSH_DIR:-}" ]]; then
  printf '[WARN] RZSH_DIR is not set. Please set export RZSH_DIR="%s" in your environment (e.g., ~/.zshrc).\n' "${my_dir:h}" >&2
  export RZSH_DIR="${my_dir:h}"
fi
source "${RZSH_DIR}/tests/test_helpers.sh"
source "${RZSH_DIR}/config/config.sh"

init_config

test_bootstrap_template_execution() {
  # Run the template with mock username and password piped
  output_log=$(printf "mock_admin\nmock_secret_password\n" | zsh "${RZSH_DIR}/scripts/bootstrap_template.sh" 2>&1)
  local exit_code=$?
  
  assert_equals 0 "${exit_code}" "bootstrap_template.sh should exit with code 0"
  
  # Check output highlights
  assert_true "[[ \"${output_log}\" == *\"User: mock_admin\"* ]]" "Output should report captured username"
  assert_true "[[ \"${output_log}\" == *\"Password: ********************\"* ]]" "Output should mask the 20-character password with 20 asterisks"
  assert_true "[[ \"${output_log}\" == *\"Evidence File:\"* ]]" "Output should report evidence file path"
  
  # Extract evidence directory from the output log (stripping ANSI escape sequences)
  local ev_dir
  ev_dir=$(echo "${output_log}" | sed $'s/\x1b\\[[0-9;]*m//g' | grep -oE "Evidence Directory: [^ ]+" | cut -d' ' -f3 | tr -d '\r\n')
  
  assert_true "[[ -n \"${ev_dir}\" ]]" "Evidence directory should be reported in output"
  assert_true "[[ -d \"${ev_dir}\" ]]" "Reported evidence directory should exist on disk"
  
  local ev_file="${ev_dir}/user_credentials_evidence.md"
  assert_true "[[ -f \"${ev_file}\" ]]" "user_credentials_evidence.md file should exist"
  
  # Verify evidence content
  local ev_content
  ev_content=$(cat "${ev_file}")
  assert_true '[[ "${ev_content}" == *"Captured Username:"*"mock_admin"* ]]' "Evidence should contain username"
  assert_true '[[ "${ev_content}" == *"Masked Password:"*"********************"* ]]' "Evidence should contain masked password"
  assert_true '[[ "${ev_content}" == *"Script Location:"* ]]' "Evidence should report script location"
  
  # Cleanup generated evidence folder
  rm -rf "${ev_dir}"
}

run_test test_bootstrap_template_execution

exit $(( TESTS_FAILED > 0 ? 1 : 0 ))
