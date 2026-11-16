# functions/16-mask.sh

# Protect against double sourcing
if [[ -n "${_MASK_SH_SOURCED:-}" ]]; then
  return 0
fi
readonly _MASK_SH_SOURCED=1

# Ensure config is sourced if available
if [[ -f "${RZSH_DIR:-${PROJECT_ROOT:-.}}/config/config.sh" ]]; then
  source "${RZSH_DIR:-${PROJECT_ROOT:-.}}/config/config.sh"
fi

# Internal helper: repeat a single character N times
_mask_repeat_char() {
  local char="${1:-*}"
  local count="${2:-0}"
  (( count <= 0 )) && return 0
  printf "%${count}s" "" | tr ' ' "${char:0:1}"
}

# Internal helper: mask all digits in a string except the last N digits, preserving separators
_mask_keep_last_digits() {
  local input="$1"
  local visible="${2:-4}"
  local mask_char="${3:-*}"
  mask_char="${mask_char:0:1}"

  local digits_only="${input//[^0-9]/}"
  local total_digits="${#digits_only}"
  local mask_digits=$(( total_digits - visible ))

  local out=""
  local i ch seen_digits=0
  for (( i = 1; i <= ${#input}; i++ )); do
    ch="${input[$i]}"
    if [[ "${ch}" == [0-9] ]]; then
      (( seen_digits++ ))
      if (( seen_digits <= mask_digits )); then
        out+="${mask_char}"
      else
        out+="${ch}"
      fi
    else
      out+="${ch}"
    fi
  done
  printf '%s\n' "${out}"
}

# /**
#  * @function mask_string
#  * @description Masks the middle portion of a string, keeping a specified number of leading and trailing characters visible.
#  * @param {string} str - The input string to mask.
#  * @param {number} [visible_start=2] - Number of leading characters to keep visible.
#  * @param {number} [visible_end=2] - Number of trailing characters to keep visible.
#  * @param {string} [mask_char="*"] - Character used for masking.
#  * @return {string} The masked string.
#  * @example
#  *   mask_string "my-secret-value" 2 2
#  */
mask_string() {
  local str="$1"
  local visible_start="${2:-2}"
  local visible_end="${3:-2}"
  local mask_char="${4:-*}"
  mask_char="${mask_char:0:1}"

  local len="${#str}"
  if (( len == 0 )); then
    printf '\n'
    return 0
  fi

  if (( len <= visible_start + visible_end )); then
    _mask_repeat_char "${mask_char}" "${len}"
    printf '\n'
    return 0
  fi

  local mask_len=$(( len - visible_start - visible_end ))
  local prefix=""
  local suffix=""
  (( visible_start > 0 )) && prefix="${str[1,${visible_start}]}"
  (( visible_end > 0 )) && suffix="${str[-${visible_end},-1]}"

  printf '%s%s%s\n' "${prefix}" "$(_mask_repeat_char "${mask_char}" "${mask_len}")" "${suffix}"
}

# /**
#  * @function mask_token
#  * @description Masks an API token, Bearer secret, or key, keeping only the first and last N characters visible.
#  * @param {string} token - The token or secret string to mask.
#  * @param {number} [visible_chars=4] - Number of characters to keep visible at each end.
#  * @param {string} [mask_char="*"] - Character used for masking.
#  * @return {string} The masked token.
#  * @example
#  *   mask_token "hvs.CAESIJ1234567890abcdef" 4
#  */
mask_token() {
  local token="$1"
  local visible="${2:-4}"
  local mask_char="${3:-*}"
  mask_string "${token}" "${visible}" "${visible}" "${mask_char}"
}

# /**
#  * @function mask_email
#  * @description Masks the local part of an email address while preserving the first character and domain.
#  * @param {string} email - The email address to mask.
#  * @param {string} [mask_char="*"] - Character used for masking.
#  * @return {string} The masked email address.
#  * @example
#  *   mask_email "alice.smith@example.com"
#  */
mask_email() {
  local email="$1"
  local mask_char="${2:-*}"
  mask_char="${mask_char:0:1}"

  if [[ "${email}" != *@* ]]; then
    mask_string "${email}" 1 0 "${mask_char}"
    return 0
  fi

  local local_part="${email%%@*}"
  local domain="${email#*@}"
  local masked_local
  if (( ${#local_part} <= 1 )); then
    masked_local="${mask_char}"
  else
    masked_local="${local_part[1]}$(_mask_repeat_char "${mask_char}" $(( ${#local_part} - 1 )))"
  fi
  printf '%s@%s\n' "${masked_local}" "${domain}"
}

# /**
#  * @function mask_phone
#  * @description Masks all digits in a phone number except the last N digits, preserving formatting characters.
#  * @param {string} phone - The phone number to mask.
#  * @param {number} [visible_digits=4] - Number of trailing digits to keep visible.
#  * @param {string} [mask_char="*"] - Character used for masking.
#  * @return {string} The masked phone number.
#  * @example
#  *   mask_phone "+1-555-123-4567" 4
#  */
mask_phone() {
  _mask_keep_last_digits "$1" "${2:-4}" "${3:-*}"
}

# /**
#  * @function mask_card
#  * @description Masks a payment card number, keeping only the last N digits visible while preserving separators.
#  * @param {string} card_number - The card number to mask.
#  * @param {number} [visible_digits=4] - Number of trailing digits to keep visible.
#  * @param {string} [mask_char="*"] - Character used for masking.
#  * @return {string} The masked card number.
#  * @example
#  *   mask_card "4111-1111-1111-1234" 4
#  */
mask_card() {
  _mask_keep_last_digits "$1" "${2:-4}" "${3:-*}"
}

# /**
#  * @function mask_json_fields
#  * @description Masks specified sensitive fields (recursively) in a JSON string using jq.
#  * @param {string} json_str - The input JSON string.
#  * @param {string} fields_csv - Comma-separated list of JSON field names to mask (e.g., "password,token,secret").
#  * @param {string} [mask_value="***MASKED***"] - Replacement value for masked fields.
#  * @return {string} JSON string with specified fields masked, or 1 if jq is unavailable or JSON is invalid.
#  * @example
#  *   mask_json_fields '{"user":"alice","token":"abc123"}' "token,password"
#  */
mask_json_fields() {
  local json_str="$1"
  local fields_csv="$2"
  local mask_value="${3:-***MASKED***}"

  if ! command -v jq >/dev/null 2>&1; then
    return 1
  fi

  jq -c --arg fields "${fields_csv}" --arg mask "${mask_value}" '
    ($fields | split(",") | map(gsub("^\\s+|\\s+$"; ""))) as $keys |
    walk(
      if type == "object" then
        with_entries(if (.key as $k | $keys | index($k)) then .value = $mask else . end)
      else
        .
      end
    )
  ' <<< "${json_str}" 2>/dev/null
}

# /**
#  * @function mask_env_line
#  * @description Masks sensitive KEY=VALUE or "Header: Value" lines when the key matches any sensitive keyword.
#  * @param {string} line - Input line (e.g., "API_TOKEN=secret123" or "Authorization: Bearer xyz").
#  * @param {string} [sensitive_keys_csv="PASSWORD,SECRET,TOKEN,KEY,AUTH"] - Comma-separated case-insensitive keywords.
#  * @param {string} [mask_value="***MASKED***"] - Replacement value when masked.
#  * @return {string} The masked line if sensitive, or the original line unchanged.
#  * @example
#  *   mask_env_line "DB_PASSWORD=supersecret"
#  */
mask_env_line() {
  local line="$1"
  local sensitive_csv="${2:-PASSWORD,SECRET,TOKEN,KEY,AUTH}"
  local mask_value="${3:-***MASKED***}"

  local sep="" key=""
  if [[ "${line}" == *=* ]]; then
    sep="="
    key="${line%%=*}"
  elif [[ "${line}" == *:* ]]; then
    sep=": "
    key="${line%%:*}"
  else
    printf '%s\n' "${line}"
    return 0
  fi

  local key_upper="${key:u}"
  local -a keywords
  keywords=("${(@s:,:)sensitive_csv}")

  local kw
  for kw in "${keywords[@]}"; do
    kw="${kw#"${kw%%[![:space:]]*}"}"
    kw="${kw%"${kw##*[![:space:]]}"}"
    [[ -z "${kw}" ]] && continue
    if [[ "${key_upper}" == *"${kw:u}"* ]]; then
      printf '%s%s%s\n' "${key}" "${sep}" "${mask_value}"
      return 0
    fi
  done

  printf '%s\n' "${line}"
}
