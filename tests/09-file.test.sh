#!/usr/bin/env zsh
# tests/09-file.test.sh
# Breadcrumb: README.md -> GLOSSARY.md -> docs/09-file.md -> examples/09_file_example.sh -> tests/09-file.test.sh
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

# Source helpers, config, and target script via RZSH_DIR
my_dir="${${(%):-%x}:A:h}"
if [[ -z "${RZSH_DIR:-}" ]]; then
  printf '[WARN] RZSH_DIR is not set. Please set export RZSH_DIR="%s" in your environment (e.g., ~/.zshrc).\n' "${my_dir:h}" >&2
  export RZSH_DIR="${my_dir:h}"
fi
source "${RZSH_DIR}/tests/test_helpers.sh"
source "${RZSH_DIR}/config/config.sh"
source "${RZSH_DIR}/functions/09-file.sh"

init_config

test_file="${PROJECT_ROOT}/logs/test_file.txt"

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
  backup=$(file_backup_and_restore "backup" "${test_file}")
  
  file_write "${test_file}" "corrupted"
  file_backup_and_restore "restore" "${test_file}" "${backup}"
  
  local content
  content=$(file_read "${test_file}")
  assert_equals "original" "${content}" "Restored content should match original"
  
  rm -f "${test_file}" "${backup}"

  # Also test direct file_backup and file_restore calls
  file_write "${test_file}" "direct backup content"
  backup=$(file_backup "${test_file}")
  assert_true "file_exists '${backup}'" "Direct backup file should exist"
  file_write "${test_file}" "modified content"
  file_restore "${backup}"
  content=$(file_read "${test_file}")
  assert_equals "direct backup content" "${content}" "file_restore should restore original content"
  rm -f "${test_file}" "${backup}"
}

test_file_permissions_owner_group() {
  file_write "${test_file}" "perm test"
  file_set_permissions "${test_file}" "640"
  local perms
  perms=$(file_get_permissions "${test_file}")
  assert_equals "640" "${perms}" "Permissions should be 640 after file_set_permissions"

  local owner
  owner=$(file_get_owner "${test_file}")
  assert_true "[[ -n \"${owner}\" ]]" "file_get_owner should return non-empty owner name"

  local grp
  grp=$(file_get_group "${test_file}")
  assert_true "[[ -n \"${grp}\" ]]" "file_get_group should return non-empty group name"

  rm -f "${test_file}"
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

test_file_read_to_array() {
  file_write "${test_file}" $'alpha\n\nbeta gamma\n   \ndelta'

  # 1. Read all lines (including blank lines) into named array
  local -a lines
  file_read_to_array "${test_file}" "lines"
  assert_equals "5" "${#lines[@]}" "Should read all 5 lines including blank lines"
  assert_equals "alpha" "${lines[1]}" "First element should be alpha"
  assert_equals "" "${lines[2]}" "Second element should be empty line"
  assert_equals "beta gamma" "${lines[3]}" "Third element should preserve spaces"
  assert_equals "delta" "${lines[5]}" "Fifth element should be delta"

  # 2. Read with skip_empty=1 and loop over results
  local -a non_empty
  file_read_to_array "${test_file}" "non_empty" 1
  assert_equals "3" "${#non_empty[@]}" "skip_empty=1 should skip blank and whitespace-only lines"

  local joined="" item
  for item in "${non_empty[@]}"; do
    joined+="${item}|"
  done
  assert_equals "alpha|beta gamma|delta|" "${joined}" "Looping over populated array should yield expected items"

  # 3. Default array name FILE_LINES
  file_read_to_array "${test_file}" "" 1
  assert_equals "3" "${#FILE_LINES[@]}" "Default FILE_LINES array should be populated"

  # 4. Missing file & invalid array name should fail
  assert_false "file_read_to_array '${test_file}.missing' 'lines'" "Missing file should return 1"
  assert_false "file_read_to_array '${test_file}' '123-invalid'" "Invalid array name should return 1"

  rm -f "${test_file}"
}

test_file_equals_and_compare() {
  local f1="/tmp/rzsh_cmp_a_$$.txt"
  local f2="/tmp/rzsh_cmp_b_$$.txt"
  local f3="/tmp/rzsh_cmp_c_$$.txt"
  local rpt="/tmp/rzsh_cmp_report_$$.md"

  printf 'alpha\nbeta\n' > "${f1}"
  printf 'alpha\nbeta\n' > "${f2}"
  printf 'alpha\ngamma\n' > "${f3}"

  assert_true "file_equals '${f1}' '${f2}'" "Identical files should return 0 for file_equals"
  assert_false "file_equals '${f1}' '${f3}'" "Different files should return non-zero for file_equals"
  assert_false "file_equals '${f1}' '/tmp/does_not_exist_rzsh_$$'" "Missing file should return non-zero"

  assert_true "file_compare -s -o '${rpt}' '${f1}' '${f2}'" "Identical files should return 0 for file_compare"
  assert_true "grep -q 'IDENTICAL' '${rpt}'" "Report should mark identical files as IDENTICAL"

  assert_false "file_compare -s -o '${rpt}' '${f1}' '${f3}'" "Different files should return 1 for file_compare"
  assert_true "grep -q 'DIFFERENT' '${rpt}'" "Report should mark differing files as DIFFERENT"
  assert_true "grep -q -- '-beta' '${rpt}' && grep -q -- '+gamma' '${rpt}'" "Report should include unified diff"

  rm -f "${f1}" "${f2}" "${f3}" "${rpt}"
}

run_test test_file_exists
run_test test_file_write_and_read
run_test test_file_append
run_test test_file_copy_and_move
run_test test_file_delete
run_test test_file_get_size
run_test test_file_backup_and_restore
run_test test_file_permissions_owner_group
run_test test_file_hash
run_test test_file_head_tail_grep
run_test test_file_read_to_array
run_test test_file_equals_and_compare

exit $(( TESTS_FAILED > 0 ? 1 : 0 ))
