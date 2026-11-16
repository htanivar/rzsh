#!/usr/bin/env zsh
# examples/99_evidences_example.sh
# Breadcrumb: README.md -> GLOSSARY.md -> docs/99-evidences.md -> examples/99_evidences_example.sh -> tests/99-evidences.test.sh
# Non-technical, copy-paste guide to capturing audit evidence:
#   - Mirroring console output and log files identically
#   - Capturing HTTP API request/response outputs (with sensitive data masked)
#   - Recording what a function did step-by-step
#   - Generating a Markdown report and .tar.gz evidence bundle
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

if [[ -z "${RZSH_DIR:-}" ]]; then
  printf '[WARN] RZSH_DIR is not set. Please set export RZSH_DIR="%s" in your environment (e.g., ~/.zshrc).\n' "${0:A:h:h}" >&2
  export RZSH_DIR="${0:A:h:h}"
fi

source "${RZSH_DIR}/config/config.sh"
init_config

# ==============================================================================
# 1. Initialize Logging + Evidence Session
#    init_logging creates ${CURRENT_LOG_FILE} so log_info / log_steps / log_command
#    automatically write the exact same messages to BOTH the console and log file.
# ==============================================================================
init_logging
init_evidence

log_section "Evidence Capture Walkthrough"
log_info "Console and log file are both writing to: ${CURRENT_LOG_FILE}"
log_info "Evidence session folder: ${CURRENT_EVIDENCE_DIR}"

# ==============================================================================
# 2. Capture System, Network, Git & Script Context
# ==============================================================================
log_steps "Collecting baseline system, network, git, and script metadata..."
collect_environment_evidence
collect_network_evidence
collect_git_evidence
collect_script_evidence "$@"

# ==============================================================================
# 3. Redirect & Capture HTTP Call Output (with Token Masking)
#    Tip: Use mock_http_response for offline demos, or call real endpoints.
# ==============================================================================
log_steps "Calling health-check API and saving HTTP response as evidence..."
mock_http_response '{"service":"billing-api","status":"healthy","token":"secret-12345"}' 200

http_res=$(http_get "https://api.example.com/health")
http_code=$(check_status_code "${http_res}")
http_body=$(http_get_body "${http_res}")

# Mask sensitive fields before saving to logs or evidence
safe_body=$(mask_json_fields "${http_body}" "token")
log_info "HTTP Status: ${http_code}"
log_info "HTTP Body (masked): ${safe_body}"

# Redirect HTTP output into an evidence artifact file
http_out_file="${CURRENT_EVIDENCE_DIR}/http_health_response.json"
printf '%s\n' "${safe_body}" > "${http_out_file}"
collect_file_evidence "${http_out_file}"

mock_restore "curl"

# ==============================================================================
# 4. Capture What a Function Did (Audit Trail Pattern)
#    Wrap your task in a function that logs steps and records a JSON summary.
# ==============================================================================
run_audited_task() {
  local target_env="$1"
  log_steps "Running audited task for environment: ${target_env}"

  # log_command runs a command and logs BOTH its output and exit code to console + log file
  log_command "uname -a"
  local cmd_rc=$?

  # Save structured outcome of what this function did
  local summary_json
  summary_json=$(printf '{"task":"run_audited_task","environment":"%s","http_status":"%s","command_exit_code":%d}' \
    "${target_env}" "${http_code}" "${cmd_rc}")
  collect_custom_evidence "${summary_json}"
}

run_audited_task "staging"

# ==============================================================================
# 5. Attach the Console/Execution Log File Itself to Evidence
#    Because log_info / log_steps / log_command wrote to ${CURRENT_LOG_FILE},
#    attaching it preserves an exact copy of everything shown on the console.
# ==============================================================================
log_steps "Attaching execution log file to evidence bundle..."
if [[ -f "${CURRENT_LOG_FILE}" ]]; then
  cp "${CURRENT_LOG_FILE}" "${CURRENT_EVIDENCE_DIR}/execution.log"
  collect_file_evidence "${CURRENT_EVIDENCE_DIR}/execution.log"
fi

# ==============================================================================
# 6. Generate Markdown Report, Validate JSON & Create Compressed Archive
# ==============================================================================
log_steps "Generating consolidated report and archive..."
generate_evidence_report > /dev/null
log_info "Markdown report written to: ${CURRENT_EVIDENCE_DIR}/report.md"

consolidated_json=$(evidence_to_json)
if evidence_validate "${consolidated_json}"; then
  log_info "Evidence metadata validated successfully."
fi

archive=$(evidence_archive)
log_info "Archived evidence bundle: ${archive}"
