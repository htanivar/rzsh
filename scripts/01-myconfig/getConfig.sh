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

# Dynamically detect variables set/exported in config.sh
local -a framework_vars
local parse_line parse_var
while IFS= read -r parse_line || [[ -n "${parse_line}" ]]; do
  if [[ "${parse_line}" =~ "^[[:space:]]*export[[:space:]]+([A-Z][A-Z0-9_]*)[[:space:]]*$" ]]; then
    framework_vars+=("${match[1]}")
  elif [[ "${parse_line}" =~ "^[[:space:]]*([A-Z][A-Z0-9_]*)=.*$" ]]; then
    parse_var="${match[1]}"
    if [[ "${parse_var}" != "PATH" ]]; then
      framework_vars+=("${parse_var}")
    fi
  fi
done < "${PROJECT_ROOT}/config/config.sh"
framework_vars=( ${(u)framework_vars} )


URL="${1:-}"

# If no URL parameter is provided, simply list the config variables and create the evidence
if [[ -z "${URL}" ]]; then
  local body='{}'
  local v
  for v in "${framework_vars[@]}"; do
    body=$(json_set_value "${body}" ".${v}" "${(P)v}")
  done

  # Output the configuration JSON to stdout
  echo "${body}"

  # Determine evidence file path with timestamp folder in DDMMYYYY_HHMMSS format
  local ts
  ts=$(date +"%d%m%Y_%H%M%S")
  local ev_dir="${EVIDENCE_DIR}/${ts}"
  local ev_file="${ev_dir}/evidence.md"

  # Write to the evidence file
  local ev_title="# Test Execution Evidence"
  local ev_content="
## Configuration Variables Set (Run without URL)

* **Timestamp:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")

\`\`\`json
$(json_beautify "${body}")
\`\`\`
"
  mkdir -p "${ev_dir}"
  file_write "${ev_file}" "${ev_title}${ev_content}"

  log_info "Configuration listed and logged to evidence: ${ev_file}"
  exit 0
fi

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

# Append framework configuration parameters dynamically from config.sh
  local v
  for v in "${framework_vars[@]}"; do
    body=$(json_set_value "${body}" ".${v}" "${(P)v}")
  done

# Output the valid JSON to stdout
echo "${body}"
