# functions/11-string.sh

# Protect against double sourcing
if [[ -n "${_STRING_SH_SOURCED:-}" ]]; then
  return 0
fi
readonly _STRING_SH_SOURCED=1

# Ensure config is sourced if available
if [[ -f "${PROJECT_ROOT:-.}/config/config.sh" ]]; then
  source "${PROJECT_ROOT:-.}/config/config.sh"
fi

# /**
#  * @function str_contains
#  * @description Checks if a substring is contained within a string.
#  * @param {string} str - The main string.
#  * @param {string} substr - The substring to search for.
#  * @return {number} 0 if contained, 1 otherwise.
#  * @example
#  *   if str_contains "hello world" "world"; then
#  *     echo "Found"
#  *   fi
#  */
str_contains() {
  local str="$1"
  local substr="$2"
  if [[ "${str}" == *"${substr}"* ]]; then
    return 0
  fi
  return 1
}

# /**
#  * @function str_starts_with
#  * @description Checks if a string starts with a specified prefix.
#  * @param {string} str - The main string.
#  * @param {string} prefix - The prefix.
#  * @return {number} 0 if matches, 1 otherwise.
#  * @example
#  *   if str_starts_with "http://google.com" "http://"; then
#  *     echo "Matches"
#  *   fi
#  */
str_starts_with() {
  local str="$1"
  local prefix="$2"
  if [[ "${str}" == "${prefix}"* ]]; then
    return 0
  fi
  return 1
}

# /**
#  * @function str_ends_with
#  * @description Checks if a string ends with a specified suffix.
#  * @param {string} str - The main string.
#  * @param {string} suffix - The suffix.
#  * @return {number} 0 if matches, 1 otherwise.
#  * @example
#  *   if str_ends_with "file.txt" ".txt"; then
#  *     echo "Matches"
#  *   fi
#  */
str_ends_with() {
  local str="$1"
  local suffix="$2"
  if [[ "${str}" == *"${suffix}" ]]; then
    return 0
  fi
  return 1
}

# /**
#  * @function str_replace
#  * @description Replaces all occurrences of a search term with a replacement term in a string.
#  * @param {string} str - The main string.
#  * @param {string} search - The term to search for.
#  * @param {string} replace - The replacement term.
#  * @return {string} The modified string.
#  * @example
#  *   local res
#  *   res=$(str_replace "hello world" "l" "x")
#  */
str_replace() {
  local str="$1"
  local search="$2"
  local replace="$3"
  echo "${str//${search}/${replace}}"
}

# /**
#  * @function str_replace_first
#  * @description Replaces only the first occurrence of a search term with a replacement term.
#  * @param {string} str - The main string.
#  * @param {string} search - The term to search for.
#  * @param {string} replace - The replacement term.
#  * @return {string} The modified string.
#  * @example
#  *   local res
#  *   res=$(str_replace_first "hello world" "l" "x")
#  */
str_replace_first() {
  local str="$1"
  local search="$2"
  local replace="$3"
  echo "${str/${search}/${replace}}"
}

# /**
#  * @function str_trim
#  * @description Trims leading and trailing whitespace from a string.
#  * @param {string} str - The string to trim.
#  * @return {string} The trimmed string.
#  * @example
#  *   local res
#  *   res=$(str_trim "   hello   ")
#  */
str_trim() {
  setopt localoptions extendedglob
  local val="$1"
  val="${val##[[:space:]]#}"
  val="${val%%[[:space:]]#}"
  echo "${val}"
}

# /**
#  * @function str_ltrim
#  * @description Trims leading whitespace from a string.
#  * @param {string} str - The string to trim.
#  * @return {string} The trimmed string.
#  * @example
#  *   local res
#  *   res=$(str_ltrim "   hello")
#  */
str_ltrim() {
  setopt localoptions extendedglob
  local val="$1"
  echo "${val##[[:space:]]#}"
}

# /**
#  * @function str_rtrim
#  * @description Trims trailing whitespace from a string.
#  * @param {string} str - The string to trim.
#  * @return {string} The trimmed string.
#  * @example
#  *   local res
#  *   res=$(str_rtrim "hello   ")
#  */
str_rtrim() {
  setopt localoptions extendedglob
  local val="$1"
  echo "${val%%[[:space:]]#}"
}

# /**
#  * @function str_split
#  * @description Splits a string by a delimiter and outputs each piece on a new line.
#  * @param {string} str - String to split.
#  * @param {string} delimiter - Splitting character/string.
#  * @return {string} Newline-separated tokens.
#  * @example
#  *   str_split "a,b,c" ","
#  */
str_split() {
  local str="$1"
  local delim="$2"
  local newline=$'\n'
  local replaced="${str//"$delim"/$newline}"
  local -a parts
  parts=( ${(f)replaced} )
  local p
  for p in "${parts[@]}"; do
    echo "${p}"
  done
}

# /**
#  * @function str_join
#  * @description Joins an array of strings or multiple arguments with the specified delimiter.
#  * @param {string} delimiter - The joining string.
#  * @param {string[]} args - The values to join.
#  * @return {string} The joined string.
#  * @example
#  *   local res
#  *   res=$(str_join "-" "a" "b" "c")
#  */
str_join() {
  local delim="$1"
  shift
  local -a args
  args=( "$@" )
  local IFS="${delim}"
  echo "${args[*]}"
}

# /**
#  * @function str_to_lower
#  * @description Converts a string to lowercase.
#  * @param {string} str - String.
#  * @return {string} Lowercase string.
#  * @example
#  *   str_to_lower "Hello"
#  */
str_to_lower() {
  local str="$1"
  echo "${str:l}"
}

# /**
#  * @function str_to_upper
#  * @description Converts a string to uppercase.
#  * @param {string} str - String.
#  * @return {string} Uppercase string.
#  * @example
#  *   str_to_upper "Hello"
#  */
str_to_upper() {
  local str="$1"
  echo "${str:u}"
}

# /**
#  * @function str_capitalize
#  * @description Capitalizes the first letter of each word in a string.
#  * @param {string} str - String.
#  * @return {string} Capitalized string.
#  * @example
#  *   str_capitalize "hello world"
#  */
str_capitalize() {
  local str="$1"
  echo "${(C)str}"
}

# /**
#  * @function str_reverse
#  * @description Reverses the character order of a string.
#  * @param {string} str - String.
#  * @return {string} Reversed string.
#  * @example
#  *   str_reverse "hello"
#  */
str_reverse() {
  local str="$1"
  local rev=""
  local i
  for (( i = ${#str}; i > 0; i-- )); do
    rev+="${str[i]}"
  done
  echo "${rev}"
}

# /**
#  * @function str_length
#  * @description Prints the character length of a string.
#  * @param {string} str - String.
#  * @return {number} String length.
#  * @example
#  *   str_length "hello"
#  */
str_length() {
  echo "${#1}"
}

# /**
#  * @function str_substring
#  * @description Returns a portion of a string starting at 0-based offset with specified length.
#  * @param {string} str - String.
#  * @param {number} offset - Start offset (0-based).
#  * @param {number} length - Substring length.
#  * @return {string} The substring.
#  * @example
#  *   str_substring "hello" 1 3
#  */
str_substring() {
  local str="$1"
  local offset="$2"
  local len="$3"
  echo "${str:$offset:$len}"
}

# /**
#  * @function str_pad_left
#  * @description Pads the left side of a string to a certain length with a padding string.
#  * @param {string} str - String.
#  * @param {number} len - Total padded length.
#  * @param {string} [pad=" "] - Padding character.
#  * @return {string} Padded string.
#  * @example
#  *   str_pad_left "42" 5 "0"
#  */
str_pad_left() {
  local str="$1"
  local len="$2"
  local pad="${3:- }"
  local pad_len=$(( len - ${#str} ))
  if (( pad_len <= 0 )); then
    echo "${str}"
    return 0
  fi
  local padding=""
  local i
  for (( i = 0; i < pad_len; i++ )); do
    padding+="${pad}"
  done
  echo "${padding:0:$pad_len}${str}"
}

# /**
#  * @function str_pad_right
#  * @description Pads the right side of a string to a certain length with a padding string.
#  * @param {string} str - String.
#  * @param {number} len - Total padded length.
#  * @param {string} [pad=" "] - Padding character.
#  * @return {string} Padded string.
#  * @example
#  *   str_pad_right "42" 5 "0"
#  */
str_pad_right() {
  local str="$1"
  local len="$2"
  local pad="${3:- }"
  local pad_len=$(( len - ${#str} ))
  if (( pad_len <= 0 )); then
    echo "${str}"
    return 0
  fi
  local padding=""
  local i
  for (( i = 0; i < pad_len; i++ )); do
    padding+="${pad}"
  done
  echo "${str}${padding:0:$pad_len}"
}

# /**
#  * @function str_escape
#  * @description Shell-escapes a string using Zsh quoting mechanics.
#  * @param {string} str - String.
#  * @return {string} Escaped string.
#  * @example
#  *   str_escape "hello 'world'"
#  */
str_escape() {
  local str="$1"
  echo "${(q)str}"
}

# /**
#  * @function str_unescape
#  * @description Unescapes a shell-escaped string.
#  * @param {string} str - Escaped string.
#  * @return {string} Unescaped string.
#  * @example
#  *   str_unescape "hello\\ \\'world\\'"
#  */
str_unescape() {
  local str="$1"
  echo "${(Q)str}"
}

# /**
#  * @function str_slugify
#  * @description Converts a string to a lowercase URL-safe slug representation.
#  * @param {string} str - String.
#  * @return {string} Slug string.
#  * @example
#  *   str_slugify "Hello, World! 2026"
#  */
str_slugify() {
  local str="${1:l}"
  str="${str//[^a-z0-9]/-}"
  while [[ "${str}" == *"--"* ]]; do
    str="${str//--/-}"
  done
  str="${str##-}"
  str="${str%%-}"
  echo "${str}"
}

# /**
#  * @function str_random
#  * @description Generates a random alphanumeric string of the specified length.
#  * @param {number} [len=16] - Output length.
#  * @return {string} Random string.
#  * @example
#  *   local secret
#  *   secret=$(str_random 32)
#  */
str_random() {
  local len="${1:-16}"
  if [[ -r /dev/urandom ]]; then
    tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c "${len}"
    echo ""
  else
    local chars="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local res=""
    local i
    for (( i = 0; i < len; i++ )); do
      local r=$(( RANDOM % ${#chars} + 1 ))
      res+="${chars[r]}"
    done
    echo "${res}"
  fi
}

# /**
#  * @function str_uuid
#  * @description Generates a standard UUID version 4 (all lowercase).
#  * @param None
#  * @return {string} UUID.
#  * @example
#  *   local id
#  *   id=$(str_uuid)
#  */
str_uuid() {
  if command -v uuidgen &>/dev/null; then
    uuidgen | tr '[:upper:]' '[:lower:]'
  else
    local r
    r=$(str_random 32)
    local hex="89ab"
    local variant_char="${hex[$(( RANDOM % 4 + 1 ))]}"
    printf "%s-%s-4%s-%s%s-%s\n" \
      "${r:0:8}" \
      "${r:8:4}" \
      "${r:13:3}" \
      "${variant_char}" \
      "${r:17:3}" \
      "${r:20:12}" | tr '[:upper:]' '[:lower:]'
  fi
}
