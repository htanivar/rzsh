# functions/06-http.sh

# Protect against double sourcing
if [[ -n "${_HTTP_SH_SOURCED:-}" ]]; then
  return 0
fi
readonly _HTTP_SH_SOURCED=1

# Ensure config & validation are sourced if available
if [[ -f "${RZSH_DIR:-${PROJECT_ROOT:-.}}/config/config.sh" ]]; then
  source "${RZSH_DIR:-${PROJECT_ROOT:-.}}/config/config.sh"
fi
if [[ -f "${RZSH_DIR:-${PROJECT_ROOT:-.}}/functions/04-validation.sh" ]]; then
  source "${RZSH_DIR:-${PROJECT_ROOT:-.}}/functions/04-validation.sh"
fi

# Default HTTP headers string (newline-separated "Key: Value" lines)
HTTP_DEFAULT_HEADERS="${HTTP_DEFAULT_HEADERS:-}"

# Internal helper: merge header lines from a newline-separated block into an associative array
# Usage: _http_merge_headers_into <map_name> <lower_map_name> <header_block>
_http_merge_headers_into() {
  local map_name="$1"
  local lower_name="$2"
  local block="$3"
  [[ -z "${block}" ]] && return 0

  local hdr key val lower_key existing_key
  for hdr in ${(f)block}; do
    [[ -z "${hdr}" || "${hdr}" != *:* ]] && continue
    key="${hdr%%:*}"
    val="${hdr#*:}"
    key="${key#"${key%%[![:space:]]*}"}"
    key="${key%"${key##*[![:space:]]}"}"
    val="${val#"${val%%[![:space:]]*}"}"
    [[ -z "${key}" ]] && continue

    lower_key="${key:l}"
    existing_key="${${(P)lower_name}[${lower_key}]:-}"
    if [[ -n "${existing_key}" && "${existing_key}" != "${key}" ]]; then
      unset "${map_name}[${existing_key}]"
    fi
    typeset -g "${map_name}[${key}]=${val}"
    typeset -g "${lower_name}[${lower_key}]=${key}"
  done
}

# /**
#  * @function http_set_default_header
#  * @description Sets or updates a default HTTP header in HTTP_DEFAULT_HEADERS (case-insensitive key replacement). Passing an empty value unsets the header.
#  * @param {string} name - Header name (e.g., "Authorization", "X-Vault-Request").
#  * @param {string} value - Header value (e.g., "Bearer token", "true").
#  * @return {number} 0 on success, or 1 if name is empty.
#  * @example
#  *   http_set_default_header "Authorization" "Bearer my-token"
#  */
http_set_default_header() {
  local name="$1"
  local value="$2"
  if [[ -z "${name}" ]]; then
    return 1
  fi

  local -A _tmp_hdrs
  local -A _tmp_lower
  _http_merge_headers_into _tmp_hdrs _tmp_lower "${HTTP_DEFAULT_HEADERS}"

  local existing_key="${_tmp_lower[${name:l}]:-}"
  if [[ -n "${existing_key}" ]]; then
    unset "_tmp_hdrs[${existing_key}]"
  fi
  if [[ -n "${value}" ]]; then
    _tmp_hdrs[${name}]="${value}"
  fi

  local k out=""
  for k in "${(@ko)_tmp_hdrs}"; do
    [[ -n "${out}" ]] && out+=$'\n'
    out+="${k}: ${_tmp_hdrs[${k}]}"
  done
  HTTP_DEFAULT_HEADERS="${out}"
  export HTTP_DEFAULT_HEADERS
  return 0
}

# /**
#  * @function http_get_default_header
#  * @description Retrieves a default HTTP header value from HTTP_DEFAULT_HEADERS (case-insensitive lookup).
#  * @param {string} name - Header name to look up.
#  * @return {string} The header value, or empty if not set.
#  * @example
#  *   local ct
#  *   ct=$(http_get_default_header "Content-Type")
#  */
http_get_default_header() {
  local name="$1"
  if [[ -z "${name}" ]]; then
    return 1
  fi

  local -A _tmp_hdrs
  local -A _tmp_lower
  _http_merge_headers_into _tmp_hdrs _tmp_lower "${HTTP_DEFAULT_HEADERS}"

  local existing_key="${_tmp_lower[${name:l}]:-}"
  if [[ -n "${existing_key}" ]]; then
    printf '%s\n' "${_tmp_hdrs[${existing_key}]}"
    return 0
  fi
  return 1
}

# /**
#  * @function http_unset_default_header
#  * @description Removes a default HTTP header from HTTP_DEFAULT_HEADERS (case-insensitive lookup).
#  * @param {string} name - Header name to remove.
#  * @return {number} 0 on success, or 1 if name is empty.
#  * @example
#  *   http_unset_default_header "X-Vault-Token"
#  */
http_unset_default_header() {
  local name="$1"
  if [[ -z "${name}" ]]; then
    return 1
  fi
  http_set_default_header "${name}" ""
}

# /**
#  * @function http_clear_default_headers
#  * @description Clears all default HTTP headers from HTTP_DEFAULT_HEADERS.
#  * @param None
#  * @return {number} 0 on success.
#  * @example
#  *   http_clear_default_headers
#  */
http_clear_default_headers() {
  HTTP_DEFAULT_HEADERS=""
  export HTTP_DEFAULT_HEADERS
  return 0
}

# /**
#  * @function http_build_headers
#  * @description Builds a newline-separated HTTP headers string by merging HTTP_DEFAULT_HEADERS with any extra/override headers passed as arguments.
#  * @param {string} [headers...] - Optional header strings ("Key: Value") or newline-separated header blocks that override matching default headers.
#  * @return {string} Newline-separated "Key: Value" headers ready for http_* functions.
#  * @example
#  *   local hdrs
#  *   hdrs=$(http_build_headers "X-Custom: 1" "Accept: text/plain")
#  */
http_build_headers() {
  local -A _merged
  local -A _lower_to_key

  _http_merge_headers_into _merged _lower_to_key "${HTTP_DEFAULT_HEADERS}"

  local arg
  for arg in "$@"; do
    _http_merge_headers_into _merged _lower_to_key "${arg}"
  done

  local k
  for k in "${(@ko)_merged}"; do
    printf '%s: %s\n' "${k}" "${_merged[${k}]}"
  done
}

# Internal helper: resolve inline JSON, file path, or @file.json payload
_http_resolve_payload() {
  local data="$1"
  if [[ -f "${data}" ]]; then
    cat "${data}"
  elif [[ "${data}" == @* && -f "${data#@}" ]]; then
    cat "${data#@}"
  else
    printf '%s' "${data}"
  fi
}

# Internal helper: execute curl with merged default + custom headers
_http_execute() {
  local method="$1"
  local has_body="$2"
  local url="$3"
  local data="$4"
  local headers="$5"

  if ! validate_command_exists "curl"; then
    return 1
  fi

  local -a curl_opts=(-s -L -w "\n%{http_code}")
  if [[ "${method}" != "GET" ]]; then
    curl_opts+=(-X "${method}")
  fi

  local merged_headers hdr
  merged_headers=$(http_build_headers "${headers}")
  if [[ -n "${merged_headers}" ]]; then
    for hdr in ${(f)merged_headers}; do
      curl_opts+=(-H "${hdr}")
    done
  fi

  if (( has_body == 1 )); then
    local payload
    payload=$(_http_resolve_payload "${data}")
    curl_opts+=(-d "${payload}")
  fi

  curl "${curl_opts[@]}" "${url}"
}

# /**
#  * @function http_get
#  * @description Performs an HTTP GET request using curl. Appends HTTP status code to the last line of the output.
#  * @param {string} url - The URL to request.
#  * @param {string} [headers] - Newline-separated headers to include (merged with HTTP_DEFAULT_HEADERS).
#  * @return {string} Response body followed by a newline and the HTTP status code.
#  * @example
#  *   local res
#  *   res=$(http_get "https://api.github.com" "Accept: application/json")
#  */
http_get() {
  _http_execute "GET" 0 "$1" "" "$2"
}

# /**
#  * @function http_post
#  * @description Performs an HTTP POST request using curl. Supports passing a JSON string, a path to a .json file, or @file.json. Appends HTTP status code to the last line of the output.
#  * @param {string} url - The URL to request.
#  * @param {string} data - The POST request body data (inline JSON string, file path to .json file, or @file.json).
#  * @param {string} [headers] - Newline-separated headers to include (merged with HTTP_DEFAULT_HEADERS).
#  * @return {string} Response body followed by a newline and the HTTP status code.
#  * @example
#  *   local res
#  *   res=$(http_post "https://httpbin.org/post" "./payload.json" "Content-Type: application/json")
#  */
http_post() {
  _http_execute "POST" 1 "$1" "$2" "$3"
}

# /**
#  * @function http_put
#  * @description Performs an HTTP PUT request using curl. Supports passing a JSON string, a path to a .json file, or @file.json. Appends HTTP status code to the last line of the output.
#  * @param {string} url - The URL to request.
#  * @param {string} data - The PUT request body data (inline JSON string, file path to .json file, or @file.json).
#  * @param {string} [headers] - Newline-separated headers to include (merged with HTTP_DEFAULT_HEADERS).
#  * @return {string} Response body followed by a newline and the HTTP status code.
#  * @example
#  *   local res
#  *   res=$(http_put "https://httpbin.org/put" "./payload.json" "Content-Type: application/json")
#  */
http_put() {
  _http_execute "PUT" 1 "$1" "$2" "$3"
}

# /**
#  * @function http_patch
#  * @description Performs an HTTP PATCH request using curl. Supports passing a JSON string, a path to a .json file, or @file.json. Appends HTTP status code to the last line of the output.
#  * @param {string} url - The URL to request.
#  * @param {string} data - The PATCH request body data (inline JSON string, file path to .json file, or @file.json).
#  * @param {string} [headers] - Newline-separated headers to include (merged with HTTP_DEFAULT_HEADERS).
#  * @return {string} Response body followed by a newline and the HTTP status code.
#  * @example
#  *   local res
#  *   res=$(http_patch "https://httpbin.org/patch" "./payload.json" "Content-Type: application/json")
#  */
http_patch() {
  _http_execute "PATCH" 1 "$1" "$2" "$3"
}

# /**
#  * @function http_delete
#  * @description Performs an HTTP DELETE request using curl. Appends HTTP status code to the last line of the output.
#  * @param {string} url - The URL to request.
#  * @param {string} [headers] - Newline-separated headers to include (merged with HTTP_DEFAULT_HEADERS).
#  * @return {string} Response body followed by a newline and the HTTP status code.
#  * @example
#  *   local res
#  *   res=$(http_delete "https://httpbin.org/delete")
#  */
http_delete() {
  _http_execute "DELETE" 0 "$1" "" "$2"
}

# /**
#  * @function check_status_code
#  * @description Extracts the HTTP status code from the formatted curl response output.
#  * @param {string} response - The raw HTTP response (containing status code on last line).
#  * @return {string} The HTTP status code.
#  * @example
#  *   local code
#  *   code=$(check_status_code "${res}")
#  */
check_status_code() {
  local response="$1"
  echo "${response}" | tail -n 1
}

# /**
#  * @function http_get_body
#  * @description Extracts the HTTP response body from a raw HTTP response (excluding the trailing status code).
#  * @param {string} response - The raw response string containing response body followed by status code.
#  * @return {string} The response body.
#  * @example
#  *   local body
#  *   body=$(http_get_body "${res}")
#  * */
http_get_body() {
  local response="$1"
  echo "${response}" | sed '$d'
}

# /**
#  * @function is_json_response
#  * @description Checks if the response body (excluding status code) is valid JSON.
#  * @param {string} response - The raw response output.
#  * @return {number} 0 if JSON, 1 otherwise.
#  * @example
#  *   if is_json_response "${res}"; then
#  *     echo "Received JSON response"
#  *   fi
#  * */
is_json_response() {
  local response="$1"
  local body
  body=$(http_get_body "${response}")
  validate_json "${body}"
}

# /**
#  * @function extract_json_field
#  * @description Extracts a specific field from a JSON string using jq.
#  * @param {string} json - The JSON string.
#  * @param {string} field - The field query path (e.g. '.name' or '.nested.value').
#  * @return {string} The extracted value.
#  * @example
#  *   local val
#  *   val=$(extract_json_field '{"user": "Alice"}' ".user")
#  */
extract_json_field() {
  local json="$1"
  local field="$2"
  if ! validate_command_exists "jq"; then
    echo "${json}" | grep -oP "(?<=\"${field#.}\":\")[^\"]*" || echo "${json}" | grep -oP "(?<=\"${field#.}\":)[0-9.]+"
    return 0
  fi
  echo "${json}" | jq -r "${field}" 2>/dev/null
}

# /**
#  * @function download_file
#  * @description Downloads a file from the specified URL to a local destination file path.
#  * @param {string} url - The URL to download.
#  * @param {string} destination - The local output file path.
#  * @return {number} 0 on success, or non-zero on failure.
#  * @example
#  *   download_file "https://example.com/logo.png" "/tmp/logo.png"
#  */
download_file() {
  local url="$1"
  local dest="$2"
  if ! validate_command_exists "curl"; then
    return 1
  fi
  curl -s -L -o "${dest}" "${url}"
}

# /**
#  * @function http_get_with_retry
#  * @description Performs an HTTP GET request with retries if the status code is not 2xx.
#  * @param {string} url - The URL to request.
#  * @param {number} [retries=3] - Maximum number of attempts.
#  * @return {string} Response body followed by a newline and the HTTP status code.
#  * @example
#  *   local res
#  *   res=$(http_get_with_retry "https://api.github.com" 5)
#  */
http_get_with_retry() {
  local url="$1"
  local retries="${2:-3}"
  local count=0
  local response
  local http_status

  while (( count < retries )); do
    response=$(http_get "${url}")
    http_status=$(check_status_code "${response}")
    if [[ "${http_status}" =~ ^2[0-9][0-9]$ ]]; then
      echo "${response}"
      return 0
    fi
    (( count++ ))
    sleep 1
  done
  
  echo "${response}"
  return 1
}
