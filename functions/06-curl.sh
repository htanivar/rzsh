# functions/06-curl.sh

# Protect against double sourcing
if [[ -n "${_CURL_SH_SOURCED:-}" ]]; then
  return 0
fi
readonly _CURL_SH_SOURCED=1

# Ensure config & validation are sourced if available
if [[ -f "${PROJECT_ROOT:-.}/config/config.sh" ]]; then
  source "${PROJECT_ROOT:-.}/config/config.sh"
fi
if [[ -f "${PROJECT_ROOT:-.}/functions/04-validation.sh" ]]; then
  source "${PROJECT_ROOT:-.}/functions/04-validation.sh"
fi

# /**
#  * @function http_get
#  * @description Performs an HTTP GET request using curl. Appends HTTP status code to the last line of the output.
#  * @param {string} url - The URL to request.
#  * @param {string} [headers] - Newline-separated headers to include.
#  * @return {string} Response body followed by a newline and the HTTP status code.
#  * @example
#  *   local res
#  *   res=$(http_get "https://api.github.com" "Accept: application/json")
#  */
http_get() {
  local url="$1"
  local headers="$2"
  
  if ! validate_command_exists "curl"; then
    return 1
  fi

  local -a curl_opts=(-s -L -w "\n%{http_code}")
  if [[ -n "${headers}" ]]; then
    local hdr
    for hdr in ${(f)headers}; do
      curl_opts+=(-H "${hdr}")
    done
  fi

  curl "${curl_opts[@]}" "${url}"
}

# /**
#  * @function http_post
#  * @description Performs an HTTP POST request using curl. Appends HTTP status code to the last line of the output.
#  * @param {string} url - The URL to request.
#  * @param {string} data - The POST request body data.
#  * @param {string} [headers] - Newline-separated headers to include.
#  * @return {string} Response body followed by a newline and the HTTP status code.
#  * @example
#  *   local res
#  *   res=$(http_post "https://httpbin.org/post" '{"key": "value"}' "Content-Type: application/json")
#  */
http_post() {
  local url="$1"
  local data="$2"
  local headers="$3"
  
  if ! validate_command_exists "curl"; then
    return 1
  fi

  local -a curl_opts=(-s -L -w "\n%{http_code}" -X POST)
  if [[ -n "${headers}" ]]; then
    local hdr
    for hdr in ${(f)headers}; do
      curl_opts+=(-H "${hdr}")
    done
  fi

  curl "${curl_opts[@]}" -d "${data}" "${url}"
}

# /**
#  * @function http_put
#  * @description Performs an HTTP PUT request using curl. Appends HTTP status code to the last line of the output.
#  * @param {string} url - The URL to request.
#  * @param {string} data - The PUT request body data.
#  * @param {string} [headers] - Newline-separated headers to include.
#  * @return {string} Response body followed by a newline and the HTTP status code.
#  * @example
#  *   local res
#  *   res=$(http_put "https://httpbin.org/put" '{"status": "active"}')
#  */
http_put() {
  local url="$1"
  local data="$2"
  local headers="$3"
  
  if ! validate_command_exists "curl"; then
    return 1
  fi

  local -a curl_opts=(-s -L -w "\n%{http_code}" -X PUT)
  if [[ -n "${headers}" ]]; then
    local hdr
    for hdr in ${(f)headers}; do
      curl_opts+=(-H "${hdr}")
    done
  fi

  curl "${curl_opts[@]}" -d "${data}" "${url}"
}

# /**
#  * @function http_delete
#  * @description Performs an HTTP DELETE request using curl. Appends HTTP status code to the last line of the output.
#  * @param {string} url - The URL to request.
#  * @param {string} [headers] - Newline-separated headers to include.
#  * @return {string} Response body followed by a newline and the HTTP status code.
#  * @example
#  *   local res
#  *   res=$(http_delete "https://httpbin.org/delete")
#  */
http_delete() {
  local url="$1"
  local headers="$2"
  
  if ! validate_command_exists "curl"; then
    return 1
  fi

  local -a curl_opts=(-s -L -w "\n%{http_code}" -X DELETE)
  if [[ -n "${headers}" ]]; then
    local hdr
    for hdr in ${(f)headers}; do
      curl_opts+=(-H "${hdr}")
    done
  fi

  curl "${curl_opts[@]}" "${url}"
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
#  * @function is_json_response
#  * @description Checks if the response body (excluding status code) is valid JSON.
#  * @param {string} response - The raw response output.
#  * @return {number} 0 if JSON, 1 otherwise.
#  * @example
#  *   if is_json_response "${res}"; then
#  *     echo "Received JSON response"
#  *   fi
#  */
is_json_response() {
  local response="$1"
  local body
  body=$(echo "${response}" | sed '$d')
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
