#!/usr/bin/env zsh
# scripts/01-myconfig/getConfig.sh
# Retrieves the configuration JSON from the specified URL using framework functions.

# Resolve PROJECT_ROOT if not set
if [[ -z "${PROJECT_ROOT:-}" ]]; then
  export PROJECT_ROOT="${0:A:h:h:h}"
fi

# Source framework config and functions
source "${PROJECT_ROOT}/config/config.sh"
init_config

URL="${1:-}"
validate_required "${URL}" "URL parameter is required" || error_exit "Usage: $0 <config_url>"

# Perform the HTTP GET call using framework utility
res=$(http_get "${URL}")
http_status=$(check_status_code "${res}")
body=$(http_get_body "${res}")

# Check HTTP status code
if [[ "${http_status}" -ne 200 ]]; then
  error_exit "Failed to fetch config from ${URL} (HTTP Status: ${http_status}). Response: ${body}"
fi

# Validate response is valid JSON
validate_json "${body}" || error_exit "Response is not valid JSON"

# Validate response keys AUTH_URL and ROLE_NAME exist
auth_url=$(json_get_value "${body}" ".AUTH_URL")
role_name=$(json_get_value "${body}" ".ROLE_NAME")

validate_required "${auth_url}" "Missing AUTH_URL in config JSON" || error_exit "Config is missing AUTH_URL"
validate_required "${role_name}" "Missing ROLE_NAME in config JSON" || error_exit "Config is missing ROLE_NAME"

# Output the valid JSON to stdout
echo "${body}"
