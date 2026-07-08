# tests/11-string.test.sh

# Source helpers, config, and target script
local my_dir="${${(%):-%x}:A:h}"
source "${my_dir}/test_helpers.sh"
source "${my_dir}/../config/config.sh"
source "${my_dir}/../functions/11-string.sh"

init_config

test_str_contains() {
  assert_true "str_contains 'hello world' 'world'" "Should contain world"
  assert_false "str_contains 'hello world' 'globe'" "Should not contain globe"
}

test_str_starts_and_ends_with() {
  assert_true "str_starts_with 'http://google.com' 'http://'" "Should start with http://"
  assert_false "str_starts_with 'google.com' 'http://'" "Should not start with http://"
  assert_true "str_ends_with 'image.png' '.png'" "Should end with .png"
  assert_false "str_ends_with 'image.png' '.jpg'" "Should not end with .jpg"
}

test_str_replace() {
  local res
  res=$(str_replace "abc-abc" "b" "x")
  assert_equals "axc-axc" "${res}" "Should replace all b with x"
  
  res=$(str_replace_first "abc-abc" "b" "x")
  assert_equals "axc-abc" "${res}" "Should replace first b with x"
}

test_str_trim() {
  local res
  res=$(str_trim "  hello  ")
  assert_equals "hello" "${res}" "Should trim leading and trailing spaces"
  
  res=$(str_ltrim "  hello")
  assert_equals "hello" "${res}" "Should trim leading spaces"
  
  res=$(str_rtrim "hello  ")
  assert_equals "hello" "${res}" "Should trim trailing spaces"
}

test_str_split_and_join() {
  local split
  split=$(str_split "a,b,c" ",")
  assert_equals $'a\nb\nc' "${split}" "Should split on comma"
  
  local joined
  joined=$(str_join "-" "a" "b" "c")
  assert_equals "a-b-c" "${joined}" "Should join with dash"
}

test_str_case() {
  local res
  res=$(str_to_lower "HeLLo")
  assert_equals "hello" "${res}" "Should lowercase"
  
  res=$(str_to_upper "HeLLo")
  assert_equals "HELLO" "${res}" "Should uppercase"
  
  res=$(str_capitalize "hello world")
  assert_equals "Hello World" "${res}" "Should capitalize words"
}

test_str_reverse_and_length() {
  local res
  res=$(str_reverse "hello")
  assert_equals "olleh" "${res}" "Should reverse string"
  
  local len
  len=$(str_length "hello")
  assert_equals "5" "${len}" "Length should be 5"
}

test_str_substring() {
  local res
  res=$(str_substring "hello" 1 3)
  assert_equals "ell" "${res}" "Substring 1 to 3 should be ell"
}

test_str_padding() {
  local res
  res=$(str_pad_left "42" 5 "0")
  assert_equals "00042" "${res}" "Left pad should result in 00042"
  
  res=$(str_pad_right "42" 5 "x")
  assert_equals "42xxx" "${res}" "Right pad should result in 42xxx"
}

test_str_escape_unescape() {
  local esc
  esc=$(str_escape "a b'c")
  local unesc
  unesc=$(str_unescape "${esc}")
  assert_equals "a b'c" "${unesc}" "Unescaping escaped string should match original"
}

test_str_slugify() {
  local res
  res=$(str_slugify "Hello, World! 2026")
  assert_equals "hello-world-2026" "${res}" "Slugify should make lowercase and remove symbols"
}

test_str_random_and_uuid() {
  local rnd
  rnd=$(str_random 10)
  assert_equals "10" "${#rnd}" "Random string should be 10 characters long"
  
  local id
  id=$(str_uuid)
  assert_equals "36" "${#id}" "UUID should be 36 characters long"
  assert_true "[[ \"${id}\" =~ ^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$ ]]" "Should match UUID pattern"
}

run_test test_str_contains
run_test test_str_starts_and_ends_with
run_test test_str_replace
run_test test_str_trim
run_test test_str_split_and_join
run_test test_str_case
run_test test_str_reverse_and_length
run_test test_str_substring
run_test test_str_padding
run_test test_str_escape_unescape
run_test test_str_slugify
run_test test_str_random_and_uuid

exit $(( TESTS_FAILED > 0 ? 1 : 0 ))
