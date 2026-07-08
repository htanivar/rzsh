# tests/test_helpers.sh

# Protect against double sourcing
if [[ -n "${_TEST_HELPERS_SH_SOURCED:-}" ]]; then
  return 0
fi
readonly _TEST_HELPERS_SH_SOURCED=1

TESTS_RUN=0
TESTS_FAILED=0
CURRENT_TEST_NAME=""

assert_equals() {
  local expected="$1"
  local actual="$2"
  local msg="${3:-Expected '$expected' to equal '$actual'}"
  if [[ "${expected}" != "${actual}" ]]; then
    printf "\n    \e[31mAssertion failed: %s\e[0m\n" "${msg}" >&2
    printf "      Expected: '%s'\n" "${expected}" >&2
    printf "      Actual:   '%s'\n" "${actual}" >&2
    return 1
  fi
  return 0
}

assert_true() {
  local cmd="$1"
  local msg="${2:-Expected command to succeed}"
  if ! eval "${cmd}"; then
    printf "\n    \e[31mAssertion failed: %s (command: %s)\e[0m\n" "${msg}" "${cmd}" >&2
    return 1
  fi
  return 0
}

assert_false() {
  local cmd="$1"
  local msg="${2:-Expected command to fail}"
  if eval "${cmd}"; then
    printf "\n    \e[31mAssertion failed: %s (command: %s)\e[0m\n" "${msg}" "${cmd}" >&2
    return 1
  fi
  return 0
}

run_test() {
  local t_func="$1"
  CURRENT_TEST_NAME="${t_func}"
  printf "  - Running %s..." "${t_func}"
  (( TESTS_RUN++ ))
  # Run in subshell to prevent test failures/environment pollution from spilling over
  (
    "${t_func}"
  )
  local exit_code=$?
  if (( exit_code == 0 )); then
    printf " \e[32mPASSED\e[0m\n"
  else
    printf " \e[31mFAILED\e[0m\n"
    (( TESTS_FAILED++ ))
  fi
}
