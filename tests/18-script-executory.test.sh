#!/usr/bin/env zsh
# tests/18-script-executory.test.sh
# Breadcrumb: README.md -> GLOSSARY.md -> docs/18-script-executory.md -> examples/18_script_executory_example.sh -> tests/18-script-executory.test.sh
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

my_dir="${${(%):-%x}:A:h}"
if [[ -z "${RZSH_DIR:-}" ]]; then
  printf '[WARN] RZSH_DIR is not set. Please set export RZSH_DIR="%s" in your environment (e.g., ~/.zshrc).\n' "${my_dir:h}" >&2
  export RZSH_DIR="${my_dir:h}"
fi
source "${RZSH_DIR}/tests/test_helpers.sh"
source "${RZSH_DIR}/config/config.sh"
source "${RZSH_DIR}/functions/18-script-executory.sh"

init_config

_make_test_dir() {
  local d="/tmp/rzsh_executory_test_$$"
  mkdir -p "${d}"
  echo "${d}"
}

test_validate_script_executable() {
  local d=$(_make_test_dir)
  echo 'echo "ok"' > "${d}/valid.sh"
  echo 'if [[ "unclosed' > "${d}/broken.sh"

  assert_true "validate_script_executable '${d}/valid.sh' >/dev/null 2>&1" "Valid script should pass"
  assert_false "validate_script_executable '${d}/missing.sh' >/dev/null 2>&1" "Missing script should fail"
  assert_false "validate_script_executable '${d}/broken.sh' >/dev/null 2>&1" "Syntax-broken script should fail"

  rm -rf "${d}"
}

test_execute_script_and_args() {
  local d=$(_make_test_dir)
  cat <<'EOF' > "${d}/greet.sh"
#!/usr/bin/env zsh
[[ "$1" == "hello" ]] && exit 0 || exit 2
EOF

  assert_true "execute_script '${d}/greet.sh' 'hello' >/dev/null 2>&1" "Script with matching arg should succeed"
  assert_false "execute_script '${d}/greet.sh' 'bye' >/dev/null 2>&1" "Script with non-matching arg should fail"

  rm -rf "${d}"
}

test_execute_scripts_sequence_order_and_fail_fast() {
  local d=$(_make_test_dir)
  local trace="${d}/trace.log"

  echo "echo step1 >> '${trace}'" > "${d}/login.sh"
  echo "echo step2 >> '${trace}'; exit 1" > "${d}/verify.sh"
  echo "echo step3 >> '${trace}'" > "${d}/update.sh"

  assert_false "execute_scripts_sequence '${d}/login.sh' '${d}/verify.sh' '${d}/update.sh' >/dev/null 2>&1" "Fail-fast sequence should return non-zero"
  local content=$(<"${trace}")
  assert_equals $'step1\nstep2' "${content}" "Fail-fast should stop before update.sh"

  # Continue on error should run all 3
  : > "${trace}"
  assert_false "execute_scripts_sequence --continue-on-error '${d}/login.sh' '${d}/verify.sh' '${d}/update.sh' >/dev/null 2>&1" "Continue-on-error still returns non-zero if any failed"
  content=$(<"${trace}")
  assert_equals $'step1\nstep2\nstep3' "${content}" "Continue-on-error should run all 3 scripts"

  rm -rf "${d}"
}

test_execute_scripts_sequence_source_and_dry_run() {
  local d=$(_make_test_dir)
  echo 'EXEC_TEST_VAR="from_login"' > "${d}/login.sh"
  echo '[[ "${EXEC_TEST_VAR}" == "from_login" ]]' > "${d}/verify.sh"

  assert_true "execute_scripts_sequence --dry-run '${d}/login.sh' '${d}/verify.sh' >/dev/null 2>&1" "Dry-run should succeed for valid scripts"
  assert_true "execute_scripts_sequence --source '${d}/login.sh' '${d}/verify.sh' >/dev/null 2>&1" "Sourced sequence should share variables"

  rm -rf "${d}"
}

test_execute_scripts_from_file() {
  local d=$(_make_test_dir)
  local trace="${d}/trace.log"
  echo "echo one >> '${trace}'" > "${d}/s1.sh"
  echo "echo two >> '${trace}'" > "${d}/s2.sh"

  cat <<EOF > "${d}/manifest.txt"
# Comment line

${d}/s1.sh
${d}/s2.sh
EOF

  assert_true "execute_scripts_from_file '${d}/manifest.txt' >/dev/null 2>&1" "Manifest execution should succeed"
  local content=$(<"${trace}")
  assert_equals $'one\ntwo' "${content}" "Manifest should run s1 then s2"

  rm -rf "${d}"
}

test_execute_script_with_retry() {
  local d=$(_make_test_dir)
  local count_file="${d}/count.txt"
  echo "0" > "${count_file}"

  cat <<EOF > "${d}/flaky.sh"
#!/usr/bin/env zsh
c=\$(<"${count_file}")
c=\$(( c + 1 ))
echo "\${c}" > "${count_file}"
(( c >= 2 )) && exit 0 || exit 1
EOF

  assert_true "execute_script_with_retry '${d}/flaky.sh' 3 0 >/dev/null 2>&1" "Flaky script should succeed on 2nd attempt"
  assert_equals "2" "$(<"${count_file}")" "Should have taken 2 attempts"

  rm -rf "${d}"
}

run_test test_validate_script_executable
run_test test_execute_script_and_args
run_test test_execute_scripts_sequence_order_and_fail_fast
run_test test_execute_scripts_sequence_source_and_dry_run
run_test test_execute_scripts_from_file
run_test test_execute_script_with_retry

exit $(( TESTS_FAILED > 0 ? 1 : 0 ))
