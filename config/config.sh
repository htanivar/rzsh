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
SECRETS_DIR="${SECRETS_DIR:-}"
RAVI_DIR="${RAVI_DIR:-}"
GIT_IGNORE_FOLDERS="${GIT_IGNORE_FOLDERS:-}"
HTTP_CONTENT_TYPE="${HTTP_CONTENT_TYPE:-}"
HTTP_ACCEPT="${HTTP_ACCEPT:-}"
HTTP_AUTH_TOKEN="${HTTP_AUTH_TOKEN:-}"
HTTP_VAULT_TOKEN="${HTTP_VAULT_TOKEN:-}"
HTTP_VAULT_REQUEST="${HTTP_VAULT_REQUEST:-}"
HTTP_DEFAULT_HEADERS="${HTTP_DEFAULT_HEADERS:-}"

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
  SECRETS_DIR="${SECRETS_DIR:-${PROJECT_ROOT}/.secrets.d}"
  GIT_IGNORE_FOLDERS="${GIT_IGNORE_FOLDERS:-vendor,.idea,.git}"
  HTTP_CONTENT_TYPE="${HTTP_CONTENT_TYPE:-application/json}"
  HTTP_ACCEPT="${HTTP_ACCEPT:-application/json}"
  HTTP_AUTH_TOKEN="${HTTP_AUTH_TOKEN:-}"
  HTTP_VAULT_TOKEN="${HTTP_VAULT_TOKEN:-}"
  HTTP_VAULT_REQUEST="${HTTP_VAULT_REQUEST:-}"

  # Populate default HTTP headers without overwriting user-preconfigured entries
  local -A _hdr_map
  local -A _hdr_lower
  local _line _k _v _kl _existing
  if [[ -n "${HTTP_DEFAULT_HEADERS:-}" ]]; then
    for _line in ${(f)HTTP_DEFAULT_HEADERS}; do
      [[ -z "${_line}" || "${_line}" != *:* ]] && continue
      _k="${_line%%:*}"
      _v="${_line#*:}"
      _k="${_k#"${_k%%[![:space:]]*}"}"
      _k="${_k%"${_k##*[![:space:]]}"}"
      _v="${_v#"${_v%%[![:space:]]*}"}"
      [[ -z "${_k}" ]] && continue
      _kl="${_k:l}"
      _hdr_map[${_k}]="${_v}"
      _hdr_lower[${_kl}]="${_k}"
    done
  fi

  local -a _defaults
  _defaults=()
  [[ -n "${HTTP_CONTENT_TYPE}" ]] && _defaults+=("Content-Type:${HTTP_CONTENT_TYPE}")
  [[ -n "${HTTP_ACCEPT}" ]] && _defaults+=("Accept:${HTTP_ACCEPT}")
  [[ -n "${HTTP_AUTH_TOKEN}" ]] && _defaults+=("Authorization:Bearer ${HTTP_AUTH_TOKEN}")
  [[ -n "${HTTP_VAULT_TOKEN}" ]] && _defaults+=("X-Vault-Token:${HTTP_VAULT_TOKEN}")
  [[ -n "${HTTP_VAULT_REQUEST}" ]] && _defaults+=("X-Vault-Request:${HTTP_VAULT_REQUEST}")

  local _entry
  for _entry in "${_defaults[@]}"; do
    _k="${_entry%%:*}"
    _v="${_entry#*:}"
    _kl="${_k:l}"
    if [[ -z "${_hdr_lower[${_kl}]:-}" ]]; then
      _hdr_map[${_k}]="${_v}"
      _hdr_lower[${_kl}]="${_k}"
    fi
  done

  HTTP_DEFAULT_HEADERS=""
  for _k in "${(@ko)_hdr_map}"; do
    if [[ -n "${HTTP_DEFAULT_HEADERS}" ]]; then
      HTTP_DEFAULT_HEADERS+=$'\n'
    fi
    HTTP_DEFAULT_HEADERS+="${_k}: ${_hdr_map[${_k}]}"
  done

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
  export SECRETS_DIR
  export RAVI_DIR
  export GIT_IGNORE_FOLDERS
  export HTTP_CONTENT_TYPE
  export HTTP_ACCEPT
  export HTTP_AUTH_TOKEN
  export HTTP_VAULT_TOKEN
  export HTTP_VAULT_REQUEST
  export HTTP_DEFAULT_HEADERS

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
