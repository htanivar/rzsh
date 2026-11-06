#!/usr/bin/env zsh
# tests/03-navigation.test.sh
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

# Source helpers, config, and target script
my_dir="${${(%):-%x}:A:h}"
source "${my_dir}/test_helpers.sh"
source "${my_dir}/../config/config.sh"
source "${my_dir}/../functions/03-navigation.sh"

init_config

test_current_directory() {
  local cur
  cur=$(current_directory)
  assert_equals "${PWD}" "${cur}" "current_directory should equal PWD"
}

test_dir_up() {
  local parent
  parent=$(dir_up 1)
  assert_equals "${PWD:h}" "${parent}" "dir_up 1 should equal PWD:h"
}

test_absolute_path() {
  local abs
  abs=$(absolute_path ".")
  assert_equals "${PWD}" "${abs}" "absolute_path of . should be PWD"
}

test_get_project_root() {
  local root
  root=$(get_project_root)
  assert_equals "${PROJECT_ROOT}" "${root}" "get_project_root should equal PROJECT_ROOT"
}

test_is_inside_git_repo() {
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    assert_true "is_inside_git_repo" "Should be true inside Git repo"
  else
    assert_false "is_inside_git_repo" "Should be false outside Git repo"
  fi
}

test_normalize_path() {
  local clean
  clean=$(normalize_path "${PWD}/foo/../bar/..")
  assert_equals "${PWD}" "${clean}" "normalize_path should resolve dots"
}

test_ensure_directory_exists() {
  local test_dir="${PROJECT_ROOT}/logs/test_nav_dir"
  ensure_directory_exists "${test_dir}"
  assert_true "[[ -d \"${test_dir}\" ]]" "Directory should exist after ensure_directory_exists"
  rm -rf "${test_dir}"
}

test_change_directory() {
  local test_dir="${PROJECT_ROOT}/logs/test_cd_dir"
  ensure_directory_exists "${test_dir}"

  # Test success
  change_directory "${test_dir}"
  assert_equals 0 $? "change_directory should return 0 on success"
  assert_equals "${test_dir}" "${PWD}" "PWD should be updated to target directory"

  # Test failure with non-existent directory
  change_directory "${test_dir}/non_existent_subdir" 2>/dev/null
  assert_equals 1 $? "change_directory should return 1 on failure"

  # Test failure with empty path
  change_directory ""
  assert_equals 1 $? "change_directory should return 1 on empty path"

  # Clean up
  rm -rf "${test_dir}"
}

test_get_current_directory() {
  local cur
  cur=$(get_current_directory)
  assert_equals "${PWD}" "${cur}" "get_current_directory should equal PWD"
}

test_get_absolute_path() {
  local abs
  abs=$(get_absolute_path ".")
  assert_equals "${PWD}" "${abs}" "get_absolute_path of . should be PWD"
}

test_to_project_root() {
  local orig_pwd="${PWD}"
  cd /tmp
  to_project_root
  assert_equals 0 $? "to_project_root should return 0 when PROJECT_ROOT is set"
  assert_equals "${PROJECT_ROOT}" "${PWD}" "to_project_root should change PWD to PROJECT_ROOT"
  cd "${orig_pwd}"
}

run_test test_current_directory
run_test test_get_current_directory
run_test test_dir_up
run_test test_absolute_path
run_test test_get_absolute_path
run_test test_get_project_root
run_test test_to_project_root
run_test test_is_inside_git_repo
run_test test_normalize_path
run_test test_ensure_directory_exists
run_test test_change_directory

exit $(( TESTS_FAILED > 0 ? 1 : 0 ))
