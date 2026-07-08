# tests/04-validation.test.sh

# Source helpers, config, and target script
local my_dir="${${(%):-%x}:A:h}"
source "${my_dir}/test_helpers.sh"
source "${my_dir}/../config/config.sh"
source "${my_dir}/../functions/04-validation.sh"

init_config

test_validate_required() {
  assert_true "validate_required 'hello'" "Non-empty should pass"
  assert_false "validate_required ''" "Empty should fail"
}

test_validate_in_list() {
  assert_true "validate_in_list 'apple' 'apple,banana,orange'" "Should find in list"
  assert_true "validate_in_list 'banana' 'apple banana orange'" "Should find in space-separated list"
  assert_false "validate_in_list 'grapes' 'apple banana orange'" "Should not find grapes"
}

test_validate_file_exists() {
  local f="${PROJECT_ROOT}/config/config.sh"
  assert_true "validate_file_exists '${f}'" "Config file should exist"
  assert_false "validate_file_exists 'non_existent_file'" "Non existent file should fail"
}

test_validate_directory_exists() {
  assert_true "validate_directory_exists '${PROJECT_ROOT}'" "Project root should exist"
  assert_false "validate_directory_exists 'non_existent_dir'" "Non existent dir should fail"
}

test_validate_is_number() {
  assert_true "validate_is_number '123'" "Integer should pass"
  assert_true "validate_is_number '-123.45'" "Float should pass"
  assert_false "validate_is_number 'abc'" "Letters should fail"
}

test_validate_email() {
  assert_true "validate_email 'test@example.com'" "Valid email should pass"
  assert_false "validate_email 'invalid-email'" "Invalid email should fail"
}

test_validate_url() {
  assert_true "validate_url 'https://google.com'" "Valid URL should pass"
  assert_false "validate_url 'google.com'" "Invalid URL should fail"
}

test_validate_command_exists() {
  assert_true "validate_command_exists 'ls'" "ls command should exist"
  assert_false "validate_command_exists 'non_existent_command_123'" "Non existent command should fail"
}

test_validate_date() {
  assert_true "validate_date '2026-07-08'" "Valid date format should pass"
  assert_false "validate_date 'invalid-date'" "Invalid date should fail"
}

test_validate_jwt() {
  assert_true "validate_jwt 'header.payload.signature'" "Valid JWT structure should pass"
  assert_false "validate_jwt 'invalidtoken'" "Invalid JWT structure should fail"
}

test_validate_json() {
  assert_true "validate_json '{\"name\":\"test\"}'" "Valid JSON should pass"
  assert_false "validate_json 'invalid'" "Invalid JSON should fail"
}

run_test test_validate_required
run_test test_validate_in_list
run_test test_validate_file_exists
run_test test_validate_directory_exists
run_test test_validate_is_number
run_test test_validate_email
run_test test_validate_url
run_test test_validate_command_exists
run_test test_validate_date
run_test test_validate_jwt
run_test test_validate_json

exit $(( TESTS_FAILED > 0 ? 1 : 0 ))
