# config/config.sh

# Protect against double sourcing
if [[ -n "${_CONFIG_SH_SOURCED:-}" ]]; then
  return 0
fi
readonly _CONFIG_SH_SOURCED=1

# Get the directory of the current file in Zsh.
# ${(%):-%x} is the standard Zsh way to get the path of the current sourced script.
# Fallback to ${0} if not available.
_CFG_DIR="${${(%):-%x}:A:h}"
[[ -z "${_CFG_DIR}" ]] && _CFG_DIR="${0:A:h}"

# Default PROJECT_ROOT is the parent of config dir
: "${PROJECT_ROOT:="${_CFG_DIR:h}"}"

# Global Variables (declared with defaults, allowing override)
LOG_DIR="${LOG_DIR:-}"
LOG_LEVEL="${LOG_LEVEL:-}"
SCRIPT_NAME="${SCRIPT_NAME:-}"
TIMESTAMP_FORMAT="${TIMESTAMP_FORMAT:-}"
DATE_FORMAT="${DATE_FORMAT:-}"
JWT_SECRET="${JWT_SECRET:-}"
EVIDENCE_DIR="${EVIDENCE_DIR:-}"

# /**
#  * @function init_config
#  * @description Initializes the global configuration variables for the framework, setting defaults if they are not already defined in the environment.
#  * @param None
#  * @return {number} 0 on success, or non-zero on failure.
#  * @example
#  *   init_config
#  */
init_config() {
  # Ensure PROJECT_ROOT is absolute and exists
  if [[ ! -d "${PROJECT_ROOT}" ]]; then
    printf 'Error: PROJECT_ROOT (%s) does not exist.\n' "${PROJECT_ROOT}" >&2
    return 1
  fi

  # Ensure local bin is in PATH for Zsh and jq
  export PATH="/home/ubuntu/.local/bin:${PATH}"

  # Set defaults if not already set by environment
  LOG_LEVEL="${LOG_LEVEL:-INFO}"
  LOG_DIR="${LOG_DIR:-${PROJECT_ROOT}/logs}"
  SCRIPT_NAME="${SCRIPT_NAME:-${0:t}}"
  TIMESTAMP_FORMAT="${TIMESTAMP_FORMAT:-%Y-%m-%d %H:%M:%S}"
  DATE_FORMAT="${DATE_FORMAT:-%Y-%m-%d}"
  JWT_SECRET="${JWT_SECRET:-placeholder-secret-keys-should-be-overridden}"
  EVIDENCE_DIR="${EVIDENCE_DIR:-${PROJECT_ROOT}/evidence}"

  # Export variables to make them available to subshells
  export PROJECT_ROOT
  export LOG_LEVEL
  export LOG_DIR
  export SCRIPT_NAME
  export TIMESTAMP_FORMAT
  export DATE_FORMAT
  export JWT_SECRET
  export EVIDENCE_DIR

  return 0
}
