#!/usr/bin/env zsh
# tests/07-user-actions.test.sh
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

# Source helpers, config, and target script via RZSH_DIR
my_dir="${${(%):-%x}:A:h}"
if [[ -z "${RZSH_DIR:-}" ]]; then
  printf '[WARN] RZSH_DIR is not set. Please set export RZSH_DIR="%s" in your environment (e.g., ~/.zshrc).\n' "${my_dir:h}" >&2
  export RZSH_DIR="${my_dir:h}"
fi
source "${RZSH_DIR}/tests/test_helpers.sh"
source "${RZSH_DIR}/config/config.sh"
source "${RZSH_DIR}/functions/07-user-actions.sh"

init_config

test_read_input() {
  local res
  res=$(read_input "Enter name" "Guest" <<< "")
  assert_equals "Guest" "${res}" "Empty input should return default Guest"
  
  res=$(read_input "Enter name" "Guest" <<< "Alice")
  assert_equals "Alice" "${res}" "Alice input should return Alice"
}

test_read_password() {
  local res
  res=$(read_password "Password" <<< "secret123")
  assert_equals "secret123" "${res}" "Password read should match input"
}

test_confirm() {
  assert_true "confirm 'Yes?' 'y' <<< ''" "Default y should return 0"
  assert_false "confirm 'No?' 'n' <<< ''" "Default n should return 1"
  assert_true "confirm 'Yes?' 'n' <<< 'y'" "Input y should return 0"
  assert_false "confirm 'No?' 'y' <<< 'n'" "Input n should return 1"
}

test_select_option() {
  local res
  res=$(select_option "Pick fruit" "apple banana orange" <<< "2")
  assert_equals "banana" "${res}" "Selecting index 2 should return banana"
}

test_wait_for_enter() {
  assert_true "wait_for_enter <<< ''" "Should succeed immediately when enter is pressed"
}

test_read_with_validation() {
  # Validation function helper
  is_numeric() {
    [[ "$1" =~ ^[0-9]+$ ]]
  }

  local res
  res=$(read_with_validation "Enter number" "is_numeric" <<< $'abc\n42')
  assert_equals "42" "${res}" "Should prompt again until 42 is inputted"
}

run_test test_read_input
run_test test_read_password
run_test test_confirm
run_test test_select_option
run_test test_wait_for_enter
run_test test_read_with_validation

exit $(( TESTS_FAILED > 0 ? 1 : 0 ))
