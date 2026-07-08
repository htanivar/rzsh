# tests/09-file.test.sh

# Source helpers, config, and target script
local my_dir="${${(%):-%x}:A:h}"
source "${my_dir}/test_helpers.sh"
source "${my_dir}/../config/config.sh"
source "${my_dir}/../functions/09-file.sh"

init_config

local test_file="${PROJECT_ROOT}/logs/test_file.txt"

# Ensure clean slate
rm -f "${test_file}"

test_file_exists() {
  assert_false "file_exists '${test_file}'" "File should not exist initially"
  touch "${test_file}"
  assert_true "file_exists '${test_file}'" "File should exist after touch"
  rm -f "${test_file}"
}

test_file_write_and_read() {
  file_write "${test_file}" "line1\nline2"
  local content
  content=$(file_read "${test_file}")
  assert_equals $'line1\nline2' "${content}" "File contents should match written value"
}

test_file_append() {
  file_write "${test_file}" "first"
  file_append "${test_file}" "second"
  local content
  content=$(file_read "${test_file}")
  assert_equals $'first\nsecond' "${content}" "File should contain appended content"
}

test_file_copy_and_move() {
  local copy_file="${test_file}.copy"
  local moved_file="${test_file}.moved"
  
  file_write "${test_file}" "data"
  file_copy "${test_file}" "${copy_file}"
  assert_true "file_exists '${copy_file}'" "Copied file should exist"
  
  file_move "${copy_file}" "${moved_file}"
  assert_false "file_exists '${copy_file}'" "Copied file should not exist after move"
  assert_true "file_exists '${moved_file}'" "Moved file should exist"
  
  rm -f "${test_file}" "${moved_file}"
}

test_file_delete() {
  touch "${test_file}"
  file_delete "${test_file}" "--force"
  assert_false "file_exists '${test_file}'" "File should be deleted"
}

test_file_get_size() {
  file_write "${test_file}" "abc"
  local sz
  sz=$(file_get_size "${test_file}")
  assert_equals "4" "${sz}" "Size of 'abc\\n' should be 4 bytes"
  rm -f "${test_file}"
}

test_file_backup_and_restore() {
  file_write "${test_file}" "original"
  local backup
  backup=$(file_backup "${test_file}")
  
  file_write "${test_file}" "corrupted"
  file_restore "${backup}"
  
  local content
  content=$(file_read "${test_file}")
  assert_equals "original" "${content}" "Restored content should match original"
  
  rm -f "${test_file}" "${backup}"
}

test_file_hash() {
  file_write "${test_file}" "hashme"
  local h
  h=$(file_hash "${test_file}" "sha256")
  # hash of "hashme\n"
  local expected
  expected=$(sha256sum "${test_file}" | cut -d' ' -f1)
  assert_equals "${expected}" "${h}" "SHA256 hash should match system sha256sum"
  rm -f "${test_file}"
}

test_file_head_tail_grep() {
  file_write "${test_file}" $'line1\nline2\nline3\nline4'
  
  local h
  h=$(file_head "${test_file}" 2)
  assert_equals $'line1\nline2' "${h}" "Head should return first 2 lines"
  
  local t
  t=$(file_tail "${test_file}" 2)
  assert_equals $'line3\nline4' "${t}" "Tail should return last 2 lines"
  
  local g
  g=$(file_grep "${test_file}" "line3")
  assert_equals "line3" "${g}" "Grep should find line3"
  
  rm -f "${test_file}"
}

run_test test_file_exists
run_test test_file_write_and_read
run_test test_file_append
run_test test_file_copy_and_move
run_test test_file_delete
run_test test_file_get_size
run_test test_file_backup_and_restore
run_test test_file_hash
run_test test_file_head_tail_grep

exit $(( TESTS_FAILED > 0 ? 1 : 0 ))
