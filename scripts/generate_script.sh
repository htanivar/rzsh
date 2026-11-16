#!/usr/bin/env zsh
# scripts/generate_script.sh
# Interactive step-by-step script generator for non-technical users.
# Generates a production-ready Zsh script backed by the rzsh framework.
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

if [[ -z "${RZSH_DIR:-}" ]]; then
  printf '[WARN] RZSH_DIR is not set. Please set export RZSH_DIR="%s" in your environment (e.g., ~/.zshrc).\n' "${0:A:h:h}" >&2
  export RZSH_DIR="${0:A:h:h}"
fi

source "${RZSH_DIR}/config/config.sh"
init_config || {
  printf "Error: Failed to initialize framework configuration.\n" >&2
  exit 1
}
init_logging

# Sanitize a human-readable label into a lowercase underscore identifier
_slugify() {
  local raw="${1:l}"
  raw="${raw//[^a-z0-9]/_}"
  while [[ "${raw}" == *__* ]]; do
    raw="${raw//__/_}"
  done
  raw="${raw#_}"
  raw="${raw%_}"
  echo "${raw:-step}"
}

# Normalize script filename (ensure .sh extension and safe characters)
_normalize_script_filename() {
  local name="$1"
  name="${name%.sh}"
  name="${name// /-}"
  name="${name//[^A-Za-z0-9._-]/}"
  echo "${name}.sh"
}

# Map a natural-language step description to rzsh framework boilerplate
_emit_step_body() {
  local step_num="$1"
  local desc="$2"
  local lower="${desc:l}"

  if [[ "${lower}" == *select* && ( "${lower}" == *server* || "${lower}" == *host* || "${lower}" == *env* ) ]]; then
    cat <<'EOF'
  local server_list="${SERVER_LIST:-dev.example.com staging.example.com prod.example.com}"
  TARGET_SERVER=$(select_option "Select target server" "${server_list}")
  validate_required "${TARGET_SERVER}" "Target server selection is required" || return 1
  log_info "Selected server: ${TARGET_SERVER}"
EOF
  elif [[ "${lower}" == *ssh* ]]; then
    cat <<'EOF'
  local remote_host="${TARGET_SERVER:-$(read_input "Enter target server hostname")}"
  local remote_user="${SSH_USER:-$(read_input "Enter SSH username" "${USER}")}"
  validate_required "${remote_host}" "Remote host is required" || return 1

  if ! ssh_is_reachable "${remote_host}"; then
    log_error "Host '${remote_host}' is not reachable over SSH."
    return 1
  fi
  log_info "SSH connectivity verified for ${remote_user}@${remote_host}"
  # Example remote command:
  # ssh_exec "${remote_user}@${remote_host}" "uptime"
EOF
  elif [[ "${lower}" == *password* || "${lower}" == *secret* || "${lower}" == *credential* ]]; then
    cat <<'EOF'
  # Option A: Read password securely from user prompt
  # AUTH_PASSWORD=$(read_password "Enter password")
  # Option B: Fetch password from a remote host or local file
  if [[ -n "${TARGET_SERVER:-}" && -n "${REMOTE_SECRET_PATH:-}" ]]; then
    AUTH_PASSWORD=$(ssh_exec "${SSH_USER:-${USER}}@${TARGET_SERVER}" "cat '${REMOTE_SECRET_PATH}'") || return 1
  elif [[ -n "${SECRET_FILE:-}" ]] && validate_file_exists "${SECRET_FILE}"; then
    AUTH_PASSWORD=$(file_read "${SECRET_FILE}") || return 1
  else
    AUTH_PASSWORD=$(read_password "Enter service password")
  fi
  validate_required "${AUTH_PASSWORD}" "Password must not be empty" || return 1
  log_info "Password loaded successfully (length: ${#AUTH_PASSWORD})."
EOF
  elif [[ "${lower}" == *payload* || "${lower}" == *prepare* ]]; then
    cat <<'EOF'
  local username="${SERVICE_USER:-$(read_input "Enter service username")}"
  validate_required "${username}" "Service username is required" || return 1

  REQUEST_PAYLOAD=$(printf '{"username":"%s","password":"%s"}' "${username}" "${AUTH_PASSWORD:-}")
  if ! validate_json "${REQUEST_PAYLOAD}"; then
    log_error "Prepared payload is not valid JSON."
    return 1
  fi
  log_info "Request payload prepared and validated."
EOF
  elif [[ "${lower}" == *observe* || "${lower}" == *verify* || "${lower}" == *success* || "${lower}" == *status* || "${lower}" == *check* ]]; then
    cat <<'EOF'
  if check_status_code "200" "${LAST_HTTP_RESPONSE:-}"; then
    log_info "Operation succeeded (HTTP 200)."
    STEP_RESULT="SUCCESS"
  else
    log_error "Operation failed or returned unexpected status."
    STEP_RESULT="FAILED"
    return 1
  fi
EOF
  elif [[ "${lower}" == *request* || "${lower}" == *login* || "${lower}" == *http* || "${lower}" == *api* ]]; then
    cat <<'EOF'
  local endpoint="${LOGIN_URL:-$(read_input "Enter login API URL" "https://api.example.com/auth/login")}"
  if ! validate_url "${endpoint}"; then
    log_error "Invalid endpoint URL: ${endpoint}"
    return 1
  fi

  log_info "Sending request to ${endpoint}..."
  LAST_HTTP_RESPONSE=$(http_post "${endpoint}" "${REQUEST_PAYLOAD:-{}}")
EOF
  elif [[ "${lower}" == *report* || "${lower}" == *evidence* || "${lower}" == *summary* ]]; then
    cat <<'EOF'
  if typeset -f generate_evidence_report >/dev/null && [[ -n "${CURRENT_EVIDENCE_DIR:-}" ]]; then
    local summary_file="${CURRENT_EVIDENCE_DIR}/workflow_summary.md"
    printf "# Workflow Execution Summary\n\n- **Date:** %s\n- **Target Server:** %s\n- **Result:** %s\n" \
      "$(date)" "${TARGET_SERVER:-N/A}" "${STEP_RESULT:-COMPLETED}" > "${summary_file}"
    if typeset -f _add_evidence_file >/dev/null; then
      _add_evidence_file "workflow_summary.md" "workflow_summary"
    fi
    generate_evidence_report >/dev/null
    log_info "Report generated at: ${CURRENT_EVIDENCE_DIR}/report.md"
  else
    log_info "Summary: Server=${TARGET_SERVER:-N/A}, Result=${STEP_RESULT:-COMPLETED}"
  fi
EOF
  else
    cat <<EOF
  log_info "Executing step ${step_num}: ${desc}"
  # TODO: Implement custom logic for '${desc}' using rzsh helpers.
EOF
  fi
}

# Write the complete generated script to target_path
_write_generated_script() {
  local target_path="$1"
  local script_name="$2"
  local description="$3"
  local include_evidence="$4"
  shift 4
  local -a steps
  steps=( "$@" )

  local target_dir="${target_path:h}"
  if [[ ! -d "${target_dir}" ]]; then
    mkdir -p "${target_dir}" || error_exit "Failed to create output directory: ${target_dir}" 1
  fi

  {
    cat <<EOF
#!/usr/bin/env zsh
# ${script_name}
# ${description}
# Generated by rzsh script generator on $(date '+%Y-%m-%d %H:%M:%S')
[ -z "\${ZSH_VERSION:-}" ] && exec zsh "\$0" "\$@"

if [[ -z "\${RZSH_DIR:-}" ]]; then
  printf '[WARN] RZSH_DIR is not set. Please set export RZSH_DIR="%s" in your environment (e.g., ~/.zshrc).\n' "\${0:A:h:h}" >&2
  export RZSH_DIR="\${0:A:h:h}"
fi

source "\${RZSH_DIR}/config/config.sh"
init_config || {
  printf "Error: Failed to initialize framework configuration.\n" >&2
  exit 1
}
init_logging

EOF

    local i=1
    local step_desc fn_name
    for step_desc in "${steps[@]}"; do
      fn_name="step_${i}_$(_slugify "${step_desc}")"
      cat <<EOF
# Step ${i}: ${step_desc}
${fn_name}() {
  log_section "Step ${i}: ${step_desc}"
EOF
      _emit_step_body "${i}" "${step_desc}"
      cat <<EOF
}

EOF
      (( i++ ))
    done

    cat <<EOF
main() {
  log_section "${script_name} - Starting Workflow"
EOF
    if [[ "${include_evidence}" == "yes" ]]; then
      cat <<'EOF'
  init_evidence || error_exit "Failed to initialize evidence tracking" 1
  collect_environment_evidence
  collect_script_evidence "$@"
EOF
    fi

    i=1
    for step_desc in "${steps[@]}"; do
      fn_name="step_${i}_$(_slugify "${step_desc}")"
      cat <<EOF
  ${fn_name} || error_exit "Step ${i} (${step_desc}) failed" 1
EOF
      (( i++ ))
    done

    cat <<EOF
  log_info "${script_name} completed successfully."
}

main "\$@"
EOF
  } > "${target_path}"

  chmod +x "${target_path}"
}

main() {
  log_section "rzsh Interactive Script Generator"
  log_info "Answer the prompts below to generate an executable rzsh workflow script."

  local raw_name script_file description output_dir terminator
  while true; do
    raw_name=$(read_input "What is the script name? (e.g., service-login)")
    if validate_required "${raw_name}" "Script name is required"; then
      break
    fi
  done
  script_file=$(_normalize_script_filename "${raw_name}")

  description=$(read_input "Short description for this script" "Automated workflow for ${script_file%.sh}")
  output_dir=$(read_input "Output directory" "${RZSH_DIR}/scripts/generated")
  terminator=$(read_input "Enter the terminator keyword to stop adding steps" "done")
  validate_required "${terminator}" "Terminator keyword cannot be empty" || terminator="done"

  local include_evidence="no"
  if confirm "Include automatic evidence & report generation?" "y"; then
    include_evidence="yes"
  fi

  log_section "Define Workflow Steps"
  log_info "Enter each step in order. Type '${terminator}' when you are finished."

  local -a steps
  local step_input
  local step_idx=1
  while true; do
    step_input=$(read_input "Step ${step_idx} (or '${terminator}' to finish)")
    if [[ "${step_input}" == "${terminator}" ]]; then
      if (( ${#steps} == 0 )); then
        log_warn "Please add at least one step before finishing."
        continue
      fi
      break
    fi
    if [[ -z "${step_input// /}" ]]; then
      log_warn "Step description cannot be empty. Enter a step or '${terminator}'."
      continue
    fi
    steps+=("${step_input}")
    (( step_idx++ ))
  done

  local target_path="${output_dir%/}/${script_file}"

  log_section "Review Generated Script Plan"
  printf "  Script File : %s\n" "${target_path}"
  printf "  Description : %s\n" "${description}"
  printf "  Evidence    : %s\n" "${include_evidence}"
  printf "  Total Steps : %d\n" "${#steps}"
  local idx=1
  for step_input in "${steps[@]}"; do
    printf "    %d. %s\n" "${idx}" "${step_input}"
    (( idx++ ))
  done

  if ! confirm "Generate this script now?" "y"; then
    log_warn "Script generation cancelled by user."
    return 0
  fi

  _write_generated_script "${target_path}" "${script_file}" "${description}" "${include_evidence}" "${steps[@]}"

  if zsh -n "${target_path}"; then
    log_info "Generated executable script: ${target_path}"
    log_info "Syntax check passed (zsh -n). Run it with: ${target_path}"
  else
    error_exit "Generated script failed syntax check: ${target_path}" 1
  fi
}

main "$@"
