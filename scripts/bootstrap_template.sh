#!/usr/bin/env zsh
# scripts/04-git/bootstrap_template.sh
# Template script to bootstrap framework functions, request credentials, and record evidence.

# Resolve PROJECT_ROOT dynamically by searching upwards for config/config.sh
if [[ -z "${PROJECT_ROOT:-}" ]]; then
  local current_dir="${0:A:h}"
  while [[ "${current_dir}" != "/" ]]; do
    if [[ -f "${current_dir}/config/config.sh" ]]; then
      export PROJECT_ROOT="${current_dir}"
      break
    fi
    current_dir="${current_dir:h}"
  done
fi

# Source framework config and functions
source "${PROJECT_ROOT}/config/config.sh"
init_config || {
  printf "Error: Failed to initialize framework configuration.\n" >&2
  exit 1
}

# Ensure required modules are sourced (validation, user-actions, errors, evidences)
for mod in 02-errors 04-validation 07-user-actions 99-evidences; do
  if [[ -f "${PROJECT_ROOT}/functions/${mod}.sh" ]]; then
    source "${PROJECT_ROOT}/functions/${mod}.sh"
  fi
done

log_section "Credentials Setup & Evidence Logging"

# 1. Prompt for User Input using framework functions
local username
local password

username=$(read_input "Enter Username")
password=$(read_password "Enter Password")

# Validate input
validate_required "${username}" "Username must not be empty" || error_exit "Username validation failed" 1
validate_required "${password}" "Password must not be empty" || error_exit "Password validation failed" 1

# Create a masked password for printing/logging
local masked_pass
masked_pass="${(l:${#password}::*:)}" # Zsh string padding to match length with '*'

log_info "Credentials captured successfully (User: ${username}, Password: ${masked_pass})"

# 2. Initialize and Record Evidence
log_info "Initializing evidence collection session..."
init_evidence || error_exit "Failed to initialize evidence tracking" 1

# Collect standard environment & script metadata
collect_environment_evidence
collect_script_evidence "$@"

# Generate a custom user input markdown evidence file
local evidence_file="${CURRENT_EVIDENCE_DIR}/user_credentials_evidence.md"
local evidence_content="
# User Input & Execution Evidence

- **Execution Date:** $(date)
- **Script Location:** \`${0:A}\`
- **Captured Username:** \`${username}\`
- **Password Length:** ${#password} chars
- **Masked Password:** \`${masked_pass}\`
"

# Write the custom evidence
printf "%b" "${evidence_content}" > "${evidence_file}"

# Log to metadata session tracker (standard project practice)
if typeset -f _add_evidence_file >/dev/null; then
  _add_evidence_file "user_credentials_evidence.md" "user_credentials"
fi

log_info "Custom user input evidence successfully generated."
log_info "Evidence Directory: ${CURRENT_EVIDENCE_DIR:A}"
log_info "Evidence File:      ${evidence_file:A}"

# Optional: consolidate and build a unified markdown report
if typeset -f generate_evidence_report >/dev/null; then
  generate_evidence_report >/dev/null
  log_info "Unified report compiled at: ${CURRENT_EVIDENCE_DIR}/report.md"
fi

exit 0
