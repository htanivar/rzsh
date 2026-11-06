#!/usr/bin/env zsh
# config/config.sh

# Re-execute under zsh if invoked via bash/sh
if [ -z "${ZSH_VERSION:-}" ] && [ -f "$0" ]; then
  exec zsh "$0" "$@"
fi

# Protect against double sourcing
if [[ -n "${_CONFIG_SH_SOURCED:-}" ]]; then
  return 0
fi
readonly _CONFIG_SH_SOURCED=1

# Prevent repeated local/typeset declarations from printing variable values to stdout
setopt TYPESET_SILENT 2>/dev/null

# Get the directory of the current file in Zsh.
# ${(%):-%x} is the standard Zsh way to get the path of the current sourced script.
# Fallback to ${0} if not available.
_CFG_DIR="${${(%):-%x}:A:h}"
[[ -z "${_CFG_DIR}" ]] && _CFG_DIR="${0:A:h}"

# Advise if RZSH_DIR is not set, and default to the parent of config dir
if [[ -z "${RZSH_DIR:-}" ]]; then
  printf '[WARN] RZSH_DIR is not set. Please set export RZSH_DIR="%s" in your environment (e.g., ~/.zshrc).\n' "${_CFG_DIR:h}" >&2
  export RZSH_DIR="${_CFG_DIR:h}"
fi

# Default PROJECT_ROOT is RZSH_DIR (parent of config dir)
: "${PROJECT_ROOT:="${RZSH_DIR}"}"

# Global Variables (declared with defaults, allowing override)
LOG_DIR="${LOG_DIR:-}"
LOG_LEVEL="${LOG_LEVEL:-}"
SCRIPT_NAME="${SCRIPT_NAME:-}"
TIMESTAMP_FORMAT="${TIMESTAMP_FORMAT:-}"
DATE_FORMAT="${DATE_FORMAT:-}"
JWT_SECRET="${JWT_SECRET:-}"
EVIDENCE_DIR="${EVIDENCE_DIR:-}"
RAVI_DIR="${RAVI_DIR:-}"
GIT_IGNORE_FOLDERS="${GIT_IGNORE_FOLDERS:-}"

# Repository Configs
typeset -g -a REPO_NAMES
REPO_NAMES=(service1 service2 service3)

typeset -g -A REPO_LOCATIONS
REPO_LOCATIONS=(
  [service1]="/home/xxxx/hello/world/code"
  [service2]="/new/location"
)

# /**
#  * @function init_config
#  * @description Initializes the global configuration variables for the framework, setting defaults if they are not already defined in the environment.
#  * @param None
#  * @return {number} 0 on success, or non-zero on failure.
#  * @example
#  *   init_config
#  */
init_config() {
  # Ensure RZSH_DIR and PROJECT_ROOT are set and exist
  RZSH_DIR="${RZSH_DIR:-${PROJECT_ROOT}}"
  PROJECT_ROOT="${PROJECT_ROOT:-${RZSH_DIR}}"

  if [[ ! -d "${RZSH_DIR}" ]]; then
    printf 'Error: RZSH_DIR (%s) does not exist.\n' "${RZSH_DIR}" >&2
    return 1
  fi

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
  GIT_IGNORE_FOLDERS="${GIT_IGNORE_FOLDERS:-vendor,.idea,.git}"

  # Export variables to make them available to subshells
  export RZSH_DIR
  export PROJECT_ROOT
  export LOG_LEVEL
  export LOG_DIR
  export SCRIPT_NAME
  export TIMESTAMP_FORMAT
  export DATE_FORMAT
  export JWT_SECRET
  export EVIDENCE_DIR
  export RAVI_DIR
  export GIT_IGNORE_FOLDERS

  return 0
}

# Automatically source all function modules in numerical order
() {
  local func_dir="${RZSH_DIR}/functions"
  if [[ -d "${func_dir}" ]]; then
    local f
    for f in "${func_dir}"/*.sh(nN); do
      source "${f}"
    done
  fi
}
