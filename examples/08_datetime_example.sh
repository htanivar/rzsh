#!/usr/bin/env zsh
# examples/08_datetime_example.sh
# Non-technical guide to calendar dates, conversions, and timestamps.

source "$(dirname "$0")/../config/config.sh"
init_config

# 1. Get current Unix timestamp
local now=$(timestamp)
echo "Current Unix Epoch seconds: ${now}"

# 2. Get current calendar date
local today=$(date_now)
echo "Current Date: ${today}"

# 3. Convert calendar date to epoch seconds
local epoch=$(parse_date "2026-07-08 12:00:00")
echo "Parsed date '2026-07-08 12:00:00' to seconds: ${epoch}"

# 4. Date calculations (Add days/hours)
local next_week=$(date_add "${today}" 7 "days")
local yesterday=$(date_subtract "${today}" 1 "days")
echo "Yesterday was: ${yesterday}"
echo "Next week:     ${next_week}"

# 5. Time differences
local seconds=$(date_diff "2026-07-01 12:00:00" "2026-07-08 12:00:00")
echo "Seconds between July 1 and July 8: ${seconds}"

# 6. Format duration
local duration=$(format_duration 7300)
echo "Formatted 7300 seconds to duration: ${duration}"

# 7. Print date range
echo "Date Range list:"
date_range "2026-07-01" "2026-07-04"
