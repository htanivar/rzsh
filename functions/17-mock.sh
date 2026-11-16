# functions/17-mock.sh

# Protect against double sourcing
if [[ -n "${_MOCK_SH_SOURCED:-}" ]]; then
  return 0
fi
readonly _MOCK_SH_SOURCED=1

# Ensure config is sourced if available
if [[ -f "${RZSH_DIR:-${PROJECT_ROOT:-.}}/config/config.sh" ]]; then
  source "${RZSH_DIR:-${PROJECT_ROOT:-.}}/config/config.sh"
fi

# Global mock state maps & subshell-safe state directory
typeset -g -A MOCK_CALL_COUNTS
typeset -g -A MOCK_CALL_ARGS
typeset -g -A MOCK_RESPONSES
typeset -g -A MOCK_EXIT_CODES
typeset -g -A MOCK_SAVED_FUNCS
typeset -g _MOCK_STATE_DIR="${_MOCK_STATE_DIR:-/tmp/rzsh_mock_$$}"

# Internal helper: record a call and emit configured mock output/exit code
_mock_dispatch() {
  local cmd_name="$1"
  shift

  local count=0
  local count_file="${_MOCK_STATE_DIR}/${cmd_name}.count"
  local args_file="${_MOCK_STATE_DIR}/${cmd_name}.args"
  if [[ -f "${count_file}" ]]; then
    count=$(<"${count_file}")
  else
    count="${MOCK_CALL_COUNTS[${cmd_name}]:-0}"
  fi
  count=$(( count + 1 ))

  MOCK_CALL_COUNTS[${cmd_name}]="${count}"
  MOCK_CALL_ARGS[${cmd_name}]="$*"
  if [[ -d "${_MOCK_STATE_DIR}" ]]; then
    printf '%d\n' "${count}" > "${count_file}"
    printf '%s' "$*" > "${args_file}"
  fi

  if [[ -n "${MOCK_RESPONSES[${cmd_name}]:-}" ]]; then
    printf '%s\n' "${MOCK_RESPONSES[${cmd_name}]}"
  fi
  return "${MOCK_EXIT_CODES[${cmd_name}]:-0}"
}

# /**
#  * @function mock_command
#  * @description Mocks a shell command or Zsh function with a static stdout response and exit code, tracking call counts and arguments.
#  * @param {string} cmd_name - Name of the command or function to mock.
#  * @param {string} [stdout_output=""] - Output to print to stdout when invoked.
#  * @param {number} [exit_code=0] - Exit status code to return when invoked.
#  * @return {number} 0 on success, 1 if cmd_name is invalid.
#  * @example
#  *   mock_command "git" "main" 0
#  *   git rev-parse --abbrev-ref HEAD
#  *   mock_restore "git"
#  */
mock_command() {
  local cmd_name="$1"
  local stdout_output="${2:-}"
  local exit_code="${3:-0}"

  if [[ ! "${cmd_name}" =~ ^[A-Za-z_][A-Za-z0-9_-]*$ ]]; then
    return 1
  fi

  # Save existing Zsh function body once so mock_restore can bring it back
  if [[ -z "${MOCK_RESPONSES[${cmd_name}]+set}" ]] && (( ${+functions[${cmd_name}]} )); then
    MOCK_SAVED_FUNCS[${cmd_name}]="${functions[${cmd_name}]}"
  fi

  MOCK_RESPONSES[${cmd_name}]="${stdout_output}"
  MOCK_EXIT_CODES[${cmd_name}]="${exit_code}"
  MOCK_CALL_COUNTS[${cmd_name}]=0
  MOCK_CALL_ARGS[${cmd_name}]=""

  mkdir -p "${_MOCK_STATE_DIR}"
  printf '0\n' > "${_MOCK_STATE_DIR}/${cmd_name}.count"
  : > "${_MOCK_STATE_DIR}/${cmd_name}.args"

  eval "${cmd_name}() { _mock_dispatch '${cmd_name}' \"\$@\"; }"
  return 0
}

# /**
#  * @function mock_http_response
#  * @description Convenience helper that mocks curl to return a specified body and HTTP status code for 06-http.sh calls.
#  * @param {string} [body='{"ok":true}'] - Response body to return.
#  * @param {number} [status_code=200] - HTTP status code appended on the final line.
#  * @return {number} 0 on success.
#  * @example
#  *   mock_http_response '{"status":"healthy"}' 200
#  *   res=$(http_get "https://api.example.com/health")
#  *   mock_restore "curl"
#  */
mock_http_response() {
  local body="${1:-{\"ok\":true\}}"
  local status_code="${2:-200}"
  mock_command "curl" "${body}"$'\n'"${status_code}" 0
}

# /**
#  * @function mock_get_call_count
#  * @description Prints the number of times a mocked command/function has been invoked.
#  * @param {string} cmd_name - Name of the mocked command.
#  * @return {number} Call count integer printed to stdout.
#  * @example
#  *   count=$(mock_get_call_count "curl")
#  */
mock_get_call_count() {
  local cmd_name="$1"
  local count_file="${_MOCK_STATE_DIR}/${cmd_name}.count"
  if [[ -f "${count_file}" ]]; then
    cat "${count_file}"
  else
    printf '%d\n' "${MOCK_CALL_COUNTS[${cmd_name}]:-0}"
  fi
}

# /**
#  * @function mock_get_last_args
#  * @description Prints the argument string passed during the most recent call to a mocked command.
#  * @param {string} cmd_name - Name of the mocked command.
#  * @return {string} Arguments from the last invocation.
#  * @example
#  *   args=$(mock_get_last_args "git")
#  */
mock_get_last_args() {
  local cmd_name="$1"
  local args_file="${_MOCK_STATE_DIR}/${cmd_name}.args"
  if [[ -f "${args_file}" ]]; then
    printf '%s\n' "$(<"${args_file}")"
  else
    printf '%s\n' "${MOCK_CALL_ARGS[${cmd_name}]:-}"
  fi
}

# /**
#  * @function mock_was_called
#  * @description Checks whether a mocked command was called (at least once, or an exact expected count).
#  * @param {string} cmd_name - Name of the mocked command.
#  * @param {number} [expected_count] - Optional exact call count to assert.
#  * @return {number} 0 if the expectation is met, 1 otherwise.
#  * @example
#  *   if mock_was_called "curl" 1; then
#  *     echo "curl was called once"
#  *   fi
#  */
mock_was_called() {
  local cmd_name="$1"
  local expected_count="${2:-}"
  local actual
  actual=$(mock_get_call_count "${cmd_name}")

  if [[ -n "${expected_count}" ]]; then
    (( actual == expected_count )) && return 0
    return 1
  fi

  (( actual > 0 )) && return 0
  return 1
}

# /**
#  * @function mock_restore
#  * @description Removes a mock for a command/function, restoring any previously saved Zsh function definition.
#  * @param {string} cmd_name - Name of the mocked command to restore.
#  * @return {number} 0 on success.
#  * @example
#  *   mock_restore "curl"
#  */
mock_restore() {
  local cmd_name="$1"
  [[ -z "${cmd_name}" ]] && return 1

  unfunction "${cmd_name}" 2>/dev/null || true

  if [[ -n "${MOCK_SAVED_FUNCS[${cmd_name}]+set}" ]]; then
    functions[${cmd_name}]="${MOCK_SAVED_FUNCS[${cmd_name}]}"
    unset "MOCK_SAVED_FUNCS[${cmd_name}]"
  fi

  unset "MOCK_RESPONSES[${cmd_name}]"
  unset "MOCK_EXIT_CODES[${cmd_name}]"
  unset "MOCK_CALL_COUNTS[${cmd_name}]"
  unset "MOCK_CALL_ARGS[${cmd_name}]"
  rm -f "${_MOCK_STATE_DIR}/${cmd_name}.count" "${_MOCK_STATE_DIR}/${cmd_name}.args"
  return 0
}

# /**
#  * @function mock_restore_all
#  * @description Restores all currently mocked commands/functions and clears all mock state.
#  * @param None
#  * @return {number} 0 on success.
#  * @example
#  *   mock_restore_all
#  */
mock_restore_all() {
  local cmd
  for cmd in "${(@k)MOCK_RESPONSES}"; do
    mock_restore "${cmd}"
  done
  rm -rf "${_MOCK_STATE_DIR}" 2>/dev/null || true
  return 0
}
