# functions/01-logs.sh

# Protect against double sourcing
if [[ -n "${_LOGS_SH_SOURCED:-}" ]]; then
  return 0
fi
readonly _LOGS_SH_SOURCED=1

# Global logging state
CURRENT_LOG_FILE=""
LOG_STEPS_COUNT=0

# Ensure config is sourced if available
if [[ -f "${PROJECT_ROOT:-.}/config/config.sh" ]]; then
  source "${PROJECT_ROOT:-.}/config/config.sh"
fi

# /**
#  * @function init_logging
#  * @description Initializes logging. Creates log directory and file with timestamp, and performs basic rotation (keeping last 5 logs).
#  * @param None
#  * @return {number} 0 on success, 1 on failure.
#  * @example
#  *   init_logging
#  */
init_logging() {
  local log_dir="${LOG_DIR:-${PROJECT_ROOT:-.}/logs}"
  
  if ! mkdir -p "${log_dir}" 2>/dev/null; then
    return 1
  fi

  local ts
  ts=$(date +%Y%m%d_%H%M%S)
  CURRENT_LOG_FILE="${log_dir}/log_${ts}.log"
  
  if ! touch "${CURRENT_LOG_FILE}" 2>/dev/null; then
    return 1
  fi

  # Basic rotation: keep only latest 5 files matching log_*.log
  local files
  files=( "${log_dir}"/log_*.log(NOm) )
  if (( ${#files} > 5 )); then
    local file_to_delete
    for file_to_delete in "${files[@]:5}"; do
      rm -f "${file_to_delete}" 2>/dev/null
    done
  fi

  LOG_STEPS_COUNT=0
  return 0
}

# /**
#  * @function log
#  * @description Core log function formatting and writing output to console (stderr) and file.
#  * @param {string} level - Log level (DEBUG, INFO, WARN, ERROR).
#  * @param {string} message - Message to log.
#  * @return {number} 0 on success.
#  * @example
#  *   log "INFO" "Starting build process"
#  */
log() {
  local level="${1:u}"
  local message="$2"
  local ts
  ts=$(date +"${TIMESTAMP_FORMAT:-%Y-%m-%d %H:%M:%S}")

  local level_val=1
  case "${level}" in
    DEBUG) level_val=0 ;;
    INFO)  level_val=1 ;;
    WARN)  level_val=2 ;;
    ERROR) level_val=3 ;;
    *)     level_val=1 ;;
  esac

  local current_level_val=1
  case "${LOG_LEVEL:u}" in
    DEBUG) current_level_val=0 ;;
    INFO)  current_level_val=1 ;;
    WARN)  current_level_val=2 ;;
    ERROR) current_level_val=3 ;;
  esac

  if (( level_val < current_level_val )); then
    return 0
  fi

  local color=""
  local reset="\e[0m"
  case "${level}" in
    DEBUG) color="\e[36m" ;; # Cyan
    INFO)  color="\e[32m" ;; # Green
    WARN)  color="\e[33m" ;; # Yellow
    ERROR) color="\e[31m" ;; # Red
  esac

  # Console output (with color)
  printf "${color}[%s] [%s] %s${reset}\n" "${ts}" "${level}" "${message}" >&2

  # File output (without color)
  if [[ -n "${CURRENT_LOG_FILE}" && -f "${CURRENT_LOG_FILE}" ]]; then
    printf "[%s] [%s] %s\n" "${ts}" "${level}" "${message}" >> "${CURRENT_LOG_FILE}"
  fi

  return 0
}

# /**
#  * @function log_info
#  * @description Logs an informational message.
#  * @param {string} message - Message to log.
#  * @return {number} 0 on success.
#  * @example
#  *   log_info "Application started"
#  */
log_info() {
  log INFO "$1"
}

# /**
#  * @function log_error
#  * @description Logs an error message.
#  * @param {string} message - Message to log.
#  * @return {number} 0 on success.
#  * @example
#  *   log_error "Failed to connect to database"
#  */
log_error() {
  log ERROR "$1"
}

# /**
#  * @function log_warn
#  * @description Logs a warning message.
#  * @param {string} message - Message to log.
#  * @return {number} 0 on success.
#  * @example
#  *   log_warn "Disk space is low"
#  */
log_warn() {
  log WARN "$1"
}

# /**
#  * @function log_debug
#  * @description Logs a debug message.
#  * @param {string} message - Message to log.
#  * @return {number} 0 on success.
#  * @example
#  *   log_debug "Connection string: $conn"
#  */
log_debug() {
  log DEBUG "$1"
}

# /**
#  * @function log_steps
#  * @description Logs progress tracking steps with an incrementing counter.
#  * @param {string} step_name - Name of the step.
#  * @return {number} 0 on success.
#  * @example
#  *   log_steps "Compile sources"
#  */
log_steps() {
  local step_name="$1"
  (( LOG_STEPS_COUNT++ ))
  log INFO "Step ${LOG_STEPS_COUNT}: ${step_name}"
}

# /**
#  * @function log_command
#  * @description Executes a command, logging both its execution start/end and redirecting its output to the log file.
#  * @param {string} command - Command to run.
#  * @return {number} Exit code of the executed command.
#  * @example
#  *   log_command "npm install"
#  */
log_command() {
  local cmd="$1"
  log INFO "Executing command: ${cmd}"
  
  local exit_code=0
  if [[ -n "${CURRENT_LOG_FILE}" && -f "${CURRENT_LOG_FILE}" ]]; then
    eval "${cmd}" >> "${CURRENT_LOG_FILE}" 2>&1
    exit_code=$?
    log INFO "Command finished with exit status: ${exit_code}"
  else
    eval "${cmd}"
    exit_code=$?
  fi
  
  return ${exit_code}
}

# /**
#  * @function log_section
#  * @description Logs a section header with border lines.
#  * @param {string} title - Section title.
#  * @return {number} 0 on success.
#  * @example
#  *   log_section "Database Migration"
#  */
log_section() {
  local title="$1"
  local border="================================================================================"
  log INFO "${border}"
  log INFO "  ${title}"
  log INFO "${border}"
}
