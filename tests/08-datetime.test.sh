# tests/08-datetime.test.sh

# Source helpers, config, and target script
local my_dir="${${(%):-%x}:A:h}"
source "${my_dir}/test_helpers.sh"
source "${my_dir}/../config/config.sh"
source "${my_dir}/../functions/08-datetime.sh"

init_config

test_timestamp() {
  local ts
  ts=$(timestamp)
  assert_true "[[ \"${ts}\" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}\\ [0-9]{2}:[0-9]{2}:[0-9]{2}$ ]]" "Timestamp should match YYYY-MM-DD HH:MM:SS"
}

test_date_now() {
  local dt
  dt=$(date_now)
  assert_true "[[ \"${dt}\" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]" "date_now should match YYYY-MM-DD"
}

test_parse_date() {
  local ep
  ep=$(parse_date "1970-01-01 00:00:00 UTC")
  assert_equals "0" "${ep}" "Epoch of 1970-01-01 00:00:00 UTC should be 0"
}

test_date_add() {
  local res
  res=$(date_add "2026-07-08 12:00:00" "2 days")
  assert_true "[[ \"${res}\" == \"2026-07-10 12:00:00\" ]]" "Adding 2 days should advance the date to 2026-07-10 12:00:00"
}

test_date_subtract() {
  local res
  res=$(date_subtract "2026-07-08 12:00:00" "1 hour")
  assert_true "[[ \"${res}\" == \"2026-07-08 11:00:00\" ]]" "Subtracting 1 hour should go back to 11:00:00"
}

test_date_diff() {
  local diff
  diff=$(date_diff "2026-07-08 12:00:00" "2026-07-08 12:01:30")
  assert_equals "90" "${diff}" "Difference should be 90 seconds"
}

test_date_format() {
  local res
  res=$(date_format "2026-07-08 00:00:00" "%Y/%m/%d")
  assert_equals "2026/07/08" "${res}" "Custom format should match"
}

test_is_valid_date() {
  assert_true "is_valid_date '2026-07-08'" "Valid date should pass"
  assert_false "is_valid_date 'invalid-date'" "Invalid date should fail"
}

test_date_range() {
  local range
  range=$(date_range "2026-07-01" "2026-07-03" "1 day")
  local expected=$'2026-07-01\n2026-07-02\n2026-07-03'
  assert_equals "${expected}" "${range}" "Range should contain 3 days"
}

test_format_duration() {
  local res
  res=$(format_duration 3665)
  assert_equals "1h 1m 5s" "${res}" "Should format 3665s to 1h 1m 5s"
}

run_test test_timestamp
run_test test_date_now
run_test test_parse_date
run_test test_date_add
run_test test_date_subtract
run_test test_date_diff
run_test test_date_format
run_test test_is_valid_date
run_test test_date_range
run_test test_format_duration

exit $(( TESTS_FAILED > 0 ? 1 : 0 ))
