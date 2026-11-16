# functions/18-script-executory.sh

# Protect against double sourcing
if [[ -n "${_SCRIPT_EXECUTORY_SH_SOURCED:-}" ]]; then
  return 0
fi
readonly _SCRIPT_EXECUTORY_SH_SOURCED=1

# Ensure config & logs are sourced if available
if [[ -f "${RZSH_DIR:-${PROJECT_ROOT:-.}}/config/config.sh" ]]; then
  source "${RZSH_DIR:-${PROJECT_ROOT:-.}}/config/config.sh"
fi
if [[ -f "${RZSH_DIR:-${PROJECT_ROOT:-.}}/functions/01-logs.sh" ]]; then
  source "${RZSH_DIR:-${PROJECT_ROOT:-.}}/functions/01-logs.sh"
fi

# Global array storing the last sequence execution summary lines
typeset -g -a SCRIPT_EXEC_SUMMARY

# Internal helper: resolve a script path directly or relative to RZSH_DIR/scripts or PROJECT_ROOT
_resolve_script_path() {
  local script_ref="$1"
  if [[ -z "${script_ref}" ]]; then
    return 1
  fi

  if [[ -f "${script_ref}" ]]; then
    echo "${script_ref:A}"
    return 0
  elif [[ -n "${RZSH_DIR:-}" && -f "${RZSH_DIR}/scripts/${script_ref}" ]]; then
    echo "${RZSH_DIR}/scripts/${script_ref}"
    return 0
  elif [[ -n "${PROJECT_ROOT:-}" && -f "${PROJECT_ROOT}/${script_ref}" ]]; then
    echo "${PROJECT_ROOT}/${script_ref}"
    return 0
  fi

  return 1
}

# /**
#  * @function validate_script_executable
#  * @description Resolves a script path and verifies it exists, is readable, and passes Zsh syntax check.
#  * @param {string} script_path - Path or relative name of the script to validate.
#  * @return {number} 0 if valid, 1 otherwise.
#  * @example
#  *   validate_script_executable "scripts/login.sh"
#  */
validate_script_executable() {
  local script_ref="$1"
  if [[ -z "${script_ref}" ]]; then
    log_error "validate_script_executable: script path is required"
    return 1
  fi

  local resolved
  resolved=$(_resolve_script_path "${script_ref}") || {
    log_error "Script not found: ${script_ref}"
    return 1
  }

  if [[ ! -r "${resolved}" ]]; then
    log_error "Script is not readable: ${resolved}"
    return 1
  fi

  if [[ "${resolved}" == *.sh || "${resolved}" == *.zsh ]]; then
    if ! zsh -n "${resolved}" 2>/dev/null; then
      log_error "Script failed Zsh syntax check: ${resolved}"
      return 1
    fi
  fi

  return 0
}

# /**
#  * @function execute_script
#  * @description Executes a target script in a Zsh subprocess with optional arguments and logs timing/status.
#  * @param {string} script_path - Path to the script to execute.
#  * @param {string} [args...] - Optional arguments forwarded to the script.
#  * @return {number} Exit code of the executed script, or 1 if validation fails.
#  * @example
#  *   execute_script "./login.sh" "--env" "prod"
#  */
execute_script() {
  local script_ref="$1"
  shift 2>/dev/null || true

  local resolved
  resolved=$(_resolve_script_path "${script_ref}") || {
    log_error "execute_script: Script not found: ${script_ref}"
    return 1
  }

  validate_script_executable "${resolved}" || return 1

  log_info "Executing script: ${resolved:t} (${resolved})"
  local start_sec=${SECONDS}
  zsh "${resolved}" "$@"
  local rc=$?
  local elapsed=$(( SECONDS - start_sec ))

  if (( rc == 0 )); then
    log_info "Script '${resolved:t}' succeeded in ${elapsed}s."
  else
    log_error "Script '${resolved:t}' failed with exit code ${rc} after ${elapsed}s."
  fi

  return ${rc}
}

# /**
#  * @function execute_script_in_current_shell
#  * @description Sources a target script in the current shell so exported/global variables persist across steps.
#  * @param {string} script_path - Path to the script to source.
#  * @param {string} [args...] - Optional positional parameters passed to the sourced script.
#  * @return {number} Exit code of the sourced script, or 1 if validation fails.
#  * @example
#  *   execute_script_in_current_shell "./login.sh"
#  */
execute_script_in_current_shell() {
  local script_ref="$1"
  shift 2>/dev/null || true

  local resolved
  resolved=$(_resolve_script_path "${script_ref}") || {
    log_error "execute_script_in_current_shell: Script not found: ${script_ref}"
    return 1
  }

  validate_script_executable "${resolved}" || return 1

  log_info "Sourcing script in current shell: ${resolved:t}"
  source "${resolved}" "$@"
  local rc=$?

  if (( rc == 0 )); then
    log_info "Sourced script '${resolved:t}' completed successfully."
  else
    log_error "Sourced script '${resolved:t}' failed with exit code ${rc}."
  fi

  return ${rc}
}

# /**
#  * @function execute_scripts_sequence
#  * @description Executes multiple scripts sequentially in the specified order.
#  * @param {string} [--continue-on-error] - Continue running remaining scripts even if one fails.
#  * @param {string} [--source] - Source scripts in the current shell instead of running in subshells.
#  * @param {string} [--dry-run] - Validate and print the execution plan without running the scripts.
#  * @param {string} scripts... - Ordered list of script paths to execute.
#  * @return {number} 0 if all scripts succeed, or non-zero exit code on failure.
#  * @example
#  *   execute_scripts_sequence "./login.sh" "./verify.sh" "./update.sh"
#  */
execute_scripts_sequence() {
  local continue_on_error=0
  local use_source=0
  local dry_run=0
  local -a scripts

  while (( $# > 0 )); do
    case "$1" in
      --continue-on-error)
        continue_on_error=1
        shift
        ;;
      --source)
        use_source=1
        shift
        ;;
      --dry-run)
        dry_run=1
        shift
        ;;
      --)
        shift
        scripts+=("$@")
        break
        ;;
      *)
        scripts+=("$1")
        shift
        ;;
    esac
  done

  if (( ${#scripts} == 0 )); then
    log_error "execute_scripts_sequence: No scripts provided."
    return 1
  fi

  SCRIPT_EXEC_SUMMARY=()
  local total=${#scripts}
  local passed=0
  local failed=0
  local overall_rc=0
  local idx=1
  local script_path rc resolved

  log_section "Script Execution Sequence (${total} scripts)"

  for script_path in "${scripts[@]}"; do
    log_info "[${idx}/${total}] Preparing: ${script_path}"

    if (( dry_run == 1 )); then
      if resolved=$(_resolve_script_path "${script_path}") && validate_script_executable "${resolved}"; then
        log_info "[DRY-RUN] Would execute (${idx}/${total}): ${resolved}"
        SCRIPT_EXEC_SUMMARY+=("${idx}. ${script_path}: DRY_RUN_OK")
        (( passed++ ))
      else
        SCRIPT_EXEC_SUMMARY+=("${idx}. ${script_path}: DRY_RUN_INVALID")
        (( failed++ ))
        overall_rc=1
        if (( continue_on_error == 0 )); then
          break
        fi
      fi
      (( idx++ ))
      continue
    fi

    if (( use_source == 1 )); then
      execute_script_in_current_shell "${script_path}"
      rc=$?
    else
      execute_script "${script_path}"
      rc=$?
    fi

    if (( rc == 0 )); then
      SCRIPT_EXEC_SUMMARY+=("${idx}. ${script_path}: PASSED (exit 0)")
      (( passed++ ))
    else
      SCRIPT_EXEC_SUMMARY+=("${idx}. ${script_path}: FAILED (exit ${rc})")
      (( failed++ ))
      overall_rc=${rc}
      if (( continue_on_error == 0 )); then
        log_error "Stopping sequence at step ${idx}/${total} (${script_path})."
        break
      fi
    fi

    (( idx++ ))
  done

  log_info "Sequence Summary: Total=${total}, Passed=${passed}, Failed=${failed}"
  return ${overall_rc}
}

# /**
#  * @function execute_scripts_from_file
#  * @description Reads an ordered list of script paths from a manifest file (ignoring blank lines and # comments) and executes them sequentially.
#  * @param {string} manifest_file - Path to the manifest file containing one script path per line.
#  * @param {string} [flags...] - Optional flags forwarded to execute_scripts_sequence (--continue-on-error, --source, --dry-run).
#  * @return {number} 0 if all scripts succeed, non-zero otherwise.
#  * @example
#  *   execute_scripts_from_file "./pipeline.txt"
#  */
execute_scripts_from_file() {
  local manifest_file="$1"
  shift 2>/dev/null || true

  if [[ -z "${manifest_file}" || ! -f "${manifest_file}" ]]; then
    log_error "execute_scripts_from_file: Manifest file not found: ${manifest_file}"
    return 1
  fi

  local -a flags
  flags=("$@")
  local -a scripts
  local line

  while IFS= read -r line || [[ -n "${line}" ]]; do
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [[ -z "${line}" || "${line}" == \#* ]] && continue
    scripts+=("${line}")
  done < "${manifest_file}"

  if (( ${#scripts} == 0 )); then
    log_error "execute_scripts_from_file: No scripts listed in ${manifest_file}"
    return 1
  fi

  execute_scripts_sequence "${flags[@]}" -- "${scripts[@]}"
}

# /**
#  * @function execute_script_with_retry
#  * @description Executes a script and retries up to max_retries times if it returns a non-zero exit code.
#  * @param {string} script_path - Path to the script to execute.
#  * @param {number} [max_retries=3] - Maximum number of attempts.
#  * @param {number} [delay_seconds=2] - Delay in seconds between retries.
#  * @param {string} [args...] - Optional arguments forwarded to the script.
#  * @return {number} 0 on success, or the last non-zero exit code after exhausting retries.
#  * @example
#  *   execute_script_with_retry "./login.sh" 3 1
#  */
execute_script_with_retry() {
  local script_path="$1"
  local max_retries="${2:-3}"
  local delay_seconds="${3:-2}"
  shift 3 2>/dev/null || shift $#

  local attempt=1
  local rc=1

  while (( attempt <= max_retries )); do
    log_info "Attempt ${attempt}/${max_retries} for '${script_path}'..."
    execute_script "${script_path}" "$@"
    rc=$?
    if (( rc == 0 )); then
      return 0
    fi
    if (( attempt < max_retries )); then
      log_warn "Retrying '${script_path}' in ${delay_seconds}s..."
      sleep "${delay_seconds}"
    fi
    (( attempt++ ))
  done

  log_error "Script '${script_path}' failed after ${max_retries} attempts."
  return ${rc}
}
