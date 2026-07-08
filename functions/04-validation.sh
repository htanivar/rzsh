# functions/04-validation.sh

# Protect against double sourcing
if [[ -n "${_VALIDATION_SH_SOURCED:-}" ]]; then
  return 0
fi
readonly _VALIDATION_SH_SOURCED=1

# Ensure config & logs are sourced if available
if [[ -f "${PROJECT_ROOT:-.}/config/config.sh" ]]; then
  source "${PROJECT_ROOT:-.}/config/config.sh"
fi
if [[ -f "${PROJECT_ROOT:-.}/functions/01-logs.sh" ]]; then
  source "${PROJECT_ROOT:-.}/functions/01-logs.sh"
fi

# /**
#  * @function validate_required
#  * @description Validates that a variable value is not empty.
#  * @param {string} var - The value to check.
#  * @param {string} [message="Value is required"] - Custom error message.
#  * @return {number} 0 if valid, 1 otherwise.
#  * @example
#  *   validate_required "${my_var}" "my_var must be set"
#  */
validate_required() {
  local var_val="$1"
  local msg="${2:-Value is required}"
  if [[ -z "${var_val}" ]]; then
    if typeset -f log_error >/dev/null; then
      log_error "${msg}"
    else
      printf "Error: %s\n" "${msg}" >&2
    fi
    return 1
  fi
  return 0
}

# /**
#  * @function validate_in_list
#  * @description Validates that a value exists in a space- or comma-separated list.
#  * @param {string} value - The value to search for.
#  * @param {string} list - The list of allowed values.
#  * @return {number} 0 if found, 1 otherwise.
#  * @example
#  *   validate_in_list "apple" "apple banana orange"
#  */
validate_in_list() {
  local val="$1"
  local list_str="$2"
  local item
  for item in ${(s: :)${list_str//,/ }}; do
    if [[ "${val}" == "${item}" ]]; then
      return 0
    fi
  done
  return 1
}

# /**
#  * @function validate_file_exists
#  * @description Validates that a file exists at the given path.
#  * @param {string} file_path - The path to the file.
#  * @return {number} 0 if file exists, 1 otherwise.
#  * @example
#  *   validate_file_exists "/etc/hosts"
#  */
validate_file_exists() {
  local file_path="$1"
  if [[ -f "${file_path}" ]]; then
    return 0
  fi
  return 1
}

# /**
#  * @function validate_directory_exists
#  * @description Validates that a directory exists at the given path.
#  * @param {string} dir_path - The path to the directory.
#  * @return {number} 0 if directory exists, 1 otherwise.
#  * @example
#  *   validate_directory_exists "/var/log"
#  */
validate_directory_exists() {
  local dir_path="$1"
  if [[ -d "${dir_path}" ]]; then
    return 0
  fi
  return 1
}

# /**
#  * @function validate_is_number
#  * @description Validates that a value is a number (integer or decimal, positive or negative).
#  * @param {string} value - The value to check.
#  * @return {number} 0 if a valid number, 1 otherwise.
#  * @example
#  *   validate_is_number "-123.45"
#  */
validate_is_number() {
  local val="$1"
  if [[ "${val}" =~ ^[-+]?[0-9]*\.?[0-9]+$ ]]; then
    return 0
  fi
  return 1
}

# /**
#  * @function validate_email
#  * @description Validates that a string matches a basic email regex pattern.
#  * @param {string} email - The email to validate.
#  * @return {number} 0 if valid, 1 otherwise.
#  * @example
#  *   validate_email "test@example.com"
#  */
validate_email() {
  local email="$1"
  if [[ "${email}" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
    return 0
  fi
  return 1
}

# /**
#  * @function validate_url
#  * @description Validates that a string is a valid HTTP/HTTPS URL.
#  * @param {string} url - The URL to validate.
#  * @return {number} 0 if valid, 1 otherwise.
#  * @example
#  *   validate_url "https://google.com"
#  */
validate_url() {
  local url="$1"
  if [[ "${url}" =~ ^https?://[A-Za-z0-9.-]+ ]]; then
    return 0
  fi
  return 1
}

# /**
#  * @function validate_command_exists
#  * @description Validates that an external command/executable is available in the current PATH.
#  * @param {string} command - The command to check.
#  * @return {number} 0 if command exists, 1 otherwise.
#  * @example
#  *   validate_command_exists "curl"
#  */
validate_command_exists() {
  local cmd="$1"
  if command -v "${cmd}" &>/dev/null; then
    return 0
  fi
  return 1
}

# /**
#  * @function validate_date
#  * @description Validates that a date string is valid and parseable.
#  * @param {string} date_string - The date string to validate.
#  * @return {number} 0 if valid date, 1 otherwise.
#  * @example
#  *   validate_date "2026-07-08"
#  */
validate_date() {
  local date_str="$1"
  if [[ -z "${date_str}" ]]; then
    return 1
  fi
  if date -d "${date_str}" &>/dev/null; then
    return 0
  elif date -j -f "%Y-%m-%d" "${date_str}" "${date_str}" &>/dev/null; then
    return 0
  elif date -j "${date_str}" &>/dev/null; then
    return 0
  elif [[ "${date_str}" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    return 0
  fi
  return 1
}

# /**
#  * @function validate_jwt
#  * @description Validates that a token has the correct structural format of a JWT (header.payload.signature).
#  * @param {string} token - The JWT token to validate.
#  * @return {number} 0 if structurally valid, 1 otherwise.
#  * @example
#  *   validate_jwt "abc.def.ghi"
#  */
validate_jwt() {
  setopt localoptions extendedglob
  local token="$1"
  if [[ "${token}" == [A-Za-z0-9_-]##.[A-Za-z0-9_-]##.[A-Za-z0-9_-]## ]]; then
    return 0
  fi
  return 1
}

# /**
#  * @function validate_json
#  * @description Validates that a string is a valid JSON document (using jq if available).
#  * @param {string} json_string - The JSON string to validate.
#  * @return {number} 0 if valid JSON, 1 otherwise.
#  * @example
#  *   validate_json '{"name": "test"}'
#  */
validate_json() {
  local json_str="$1"
  if [[ -z "${json_str}" ]]; then
    return 1
  fi
  if command -v jq &>/dev/null; then
    echo "${json_str}" | jq . &>/dev/null
    return $?
  else
    if [[ "${json_str}" =~ ^[[:space:]]*[\{\[].*[\}\]][[:space:]]*$ ]]; then
      return 0
    fi
  fi
  return 1
}
