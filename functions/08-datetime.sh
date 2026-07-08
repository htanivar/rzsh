# functions/08-datetime.sh

# Protect against double sourcing
if [[ -n "${_DATETIME_SH_SOURCED:-}" ]]; then
  return 0
fi
readonly _DATETIME_SH_SOURCED=1

# Ensure config is sourced if available
if [[ -f "${PROJECT_ROOT:-.}/config/config.sh" ]]; then
  source "${PROJECT_ROOT:-.}/config/config.sh"
fi

# Load Zsh datetime module if available
zmodload zsh/datetime 2>/dev/null

# /**
#  * @function timestamp
#  * @description Outputs the current date and time formatted according to TIMESTAMP_FORMAT.
#  * @param None
#  * @return {string} The formatted timestamp.
#  * @example
#  *   local ts
#  *   ts=$(timestamp)
#  */
timestamp() {
  if typeset -f strftime >/dev/null || [[ -n "${EPOCHSECONDS:-}" ]]; then
    strftime "${TIMESTAMP_FORMAT:-%Y-%m-%d %H:%M:%S}" "${EPOCHSECONDS}"
  else
    date +"${TIMESTAMP_FORMAT:-%Y-%m-%d %H:%M:%S}"
  fi
}

# /**
#  * @function date_now
#  * @description Outputs the current date formatted according to DATE_FORMAT.
#  * @param None
#  * @return {string} The formatted date.
#  * @example
#  *   local dt
#  *   dt=$(date_now)
#  */
date_now() {
  if typeset -f strftime >/dev/null || [[ -n "${EPOCHSECONDS:-}" ]]; then
    strftime "${DATE_FORMAT:-%Y-%m-%d}" "${EPOCHSECONDS}"
  else
    date +"${DATE_FORMAT:-%Y-%m-%d}"
  fi
}

# /**
#  * @function parse_date
#  * @description Parses a date string and prints its representation in epoch seconds.
#  * @param {string} date_string - The date string to parse.
#  * @return {number} Epoch seconds.
#  * @example
#  *   local epoch
#  *   epoch=$(parse_date "2026-07-08 12:00:00")
#  */
parse_date() {
  local date_str="$1"
  if [[ -z "${date_str}" ]]; then
    return 1
  fi
  # GNU date (Linux)
  if date -d "${date_str}" +%s &>/dev/null; then
    date -d "${date_str}" +%s
    return 0
  fi
  # BSD/macOS date
  if date -j -f "%Y-%m-%d %H:%M:%S" "${date_str}" +%s &>/dev/null; then
    date -j -f "%Y-%m-%d %H:%M:%S" "${date_str}" +%s
    return 0
  fi
  if date -j -f "%Y-%m-%d" "${date_str}" +%s &>/dev/null; then
    date -j -f "%Y-%m-%d" "${date_str}" +%s
    return 0
  fi
  if date -j "${date_str}" +%s &>/dev/null; then
    date -j "${date_str}" +%s
    return 0
  fi
  return 1
}

# /**
#  * @function _duration_to_seconds
#  * @description Internal helper that converts a duration string (e.g. "2 days", "3 hours") to seconds.
#  * @param {string} duration - Duration string.
#  * @return {number} Seconds representation.
#  */
_duration_to_seconds() {
  local dur="$1"
  local amount
  local unit
  local -a parts
  parts=( ${(s: :)dur} )
  
  amount="${parts[1]}"
  unit="${parts[2]:l}"
  
  if [[ -z "${amount}" || ! "${amount}" =~ ^[0-9]+$ ]]; then
    return 1
  fi

  local mult=1
  case "${unit}" in
    second|seconds|sec|secs|s) mult=1 ;;
    minute|minutes|min|mins|m) mult=60 ;;
    hour|hours|h)              mult=3600 ;;
    day|days|d)                mult=86400 ;;
    week|weeks|w)              mult=604800 ;;
    *)                         return 1 ;;
  esac
  
  echo $(( amount * mult ))
}

# /**
#  * @function date_add
#  * @description Adds a duration (e.g., "1 day", "2 hours") to a starting date-time.
#  * @param {string} date - Starting date string.
#  * @param {string} duration - Duration string to add.
#  * @return {string} Resulting date string in YYYY-MM-DD HH:MM:SS format.
#  * @example
#  *   local future
#  *   future=$(date_add "2026-07-08 12:00:00" "2 days")
#  */
date_add() {
  local dt="$1"
  local dur="$2"
  local epoch
  epoch=$(parse_date "${dt}") || return 1
  local secs
  secs=$(_duration_to_seconds "${dur}") || return 1
  local new_epoch=$(( epoch + secs ))
  strftime "%Y-%m-%d %H:%M:%S" "${new_epoch}"
}

# /**
#  * @function date_subtract
#  * @description Subtracts a duration (e.g., "1 day", "2 hours") from a starting date-time.
#  * @param {string} date - Starting date string.
#  * @param {string} duration - Duration string to subtract.
#  * @return {string} Resulting date string in YYYY-MM-DD HH:MM:SS format.
#  * @example
#  *   local past
#  *   past=$(date_subtract "2026-07-08 12:00:00" "1 hour")
#  */
date_subtract() {
  local dt="$1"
  local dur="$2"
  local epoch
  epoch=$(parse_date "${dt}") || return 1
  local secs
  secs=$(_duration_to_seconds "${dur}") || return 1
  local new_epoch=$(( epoch - secs ))
  strftime "%Y-%m-%d %H:%M:%S" "${new_epoch}"
}

# /**
#  * @function date_diff
#  * @description Calculates the difference (in seconds) between two dates.
#  * @param {string} date1 - First date.
#  * @param {string} date2 - Second date.
#  * @return {number} Difference in seconds.
#  * @example
#  *   local diff
#  *   diff=$(date_diff "2026-07-08 12:00:00" "2026-07-08 12:01:30")
#  */
date_diff() {
  local dt1="$1"
  local dt2="$2"
  local ep1
  ep1=$(parse_date "${dt1}") || return 1
  local ep2
  ep2=$(parse_date "${dt2}") || return 1
  echo $(( ep1 > ep2 ? ep1 - ep2 : ep2 - ep1 ))
}

# /**
#  * @function date_format
#  * @description Formats a date string using the specified format.
#  * @param {string} date - The date to format.
#  * @param {string} format - Strftime format string.
#  * @return {string} Formatted date.
#  * @example
#  *   date_format "2026-07-08" "%A, %B %d, %Y"
#  */
date_format() {
  local dt="$1"
  local fmt="$2"
  local epoch
  epoch=$(parse_date "${dt}") || return 1
  strftime "${fmt}" "${epoch}"
}

# /**
#  * @function timezone_convert
#  * @description Converts a date string from one timezone to another.
#  * @param {string} date - The date string.
#  * @param {string} from_tz - Source timezone (e.g. UTC, America/New_York).
#  * @param {string} to_tz - Destination timezone.
#  * @return {string} Converted date in YYYY-MM-DD HH:MM:SS format.
#  * @example
#  *   timezone_convert "2026-07-08 12:00:00" "UTC" "America/New_York"
#  */
timezone_convert() {
  local dt="$1"
  local from_tz="$2"
  local to_tz="$3"
  TZ="${to_tz}" date -d "TZ=\"${from_tz}\" ${dt}" +"%Y-%m-%d %H:%M:%S" 2>/dev/null
}

# /**
#  * @function is_valid_date
#  * @description Checks if a date string is parseable and valid.
#  * @param {string} date - Date string.
#  * @return {number} 0 if valid, 1 otherwise.
#  * @example
#  *   if is_valid_date "2026-02-30"; then
#  *     echo "Valid"
#  *   fi
#  */
is_valid_date() {
  parse_date "$1" &>/dev/null
}

# /**
#  * @function date_range
#  * @description Prints a range of dates from start to end with the specified interval.
#  * @param {string} start - Start date.
#  * @param {string} end - End date.
#  * @param {string} [interval="1 day"] - Interval duration string.
#  * @return {string} Newline-separated list of dates.
#  * @example
#  *   date_range "2026-07-01" "2026-07-05" "1 day"
#  */
date_range() {
  local start="$1"
  local end="$2"
  local interval="${3:-1 day}"
  
  local start_ep
  start_ep=$(parse_date "${start}") || return 1
  local end_ep
  end_ep=$(parse_date "${end}") || return 1
  local step
  step=$(_duration_to_seconds "${interval}") || return 1
  
  local curr="${start_ep}"
  while (( curr <= end_ep )); do
    strftime "%Y-%m-%d" "${curr}"
    (( curr += step ))
  done
}

# /**
#  * @function format_duration
#  * @description Formats a number of seconds into a human-readable duration (e.g., 2h 15m 5s).
#  * @param {number} seconds - Number of seconds.
#  * @return {string} Human-readable duration.
#  * @example
#  *   format_duration 8130
#  */
format_duration() {
  local secs="$1"
  if [[ -z "${secs}" || ! "${secs}" =~ ^[0-9]+$ ]]; then
    return 1
  fi
  local h=$(( secs / 3600 ))
  local m=$(( (secs % 3600) / 60 ))
  local s=$(( secs % 60 ))
  
  local result=""
  if (( h > 0 )); then
    result+="${h}h "
  fi
  if (( m > 0 || h > 0 )); then
    result+="${m}m "
  fi
  result+="${s}s"
  echo "${result}"
}
