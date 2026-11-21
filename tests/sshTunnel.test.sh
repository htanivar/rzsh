#!/usr/bin/env zsh
# tests/sshTunnel.test.sh
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

my_dir="${${(%):-%x}:A:h}"
if [[ -z "${RZSH_DIR:-}" ]]; then
  export RZSH_DIR="${my_dir:h}"
fi

source "${RZSH_DIR}/tests/test_helpers.sh"
source "${RZSH_DIR}/config/config.sh"
init_config

TARGET_SCRIPT="${RZSH_DIR}/scripts/02-ssh/sshTunnel.sh"

# Create a temporary mock bin directory with a fake `ssh` binary
MOCK_BIN_DIR=$(mktemp -d)
SSH_ARGS_FILE="${MOCK_BIN_DIR}/ssh_args.txt"
DUMMY_KEY="${MOCK_BIN_DIR}/dummy_id_rsa"
touch "${DUMMY_KEY}"

cat <<'EOF' > "${MOCK_BIN_DIR}/ssh"
#!/usr/bin/env zsh
echo "$@" > "${MOCK_SSH_ARGS_FILE}"
if [[ "$*" == *"-N"* ]]; then
  sleep 3
fi
exit 0
EOF
chmod +x "${MOCK_BIN_DIR}/ssh"

cleanup() {
  rm -rf "${MOCK_BIN_DIR}"
}
trap cleanup EXIT

test_help_flag() {
  local out
  out=$("${TARGET_SCRIPT}" --help)
  assert_equals 0 $? "--help should exit with 0"
  assert_true "[[ \"${out}\" == *\"--local-port\"* ]]" "--help should document --local-port"
}

test_non_interactive_missing_args_fails() {
  "${TARGET_SCRIPT}" --non-interactive -H "10.0.0.5" >/dev/null 2>&1
  assert_equals 1 $? "Non-interactive mode with missing args should fail"
}

test_non_interactive_cli_mode() {
  rm -f "${SSH_ARGS_FILE}"
  local pid
  pid=$(PATH="${MOCK_BIN_DIR}:${PATH}" MOCK_SSH_ARGS_FILE="${SSH_ARGS_FILE}" \
    "${TARGET_SCRIPT}" -H "203.0.113.10" -p 2222 -u "ubuntu" -l 8080 -t "127.0.0.1" -r 80 -i "${DUMMY_KEY}" --skip-check 2>/dev/null)
  local rc=$?
  assert_equals 0 ${rc} "Non-interactive CLI mode should succeed"
  assert_true "[[ \"${pid}\" =~ ^[0-9]+$ ]]" "Should output numeric tunnel PID"

  # Clean up background mock ssh process
  kill "${pid}" 2>/dev/null

  local args
  args=$(cat "${SSH_ARGS_FILE}" 2>/dev/null)
  assert_true "[[ \"${args}\" == *\"-N -L 8080:127.0.0.1:80\"* ]]" "Should pass -N -L forwarding args"
  assert_true "[[ \"${args}\" == *\"-p 2222\"* ]]" "Should pass SSH port 2222"
  assert_true "[[ \"${args}\" == *\"-i ${DUMMY_KEY}\"* ]]" "Should pass identity key"
  assert_true "[[ \"${args}\" == *\"ubuntu@203.0.113.10\"* ]]" "Should pass user@host"
}

test_interactive_mode() {
  rm -f "${SSH_ARGS_FILE}"
  local pid
  pid=$(printf "198.51.100.20\n22\ndeploy\n9090\nlocalhost\n3000\n1\ny\n" | \
    PATH="${MOCK_BIN_DIR}:${PATH}" MOCK_SSH_ARGS_FILE="${SSH_ARGS_FILE}" \
    "${TARGET_SCRIPT}" --skip-check 2>/dev/null)
  local rc=$?
  assert_equals 0 ${rc} "Interactive mode should succeed"
  assert_true "[[ \"${pid}\" =~ ^[0-9]+$ ]]" "Interactive mode should output numeric tunnel PID"

  kill "${pid}" 2>/dev/null

  local args
  args=$(cat "${SSH_ARGS_FILE}" 2>/dev/null)
  assert_true "[[ \"${args}\" == *\"-N -L 9090:localhost:3000\"* ]]" "Interactive mode should forward 9090:localhost:3000"
  assert_true "[[ \"${args}\" == *\"deploy@198.51.100.20\"* ]]" "Interactive mode should connect as deploy@198.51.100.20"
}

run_test test_help_flag
run_test test_non_interactive_missing_args_fails
run_test test_non_interactive_cli_mode
run_test test_interactive_mode
