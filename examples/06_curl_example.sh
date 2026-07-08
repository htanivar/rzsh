#!/usr/bin/env zsh
# examples/06_curl_example.sh
# Non-technical guide to internet queries, api checks, and auto-retries.

source "$(dirname "$0")/../config/config.sh"
init_config

echo "Connecting to public API..."

# 1. HTTP GET request (returns body + code)
local response=$(http_get "https://httpbin.org/get")
local code=$(check_status_code "${response}")

echo "HTTP Response Status Code: ${code}"

# 2. Verify JSON format
if is_json_response "${response}"; then
  echo "API returned a valid JSON document."
  
  # Extract specific property
  local user_agent=$(extract_json_field "${response}" ".headers.User-Agent")
  echo "Your browser agent was logged as: ${user_agent}"
fi

# 3. Automated retry get request
echo "Testing request retry on mock url..."
http_get_with_retry "https://httpbin.org/status/200" 3
