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

# ==============================================================================
# Internal Helpers
# ==============================================================================

# Generate N random characters from a tr-compatible character class/set
_mock_random_chars() {
  local charset="$1"
  local length="${2:-12}"
  (( length <= 0 )) && return 0
  LC_ALL=C tr -dc "${charset}" < /dev/urandom | head -c "${length}"
}

# Generate a random non-negative integer (subshell-safe via /dev/urandom)
_mock_rand_uint() {
  if [[ -r /dev/urandom ]] && command -v od >/dev/null 2>&1; then
    local val
    val=$(od -An -N4 -tu4 /dev/urandom | tr -d '[:space:]')
    printf '%s\n' "${val:-$RANDOM}"
  else
    printf '%d\n' "${RANDOM}"
  fi
}

# Generate a single dummy value by type name
_mock_value_by_type() {
  local item_type="${1:-string}"
  case "${item_type}" in
    int|number)   mock_int 1 1000 ;;
    bool|boolean) mock_bool ;;
    email)        mock_email ;;
    uuid)         mock_uuid ;;
    alnum|alphanumeric) mock_alphanumeric 10 ;;
    token|vault)  mock_vault_token ;;
    password)     mock_password 12 1 ;;
    *)            mock_string 8 ;;
  esac
}

# Record a command mock call and emit configured stdout/exit code
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

# ==============================================================================
# Primitive & Secret Data Generators
# ==============================================================================

# /**
#  * @function mock_string
#  * @description Generates a random alphabetic dummy string, optionally with a prefix.
#  * @param {number} [length=12] - Number of random alphabetic characters.
#  * @param {string} [prefix=""] - Optional string prefix.
#  * @return {string} The generated dummy string.
#  * @example
#  *   val=$(mock_string 8 "user_")
#  */
mock_string() {
  local length="${1:-12}"
  local prefix="${2:-}"
  printf '%s%s\n' "${prefix}" "$(_mock_random_chars 'A-Za-z' "${length}")"
}

# /**
#  * @function mock_alphanumeric
#  * @description Generates a random alphanumeric (A-Z, a-z, 0-9) dummy string.
#  * @param {number} [length=16] - Length of the generated string.
#  * @return {string} The generated alphanumeric string.
#  * @example
#  *   id=$(mock_alphanumeric 16)
#  */
mock_alphanumeric() {
  local length="${1:-16}"
  printf '%s\n' "$(_mock_random_chars 'A-Za-z0-9' "${length}")"
}

# /**
#  * @function mock_password
#  * @description Generates a random password with uppercase, lowercase, digits, and optional special characters.
#  * @param {number} [length=16] - Password length (minimum 4 enforced when length >= 4).
#  * @param {number} [include_special=1] - Set to 1 to include special characters (!@#$%^&*-_=+), or 0 for alphanumeric only.
#  * @return {string} The generated password.
#  * @example
#  *   pw=$(mock_password 16 1)
#  */
mock_password() {
  local length="${1:-16}"
  local include_special="${2:-1}"

  local charset='A-Za-z0-9'
  (( include_special == 1 )) && charset='A-Za-z0-9!@#$%^&*_+= -'
  # Keep '-' at the end without spaces in the special set
  (( include_special == 1 )) && charset='A-Za-z0-9!@#$%^&*_+=-'

  if (( length < 4 )); then
    printf '%s\n' "$(_mock_random_chars "${charset}" "${length}")"
    return 0
  fi

  # Guarantee character class diversity in the first characters, then fill remainder
  local guaranteed=""
  guaranteed+="$(_mock_random_chars 'A-Z' 1)"
  guaranteed+="$(_mock_random_chars 'a-z' 1)"
  guaranteed+="$(_mock_random_chars '0-9' 1)"
  if (( include_special == 1 )); then
    guaranteed+="$(_mock_random_chars '!@#$%^&*_+=-' 1)"
  fi

  local rem=$(( length - ${#guaranteed} ))
  local rest=""
  (( rem > 0 )) && rest="$(_mock_random_chars "${charset}" "${rem}")"

  # Shuffle characters using shuf if available, otherwise emit combined string
  local combined="${guaranteed}${rest}"
  if command -v shuf >/dev/null 2>&1; then
    printf '%s' "${combined}" | fold -w1 | shuf | tr -d '\n'
    printf '\n'
  else
    printf '%s\n' "${combined}"
  fi
}

# /**
#  * @function mock_int
#  * @description Generates a random integer within [min, max] inclusive.
#  * @param {number} [min=1] - Minimum integer value.
#  * @param {number} [max=1000] - Maximum integer value.
#  * @return {number} Random integer printed to stdout.
#  * @example
#  *   port=$(mock_int 8000 9000)
#  */
mock_int() {
  local min="${1:-1}"
  local max="${2:-1000}"
  if (( max < min )); then
    local tmp="${min}"
    min="${max}"
    max="${tmp}"
  fi
  local span=$(( max - min + 1 ))
  local r
  r=$(_mock_rand_uint)
  printf '%d\n' $(( min + (r % span) ))
}

# /**
#  * @function mock_bool
#  * @description Generates a random boolean string ('true' or 'false').
#  * @param None
#  * @return {string} 'true' or 'false'.
#  * @example
#  *   flag=$(mock_bool)
#  */
mock_bool() {
  local r
  r=$(_mock_rand_uint)
  if (( r % 2 == 0 )); then
    printf 'true\n'
  else
    printf 'false\n'
  fi
}

# /**
#  * @function mock_uuid
#  * @description Generates a random RFC 4122 version 4 UUID.
#  * @param None
#  * @return {string} UUID v4 string.
#  * @example
#  *   uid=$(mock_uuid)
#  */
mock_uuid() {
  local p1 p2 p3 p4 p5 variant_chars="89ab"
  p1=$(_mock_random_chars '0-9a-f' 8)
  p2=$(_mock_random_chars '0-9a-f' 4)
  p3="4$(_mock_random_chars '0-9a-f' 3)"
  local v_idx=$(( (RANDOM % 4) + 1 ))
  p4="${variant_chars[${v_idx}]}$(_mock_random_chars '0-9a-f' 3)"
  p5=$(_mock_random_chars '0-9a-f' 12)
  printf '%s-%s-%s-%s-%s\n' "${p1}" "${p2}" "${p3}" "${p4}" "${p5}"
}

# /**
#  * @function mock_email
#  * @description Generates a random dummy email address.
#  * @param {string} [domain="example.com"] - Email domain name.
#  * @return {string} Dummy email address.
#  * @example
#  *   email=$(mock_email "acme.test")
#  */
mock_email() {
  local domain="${1:-example.com}"
  local local_part
  local_part="user_$(_mock_random_chars 'a-z0-9' 8)"
  printf '%s@%s\n' "${local_part}" "${domain}"
}

# /**
#  * @function mock_phone
#  * @description Generates a random US-style dummy phone number (+1-555-XXX-XXXX).
#  * @param None
#  * @return {string} Dummy phone number.
#  * @example
#  *   phone=$(mock_phone)
#  */
mock_phone() {
  local area line
  area=$(mock_int 100 999)
  line=$(mock_int 1000 9999)
  printf '+1-555-%03d-%04d\n' "${area}" "${line}"
}

# /**
#  * @function mock_date
#  * @description Prints a formatted timestamp/date string (defaults to YYYY-MM-DD).
#  * @param {string} [format="%Y-%m-%d"] - strftime format string.
#  * @return {string} Formatted date string.
#  * @example
#  *   ts=$(mock_date "%Y-%m-%dT%H:%M:%SZ")
#  */
mock_date() {
  local fmt="${1:-%Y-%m-%d}"
  date -u +"${fmt}"
}

# /**
#  * @function mock_jwt
#  * @description Generates a dummy 3-segment JWT token (header.payload.signature). Uses jwt_create if available, otherwise builds a valid base64url JWT.
#  * @param {string} [sub="mock-user"] - Subject claim ('sub').
#  * @param {string} [role="admin"] - Role claim ('role').
#  * @return {string} Dummy JWT string.
#  * @example
#  *   token=$(mock_jwt "alice" "developer")
#  */
mock_jwt() {
  local sub="${1:-mock-user}"
  local role="${2:-admin}"

  local payload
  payload=$(printf '{"sub":"%s","role":"%s","iat":%d}' "${sub}" "${role}" "$(date +%s)")

  if typeset -f jwt_create >/dev/null 2>&1; then
    jwt_create "${payload}" "${JWT_SECRET:-mock-secret}" 3600
    return $?
  fi

  local hdr_b64 pay_b64 sig_b64
  hdr_b64=$(printf '%s' '{"alg":"HS256","typ":"JWT"}' | base64 | tr '+/' '-_' | tr -d '=\n')
  pay_b64=$(printf '%s' "${payload}" | base64 | tr '+/' '-_' | tr -d '=\n')
  sig_b64=$(_mock_random_chars 'A-Za-z0-9_-' 43)
  printf '%s.%s.%s\n' "${hdr_b64}" "${pay_b64}" "${sig_b64}"
}

# /**
#  * @function mock_vault_token
#  * @description Generates a dummy HashiCorp Vault token (e.g., hvs.<alphanumeric>).
#  * @param {string} [prefix="hvs."] - Vault token prefix.
#  * @param {number} [length=24] - Random suffix length.
#  * @return {string} Dummy Vault token.
#  * @example
#  *   vtok=$(mock_vault_token)
#  */
mock_vault_token() {
  local prefix="${1:-hvs.}"
  local length="${2:-24}"
  printf '%s%s\n' "${prefix}" "$(_mock_random_chars 'A-Za-z0-9' "${length}")"
}

# ==============================================================================
# Array, Nested Array & JSON Generators
# ==============================================================================

# /**
#  * @function mock_array
#  * @description Populates a Zsh array variable with N dummy items of a given type.
#  * @param {number} [count=5] - Number of elements to generate.
#  * @param {string} [array_name=MOCK_ARRAY] - Target Zsh array variable name.
#  * @param {string} [item_type="string"] - Item generator type: string, alphanumeric, int, bool, email, uuid, token, password.
#  * @return {number} 0 on success, 1 if array_name is invalid.
#  * @example
#  *   local -a users
#  *   mock_array 3 "users" "email"
#  */
mock_array() {
  local _count="${1:-5}"
  local _array_name="${2:-MOCK_ARRAY}"
  local _item_type="${3:-string}"

  if [[ ! "${_array_name}" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
    return 1
  fi

  local -a _items
  local _i
  for (( _i = 1; _i <= _count; _i++ )); do
    _items+=("$(_mock_value_by_type "${_item_type}")")
  done

  set -A "${_array_name}" "${_items[@]}"
  return 0
}

# /**
#  * @function mock_nested_array
#  * @description Generates a JSON 2D nested array with the specified rows, columns, and element type.
#  * @param {number} [rows=3] - Number of outer array rows.
#  * @param {number} [cols=3] - Number of elements per inner array.
#  * @param {string} [item_type="string"] - Element type: string, alphanumeric, int, bool, email, uuid.
#  * @return {string} Compact JSON 2D array string.
#  * @example
#  *   matrix=$(mock_nested_array 2 3 "int")
#  */
mock_nested_array() {
  local rows="${1:-3}"
  local cols="${2:-3}"
  local item_type="${3:-string}"

  local out="["
  local r c val
  for (( r = 1; r <= rows; r++ )); do
    (( r > 1 )) && out+=","
    out+="["
    for (( c = 1; c <= cols; c++ )); do
      (( c > 1 )) && out+=","
      val=$(_mock_value_by_type "${item_type}")
      if [[ "${item_type}" == "int" || "${item_type}" == "number" || "${item_type}" == "bool" || "${item_type}" == "boolean" ]]; then
        out+="${val}"
      else
        out+="\"${val}\""
      fi
    done
    out+="]"
  done
  out+="]"
  printf '%s\n' "${out}"
}

# /**
#  * @function mock_json
#  * @description Generates a dummy JSON object with optional nested objects and nested arrays.
#  * @param {number} [depth=1] - Nesting depth (1 = flat object, 2+ = includes nested object and nested array).
#  * @param {number} [keys_count=3] - Number of scalar keys at the root level.
#  * @return {string} Valid JSON object string.
#  * @example
#  *   payload=$(mock_json 2 3)
#  */
mock_json() {
  local depth="${1:-1}"
  local keys_count="${2:-3}"

  local out="{"
  local i key val
  for (( i = 1; i <= keys_count; i++ )); do
    (( i > 1 )) && out+=","
    key="field_${i}"
    val=$(mock_alphanumeric 8)
    out+="\"${key}\":\"${val}\""
  done

  if (( depth > 1 )); then
    local sub
    sub=$(mock_json $(( depth - 1 )) 2)
    local nested_arr
    nested_arr=$(mock_nested_array 2 2 "int")
    out+=",\"nested\":${sub},\"matrix\":${nested_arr}"
  fi

  out+="}"
  printf '%s\n' "${out}"
}

# /**
#  * @function mock_json_user
#  * @description Generates a realistic dummy user JSON payload including nested metadata, roles array, and tokens.
#  * @param None
#  * @return {string} Valid JSON user object string.
#  * @example
#  *   user_json=$(mock_json_user)
#  */
mock_json_user() {
  local uid uname email phone tok created
  uid=$(mock_uuid)
  uname=$(mock_string 6 "usr_")
  email=$(mock_email)
  phone=$(mock_phone)
  tok=$(mock_vault_token)
  created=$(mock_date "%Y-%m-%dT%H:%M:%SZ")

  printf '{"id":"%s","username":"%s","email":"%s","phone":"%s","active":%s,"roles":["viewer","editor"],"token":"%s","meta":{"created_at":"%s","env":"mock"}}\n' \
    "${uid}" "${uname}" "${email}" "${phone}" "$(mock_bool)" "${tok}" "${created}"
}

# ==============================================================================
# Command & HTTP Stubbing
# ==============================================================================

# /**
#  * @function mock_command
#  * @description Mocks a shell command or Zsh function with a static stdout response and exit code, tracking call counts and arguments.
#  * @param {string} cmd_name - Name of the command or function to mock.
#  * @param {string} [stdout_output=""] - Output to print to stdout when invoked.
#  * @param {number} [exit_code=0] - Exit status code to return when invoked.
#  * @return {number} 0 on success, 1 if cmd_name is invalid.
#  * @example
#  *   mock_command "git" "main" 0
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
#  *   mock_was_called "curl" 1
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
