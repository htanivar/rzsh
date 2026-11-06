#!/usr/bin/env zsh
# tests/10-directory.test.sh
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

# Source helpers, config, and target script via RZSH_DIR
my_dir="${${(%):-%x}:A:h}"
if [[ -z "${RZSH_DIR:-}" ]]; then
  printf '[WARN] RZSH_DIR is not set. Please set export RZSH_DIR="%s" in your environment (e.g., ~/.zshrc).\n' "${my_dir:h}" >&2
  export RZSH_DIR="${my_dir:h}"
fi
source "${RZSH_DIR}/tests/test_helpers.sh"
source "${RZSH_DIR}/config/config.sh"
source "${RZSH_DIR}/functions/10-directory.sh"

init_config

test_root_dir="${PROJECT_ROOT}/logs/test_dir_mod"

# Cleanup from previous runs
rm -rf "${test_root_dir}"

test_dir_exists_and_create() {
  assert_false "dir_exists '${test_root_dir}'" "Dir should not exist initially"
  dir_create "${test_root_dir}"
  assert_true "dir_exists '${test_root_dir}'" "Dir should exist after create"
}

test_dir_is_empty_and_clean() {
  assert_true "dir_is_empty '${test_root_dir}'" "Created dir should be empty"
  
  touch "${test_root_dir}/file1.txt"
  assert_false "dir_is_empty '${test_root_dir}'" "Dir with file should not be empty"
  
  dir_clean "${test_root_dir}"
  assert_true "dir_is_empty '${test_root_dir}'" "Dir should be empty after clean"
}

test_dir_copy_and_move() {
  local copy_dir="${test_root_dir}.copy"
  local moved_dir="${test_root_dir}.moved"
  
  dir_create "${test_root_dir}"
  touch "${test_root_dir}/temp.txt"
  
  dir_copy "${test_root_dir}" "${copy_dir}"
  assert_true "dir_exists '${copy_dir}'" "Copied dir should exist"
  assert_true "[[ -f \"${copy_dir}/temp.txt\" ]]" "Copied file should exist"
  
  dir_move "${copy_dir}" "${moved_dir}"
  assert_false "dir_exists '${copy_dir}'" "Copied dir should not exist after move"
  assert_true "dir_exists '${moved_dir}'" "Moved dir should exist"
  
  dir_delete "${moved_dir}" "--force"
  dir_delete "${test_root_dir}" "--force"
}

test_dir_list() {
  dir_create "${test_root_dir}"
  touch "${test_root_dir}/a.txt" "${test_root_dir}/b.log"
  
  local lst
  lst=$(dir_list "${test_root_dir}" "*.txt")
  assert_equals "a.txt" "${lst}" "Filtered list should match pattern" || return 1
  
  dir_clean "${test_root_dir}"
}

test_dir_sync() {
  local sync_dest="${test_root_dir}_sync_dest"
  rm -rf "${sync_dest}"
  
  dir_create "${test_root_dir}"
  echo "data" > "${test_root_dir}/file.txt"
  
  dir_sync "${test_root_dir}" "${sync_dest}"
  assert_true "[[ -f \"${sync_dest}/file.txt\" ]]" "Synced file should exist"
  
  rm -rf "${sync_dest}"
}

test_dir_watch() {
  local changed=0
  test_cb() {
    changed=1
  }
  
  dir_create "${test_root_dir}"
  
  # Run in background since dir_watch runs a short loop
  (
    sleep 0.1
    echo "mod" > "${test_root_dir}/change.txt"
  ) &
  
  dir_watch "${test_root_dir}" "test_cb" 3
  
  assert_equals "1" "${changed}" "Callback should be triggered when file is added"
}

test_dir_size_tree_and_delete() {
  dir_create "${test_root_dir}/sub"
  echo "hello" > "${test_root_dir}/sub/item.txt"

  local sz
  sz=$(dir_size "${test_root_dir}")
  assert_true "[[ \"${sz}\" =~ ^[0-9]+$ && ${sz} -gt 0 ]]" "dir_size should return positive byte count"

  local tree_out
  tree_out=$(dir_tree "${test_root_dir}")
  assert_true "[[ \"${tree_out}\" == *\"item.txt\"* ]]" "dir_tree output should include item.txt"

  dir_delete "${test_root_dir}" "--force"
  assert_false "dir_exists '${test_root_dir}'" "dir_delete should remove directory"
}

run_test test_dir_exists_and_create
run_test test_dir_is_empty_and_clean
run_test test_dir_copy_and_move
run_test test_dir_list
run_test test_dir_sync
run_test test_dir_watch
run_test test_dir_size_tree_and_delete

# Cleanup
rm -rf "${test_root_dir}"

exit $(( TESTS_FAILED > 0 ? 1 : 0 ))
