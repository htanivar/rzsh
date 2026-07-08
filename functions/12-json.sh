# functions/12-json.sh

# Protect against double sourcing
if [[ -n "${_JSON_SH_SOURCED:-}" ]]; then
  return 0
fi
readonly _JSON_SH_SOURCED=1

# Ensure config is sourced if available
if [[ -f "${PROJECT_ROOT:-.}/config/config.sh" ]]; then
  source "${PROJECT_ROOT:-.}/config/config.sh"
fi

# /**
#  * @function json_parse
#  * @description Parses and prints the structured representation of a JSON string.
#  * @param {string} json - JSON string.
#  * @return {number} 0 on success, non-zero on failure.
#  * @example
#  *   json_parse '{"name": "test"}'
#  */
json_parse() {
  local json="$1"
  if [[ -z "${json}" ]]; then
    return 1
  fi
  echo "${json}" | jq .
}

# /**
#  * @function json_get_value
#  * @description Gets the value at the specified JSON path using jq.
#  * @param {string} json - JSON string.
#  * @param {string} path - jq path filter (e.g. '.user.name').
#  * @return {string} The extracted value.
#  * @example
#  *   local name
#  *   name=$(json_get_value '{"user": {"name": "Bob"}}' '.user.name')
#  */
json_get_value() {
  local json="$1"
  local json_path="$2"
  if [[ -z "${json}" || -z "${json_path}" ]]; then
    return 1
  fi
  echo "${json}" | jq -r "${json_path}"
}

# /**
#  * @function json_set_value
#  * @description Modifies/adds a value at the specified JSON path.
#  * @param {string} json - JSON string.
#  * @param {string} path - jq path filter (e.g. '.user.age').
#  * @param {string} value - New value to set.
#  * @return {string} The modified JSON.
#  * @example
#  *   local new_json
#  *   new_json=$(json_set_value '{"name": "Bob"}' '.age' '30')
#  */
json_set_value() {
  local json="$1"
  local json_path="$2"
  local val="$3"
  
  if [[ -z "${json}" || -z "${json_path}" ]]; then
    return 1
  fi
  
  if echo "${val}" | jq -e . &>/dev/null; then
    echo "${json}" | jq --argjson val "${val}" "${json_path} = \$val"
  else
    echo "${json}" | jq --arg val "${val}" "${json_path} = \$val"
  fi
}

# /**
#  * @function json_delete_key
#  * @description Deletes a key/field at the specified JSON path.
#  * @param {string} json - JSON string.
#  * @param {string} path - jq path filter to delete (e.g. '.user.secret').
#  * @return {string} The modified JSON.
#  * @example
#  *   local cleaned
#  *   cleaned=$(json_delete_key '{"name": "Bob", "secret": "123"}' '.secret')
#  */
json_delete_key() {
  local json="$1"
  local json_path="$2"
  if [[ -z "${json}" || -z "${json_path}" ]]; then
    return 1
  fi
  echo "${json}" | jq "del(${json_path})"
}

# /**
#  * @function json_get_keys
#  * @description Gets all keys at the specified JSON path.
#  * @param {string} json - JSON string.
#  * @param {string} [path="."] - jq path filter.
#  * @return {string} JSON array of keys.
#  * @example
#  *   json_get_keys '{"name": "Bob", "age": 30}'
#  */
json_get_keys() {
  local json="$1"
  local json_path="${2:-.}"
  if [[ -z "${json}" ]]; then
    return 1
  fi
  echo "${json}" | jq "${json_path} | keys"
}

# /**
#  * @function json_merge
#  * @description Merges two JSON objects together.
#  * @param {string} json1 - First JSON object.
#  * @param {string} json2 - Second JSON object.
#  * @return {string} Merged JSON.
#  * @example
#  *   json_merge '{"a": 1}' '{"b": 2}'
#  */
json_merge() {
  local j1="$1"
  local j2="$2"
  if [[ -z "${j1}" || -z "${j2}" ]]; then
    return 1
  fi
  jq -n --argjson obj1 "${j1}" --argjson obj2 "${j2}" '$obj1 * $obj2'
}

# /**
#  * @function json_to_yaml
#  * @description Converts a JSON string to YAML format.
#  * @param {string} json - JSON string.
#  * @return {string} YAML format output.
#  * @example
#  *   json_to_yaml '{"name": "Bob", "age": 30}'
#  */
json_to_yaml() {
  local json="$1"
  if [[ -z "${json}" ]]; then
    return 1
  fi
  
  if command -v python3 &>/dev/null; then
    echo "${json}" | python3 -c 'import sys, json, yaml; print(yaml.dump(json.loads(sys.stdin.read())))' 2>/dev/null
    if (( $? == 0 )); then
      return 0
    fi
  fi
  
  echo "${json}" | jq -r 'to_entries | .[] | "\(.key): \(.value)"' 2>/dev/null
}

# /**
#  * @function json_validate
#  * @description Validates if a string is a syntactically correct JSON document.
#  * @param {string} json - JSON string to validate.
#  * @return {number} 0 if valid JSON, 1 otherwise.
#  * @example
#  *   if json_validate "${some_input}"; then
#  *     echo "JSON is valid"
#  *   fi
#  */
json_validate() {
  local json="$1"
  if [[ -z "${json}" ]]; then
    return 1
  fi
  echo "${json}" | jq -e . &>/dev/null
}

# /**
#  * @function json_beautify
#  * @description Formats a JSON string with pretty spacing/indentation.
#  * @param {string} json - JSON string.
#  * @return {string} Formatted JSON.
#  * @example
#  *   json_beautify '{"a":1}'
#  */
json_beautify() {
  local json="$1"
  if [[ -z "${json}" ]]; then
    return 1
  fi
  echo "${json}" | jq .
}

# /**
#  * @function json_escape
#  * @description Escapes a JSON string so it can be safely used in a string field.
#  * @param {string} json - JSON string.
#  * @return {string} Escaped JSON.
#  * @example
#  *   json_escape '{"name": "Bob"}'
#  */
json_escape() {
  local json="$1"
  if [[ -z "${json}" ]]; then
    return 1
  fi
  echo "${json}" | jq -R .
}

# /**
#  * @function json_array_add
#  * @description Appends an item to a JSON array at the specified path.
#  * @param {string} json - JSON string.
#  * @param {string} path - jq path to array (e.g. '.tags').
#  * @param {string} item - The value to append.
#  * @return {string} Modified JSON.
#  * @example
#  *   json_array_add '{"tags": ["a"]}' '.tags' '"b"'
#  */
json_array_add() {
  local json="$1"
  local json_path="$2"
  local item="$3"
  
  if [[ -z "${json}" || -z "${json_path}" ]]; then
    return 1
  fi
  
  if echo "${item}" | jq -e . &>/dev/null; then
    echo "${json}" | jq --argjson val "${item}" "${json_path} += [\$val]"
  else
    echo "${json}" | jq --arg val "${item}" "${json_path} += [\$val]"
  fi
}

# /**
#  * @function json_array_remove
#  * @description Removes an item from a JSON array by its index.
#  * @param {string} json - JSON string.
#  * @param {string} path - jq path to array.
#  * @param {number} index - Index of element to delete.
#  * @return {string} Modified JSON.
#  * @example
#  *   json_array_remove '{"tags": ["a", "b"]}' '.tags' 0
#  */
json_array_remove() {
  local json="$1"
  local json_path="$2"
  local index="$3"
  if [[ -z "${json}" || -z "${json_path}" || -z "${index}" ]]; then
    return 1
  fi
  echo "${json}" | jq "del(${json_path}[${index}])"
}

# /**
#  * @function json_extract_path
#  * @description Alias to json_get_value. Retrieves a value from a JSON path.
#  * @param {string} json - JSON string.
#  * @param {string} path - jq path.
#  * @return {string} Value at path.
#  * @example
#  *   json_extract_path '{"id": 1}' '.id'
#  */
json_extract_path() {
  json_get_value "$1" "$2"
}

# /**
#  * @function json_compact
#  * @description Compacts a JSON string, removing all non-essential formatting whitespace.
#  * @param {string} json - JSON string.
#  * @return {string} Compacted JSON.
#  * @example
#  *   json_compact '{\n  "a": 1\n}'
#  */
json_compact() {
  local json="$1"
  if [[ -z "${json}" ]]; then
    return 1
  fi
  echo "${json}" | jq -c .
}
