# tests/12-json.test.sh

# Source helpers, config, and target script
local my_dir="${${(%):-%x}:A:h}"
source "${my_dir}/test_helpers.sh"
source "${my_dir}/../config/config.sh"
source "${my_dir}/../functions/12-json.sh"

init_config

local json='{"user":{"id":42,"name":"Alice","roles":["admin","user"]}}'

test_json_parse_and_validate() {
  assert_true "json_validate '${json}'" "Valid JSON should pass validation"
  assert_false "json_validate 'invalid'" "Invalid JSON should fail validation"
}

test_json_get_value() {
  local val
  val=$(json_get_value "${json}" ".user.name")
  assert_equals "Alice" "${val}" "Name should be Alice"
  
  val=$(json_extract_path "${json}" ".user.id")
  assert_equals "42" "${val}" "ID should be 42"
}

test_json_set_value() {
  local res
  res=$(json_set_value "${json}" ".user.name" "Bob")
  local val
  val=$(json_get_value "${res}" ".user.name")
  assert_equals "Bob" "${val}" "Name should be updated to Bob"
  
  # Set an object value
  res=$(json_set_value "${json}" ".user.meta" '{"active":true}')
  val=$(json_get_value "${res}" ".user.meta.active")
  assert_equals "true" "${val}" "Meta active should be true"
}

test_json_delete_key() {
  local res
  res=$(json_delete_key "${json}" ".user.roles")
  local val
  val=$(json_get_value "${res}" ".user.roles")
  assert_equals "null" "${val}" "Roles should be deleted (null)"
}

test_json_get_keys() {
  local keys
  keys=$(json_get_keys "${json}" ".user")
  assert_true "[[ \"${keys}\" == *\"id\"* && \"${keys}\" == *\"name\"* ]]" "Keys should contain id and name"
}

test_json_merge() {
  local j1='{"a":1,"b":2}'
  local j2='{"b":3,"c":4}'
  local res
  res=$(json_merge "${j1}" "${j2}")
  local b
  b=$(json_get_value "${res}" ".b")
  assert_equals "3" "${b}" "Merge should overwrite values from second object"
}

test_json_to_yaml() {
  local yaml_out
  yaml_out=$(json_to_yaml '{"name":"Alice"}')
  assert_true "[[ \"${yaml_out}\" == *\"name:\"* ]]" "YAML should format properly"
}

test_json_array_add_remove() {
  local arr='{"list":[1,2]}'
  local res
  res=$(json_array_add "${arr}" ".list" "3")
  local val
  val=$(json_get_value "${res}" ".list[2]")
  assert_equals "3" "${val}" "Should add 3 to list"
  
  res=$(json_array_remove "${res}" ".list" 0)
  val=$(json_get_value "${res}" ".list[0]")
  assert_equals "2" "${val}" "Should delete first item, making index 0 equal to 2"
}

test_json_beautify_and_compact() {
  local flat
  flat=$(json_compact $'{\n  "a": 1\n}')
  assert_equals '{"a":1}' "${flat}" "Should compact JSON"
}

run_test test_json_parse_and_validate
run_test test_json_get_value
run_test test_json_set_value
run_test test_json_delete_key
run_test test_json_get_keys
run_test test_json_merge
run_test test_json_to_yaml
run_test test_json_array_add_remove
run_test test_json_beautify_and_compact

exit $(( TESTS_FAILED > 0 ? 1 : 0 ))
