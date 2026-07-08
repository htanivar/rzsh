# functions/02-errors.sh

# Protect against double sourcing
if [[ -n "${_ERRORS_SH_SOURCED:-}" ]]; then
  return 0
fi
readonly _ERRORS_SH_SOURCED=1

# Global array to track temporary files for cleanup
typeset -g -a TEMP_FILES

# Source logs if available
if [[ -f "${PROJECT_ROOT:-.}/functions/01-logs.sh" ]]; then
  source "${PROJECT_ROOT:-.}/functions/01-logs.sh"
fi

# /**
#  * @function error_exit
#  * @description Logs a fatal error message, prints the current call stack trace, cleans up registered temporary files, and exits the script.
#  * @param {string} message - The error message.
#  * @param {number} [exit_code=1] - The exit status code.
#  * @return {void}
#  * @example
#  *   error_exit "Database connection failed" 2
#  */
error_exit() {
  local msg="$1"
  local code="${2:-1}"

  # Fallback to printf if log_error is not defined
  if typeset -f log_error >/dev/null; then
    log_error "FATAL: ${msg}"
    log_error "Stack Trace:"
    local i
    for (( i = 2; i <= ${#funcstack}; i++ )); do
      log_error "  at ${funcstack[i]}() in ${funcfiletrace[i]}"
    done
  else
    printf "FATAL: %s\n" "${msg}" >&2
    printf "Stack Trace:\n" >&2
    local i
    for (( i = 2; i <= ${#funcstack}; i++ )); do
      printf "  at %s() in %s\n" "${funcstack[i]}" "${funcfiletrace[i]}" >&2
    done
  fi

  # Cleanup temporary files
  if (( ${#TEMP_FILES} > 0 )); then
    if typeset -f log_info >/dev/null; then
      log_info "Cleaning up temporary files..."
    else
      printf "Cleaning up temporary files...\n" >&2
    fi
    
    local f
    for f in "${TEMP_FILES[@]}"; do
      if [[ -e "${f}" ]]; then
        rm -rf "${f}" 2>/dev/null
      fi
    done
  fi

  exit "${code}"
}
