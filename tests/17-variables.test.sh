# tests/17-variables.test.sh

# Source helpers, config, and target script
local my_dir="${${(%):-%x}:A:h}"
source "${my_dir}/test_helpers.sh"
source "${my_dir}/../config/config.sh"
source "${my_dir}/../functions/15-variables.sh"

init_config

test_config_var_get_set_unset() {
  # Set a custom variable
  assert_true "config_set_var TEST_VAR 'hello_world'" "Setting TEST_VAR should succeed"
  
  # Get it
  local val
  val=$(config_get_var TEST_VAR)
  assert_equals "hello_world" "${val}" "TEST_VAR should be hello_world"
  
  # Get with fallback default
  val=$(config_get_var NON_EXISTENT_VAR "default_val")
  assert_equals "default_val" "${val}" "NON_EXISTENT_VAR should fallback to default"
  
  # Unset it
  assert_true "config_unset_var TEST_VAR" "Unsetting TEST_VAR should succeed"
  val=$(config_get_var TEST_VAR "unset_default")
  assert_equals "unset_default" "${val}" "TEST_VAR should be unset and return fallback"
}

test_repo_location_get_set_unset() {
  # Get location of service1 from config
  local val
  val=$(config_get_repo_location "service1")
  assert_equals "/home/xxxx/hello/world/code" "${val}" "service1 location should match config"
  
  # Set a new repo location
  assert_true "config_set_repo_location 'test_service' '/path/to/test_service'" "Setting test_service location should succeed"
  val=$(config_get_repo_location "test_service")
  assert_equals "/path/to/test_service" "${val}" "test_service location should match assigned value"
  
  # Check that it is added to REPO_NAMES
  assert_true "[[ \${REPO_NAMES[(Ie)test_service]} -ne 0 ]]" "test_service should be present in REPO_NAMES array"
  
  # Unset/remove it
  assert_true "config_unset_repo_location 'test_service'" "Unsetting test_service should succeed"
  val=$(config_get_repo_location "test_service")
  assert_equals "" "${val}" "test_service location should now be empty"
  assert_true "[[ \${REPO_NAMES[(Ie)test_service]} -eq 0 ]]" "test_service should be removed from REPO_NAMES array"
}

test_list_repos() {
  local out
  out=$(config_list_repos)
  assert_true "[[ \"${out}\" == *\"service1: /home/xxxx/hello/world/code\"* ]]" "config_list_repos should output service1 location"
}

run_test test_config_var_get_set_unset
run_test test_repo_location_get_set_unset
run_test test_list_repos

exit $(( TESTS_FAILED > 0 ? 1 : 0 ))
