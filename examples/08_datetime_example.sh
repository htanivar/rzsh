#!/usr/bin/env zsh
# examples/08_datetime_example.sh
# Non-technical guide to calendar dates, conversions, and timestamps.
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

if [[ -z "${RZSH_DIR:-}" ]]; then
  printf '[WARN] RZSH_DIR is not set. Please set export RZSH_DIR="%s" in your environment (e.g., ~/.zshrc).\n' "${0:A:h:h}" >&2
  export RZSH_DIR="${0:A:h:h}"
fi

source "${RZSH_DIR}/config/config.sh"
init_config

# 1. Get current Unix timestamp
now=$(timestamp)
echo "Current Unix Epoch seconds: ${now}"

# 2. Get current calendar date
today=$(date_now)
echo "Current Date: ${today}"

# 3. Convert calendar date to epoch seconds
epoch=$(parse_date "2026-07-08 12:00:00")
echo "Parsed date '2026-07-08 12:00:00' to seconds: ${epoch}"

# 4. Date calculations (Add days/hours)
next_week=$(date_add "${today}" 7 "days")
yesterday=$(date_subtract "${today}" 1 "days")
echo "Yesterday was: ${yesterday}"
echo "Next week:     ${next_week}"

# 5. Time differences
seconds=$(date_diff "2026-07-01 12:00:00" "2026-07-08 12:00:00")
echo "Seconds between July 1 and July 8: ${seconds}"

# 6. Format duration
duration=$(format_duration 7300)
echo "Formatted 7300 seconds to duration: ${duration}"

# 7. Print date range
echo "Date Range list:"
date_range "2026-07-01" "2026-07-04"
