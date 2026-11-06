#!/usr/bin/env zsh
# scripts/04-git/bootstrap_template.sh
# Template script to bootstrap framework functions, request credentials, and record evidence.
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

# Advise if RZSH_DIR is not set, and fallback to local framework directory
if [[ -z "${RZSH_DIR:-}" ]]; then
  printf '[WARN] RZSH_DIR is not set. Please set export RZSH_DIR="%s" in your environment (e.g., ~/.zshrc).\n' "${0:A:h:h}" >&2
  export RZSH_DIR="${0:A:h:h}"
fi

# Source framework config and functions via RZSH_DIR
source "${RZSH_DIR}/config/config.sh"
init_config || {
  printf "Error: Failed to initialize framework configuration.\n" >&2
  exit 1
}

log_section "Credentials Setup & Evidence Logging"

# 1. Prompt for User Input using framework functions
username=$(read_input "Enter Username")
password=$(read_password "Enter Password")

# Validate input
validate_required "${username}" "Username must not be empty" || error_exit "Username validation failed" 1
validate_required "${password}" "Password must not be empty" || error_exit "Password validation failed" 1

# Create a masked password for printing/logging
masked_pass="${(l:${#password}::*:)}" # Zsh string padding to match length with '*'

log_info "Credentials captured successfully (User: ${username}, Password: ${masked_pass})"

# 2. Initialize and Record Evidence
log_info "Initializing evidence collection session..."
init_evidence || error_exit "Failed to initialize evidence tracking" 1

# Collect standard environment & script metadata
collect_environment_evidence
collect_script_evidence "$@"

# Generate a custom user input markdown evidence file
evidence_file="${CURRENT_EVIDENCE_DIR}/user_credentials_evidence.md"
evidence_content="
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
