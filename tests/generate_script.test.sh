#!/usr/bin/env zsh
# tests/generate_script.test.sh
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

my_dir="${${(%):-%x}:A:h}"
if [[ -z "${RZSH_DIR:-}" ]]; then
  export RZSH_DIR="${my_dir:h}"
fi
source "${RZSH_DIR}/tests/test_helpers.sh"
source "${RZSH_DIR}/config/config.sh"
init_config

test_generate_service_login_script() {
  local tmp_dir="/tmp/rzsh_gen_test_$$"
  mkdir -p "${tmp_dir}"
  local out_file="${tmp_dir}/service-login.sh"

  printf 'service-login\nAutomated service login workflow\n%s\nEND\ny\nselect the server\nssh into the server\nread the password\nprepare the payload\nmake a login request\nobserve the login is successful or not\ngenerate a report for the user\nEND\ny\n' "${tmp_dir}" \
    | zsh "${RZSH_DIR}/scripts/generate_script.sh" >/dev/null 2>&1

  assert_true "[[ -x '${out_file}' ]]" "Generated script should exist and be executable"
  assert_true "zsh -n '${out_file}'" "Generated script should pass zsh -n syntax check"
  assert_true "grep -q 'step_1_select_the_server()' '${out_file}'" "Should generate step 1 function"
  assert_true "grep -q 'select_option' '${out_file}'" "Step 1 should use select_option"
  assert_true "grep -q 'ssh_is_reachable' '${out_file}'" "Step 2 should use ssh_is_reachable"
  assert_true "grep -q 'read_password' '${out_file}'" "Step 3 should use read_password"
  assert_true "grep -q 'validate_json' '${out_file}'" "Step 4 should use validate_json"
  assert_true "grep -q 'http_post' '${out_file}'" "Step 5 should use http_post"
  assert_true "grep -q 'check_status_code' '${out_file}'" "Step 6 should use check_status_code"
  assert_true "grep -q 'generate_evidence_report' '${out_file}'" "Step 7 should use generate_evidence_report"

  rm -rf "${tmp_dir}"
}

test_generate_custom_fallback_and_cancel() {
  local tmp_dir="/tmp/rzsh_gen_cancel_$$"
  mkdir -p "${tmp_dir}"
  local out_file="${tmp_dir}/custom-task.sh"

  # Cancel at confirmation prompt
  printf 'custom-task\nCustom desc\n%s\ndone\nn\nrun custom backup\ndone\nn\n' "${tmp_dir}" \
    | zsh "${RZSH_DIR}/scripts/generate_script.sh" >/dev/null 2>&1
  assert_false "[[ -f '${out_file}' ]]" "Cancelled generation should not create file"

  # Confirm generation with fallback step
  printf 'custom-task\nCustom desc\n%s\ndone\nn\nrun custom backup\ndone\ny\n' "${tmp_dir}" \
    | zsh "${RZSH_DIR}/scripts/generate_script.sh" >/dev/null 2>&1
  assert_true "[[ -x '${out_file}' ]]" "Confirmed generation should create executable script"
  assert_true "zsh -n '${out_file}'" "Fallback script should pass zsh -n"
  assert_true "grep -q 'step_1_run_custom_backup()' '${out_file}'" "Should generate custom step function"
  assert_false "grep -q 'init_evidence' '${out_file}'" "Should omit evidence when user selects no"

  rm -rf "${tmp_dir}"
}

run_test test_generate_service_login_script
run_test test_generate_custom_fallback_and_cancel

exit $(( TESTS_FAILED > 0 ? 1 : 0 ))
