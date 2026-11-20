# functions/19-cache.sh

# Protect against double sourcing
if [[ -n "${_CACHE_SH_SOURCED:-}" ]]; then
  return 0
fi
readonly _CACHE_SH_SOURCED=1

# Ensure config, logs, and jwt modules are sourced if available
if [[ -f "${RZSH_DIR:-${PROJECT_ROOT:-.}}/config/config.sh" ]]; then
  source "${RZSH_DIR:-${PROJECT_ROOT:-.}}/config/config.sh"
fi
if [[ -f "${RZSH_DIR:-${PROJECT_ROOT:-.}}/functions/01-logs.sh" ]]; then
  source "${RZSH_DIR:-${PROJECT_ROOT:-.}}/functions/01-logs.sh"
fi
if [[ -f "${RZSH_DIR:-${PROJECT_ROOT:-.}}/functions/13-jwt.sh" ]]; then
  source "${RZSH_DIR:-${PROJECT_ROOT:-.}}/functions/13-jwt.sh"
fi

# Load datetime module for EPOCHSECONDS
zmodload zsh/datetime 2>/dev/null

# Internal helper: resolve base secrets cache directory
_cache_base_dir() {
  echo "${SECRETS_DIR:-${PROJECT_ROOT:-${RZSH_DIR:-.}}/.secrets.d}"
}

# Internal helper: current unix epoch timestamp in seconds
_cache_now() {
  echo "${EPOCHSECONDS:-$(date +%s)}"
}

# Internal helper: validate and normalize a cache key (supports organized paths like app/env/token)
_cache_sanitize_key() {
  local raw_key="$1"
  if [[ -z "${raw_key}" ]]; then
    return 1
  fi

  # Reject leading/trailing slashes, backslashes, or parent directory traversal
  if [[ "${raw_key}" == /* || "${raw_key}" == */ || "${raw_key}" == *..* || "${raw_key}" == *\\* ]]; then
    return 1
  fi

  # Collapse any duplicate slashes and validate allowed characters
  local cleaned="${raw_key//\/\//\/}"
  cleaned="${cleaned%.json}"
  if [[ -z "${cleaned}" || ! "${cleaned}" =~ ^[a-zA-Z0-9._/-]+$ ]]; then
    return 1
  fi

  echo "${cleaned}"
}

# Internal helper: resolve full file path for a cache key
_cache_entry_path() {
  local key="$1"
  local sanitized
  sanitized=$(_cache_sanitize_key "${key}") || return 1
  local base_dir
  base_dir=$(_cache_base_dir)
  echo "${base_dir}/${sanitized}.json"
}

# Internal helper: read a single JSON field from a cache entry file
_cache_read_field() {
  local entry_file="$1"
  local field="$2"
  [[ -f "${entry_file}" ]] || return 1
  jq -r ".${field} // empty" "${entry_file}" 2>/dev/null
}

# Internal helper: check if a cache entry file is expired (returns 0 if expired, 1 if valid)
_cache_is_entry_expired() {
  local entry_file="$1"
  [[ -f "${entry_file}" ]] || return 0

  local expires_at
  expires_at=$(_cache_read_field "${entry_file}" "expires_at")
  local now
  now=$(_cache_now)

  if [[ -n "${expires_at}" && "${expires_at}" =~ ^[0-9]+$ ]] && (( expires_at > 0 && now >= expires_at )); then
    return 0
  fi

  # If the cached value is a JWT with an exp claim, honor JWT expiration as well
  if typeset -f jwt_expired >/dev/null; then
    local val
    val=$(_cache_read_field "${entry_file}" "value")
    local -a parts
    parts=( ${(s:.:)val} )
    if (( ${#parts} == 3 )) && jwt_expired "${val}" 2>/dev/null; then
      return 0
    fi
  fi

  return 1
}

# Internal helper: log error if log_error is available, else stderr
_cache_log_error() {
  if typeset -f log_error >/dev/null; then
    log_error "$1"
  else
    printf '[ERROR] %s\n' "$1" >&2
  fi
}

# Internal helper: log info if log_info is available
_cache_log_info() {
  if typeset -f log_info >/dev/null; then
    log_info "$1"
  fi
}

# /**
#  * @function cache_init
#  * @description Initializes the secrets cache directory (SECRETS_DIR or a custom path) with owner-only permissions (0700).
#  * @param {string} [dir] - Optional custom directory path (defaults to SECRETS_DIR).
#  * @return {number} 0 on success, 1 on failure.
#  * @example
#  *   cache_init
#  */
cache_init() {
  local target_dir="${1:-$(_cache_base_dir)}"
  if [[ -z "${target_dir}" ]]; then
    _cache_log_error "cache_init: secrets directory path is empty"
    return 1
  fi

  if [[ -n "${1:-}" ]]; then
    SECRETS_DIR="${target_dir}"
    export SECRETS_DIR
  fi

  mkdir -p "${target_dir}" 2>/dev/null || {
    _cache_log_error "cache_init: failed to create directory '${target_dir}'"
    return 1
  }
  chmod 700 "${target_dir}" 2>/dev/null || true
  return 0
}

# /**
#  * @function cache_set
#  * @description Stores a secret or token in the organized .secrets.d cache with an optional TTL in seconds. Auto-detects JWT 'exp' claim when ttl_seconds is omitted.
#  * @param {string} key - Cache key or organized path (e.g., "myapp/prod/jwt_token").
#  * @param {string} value - Secret or token value to store.
#  * @param {number} [ttl_seconds] - Time-to-live in seconds (0 = persistent). Omit to auto-detect JWT 'exp' or store persistently.
#  * @return {number} 0 on success, 1 on invalid input or write failure.
#  * @example
#  *   cache_set "payments/prod/jwt" "${token}" 3600
#  */
cache_set() {
  local key="$1"
  local value="$2"
  local ttl_seconds="${3:-}"

  if [[ -z "${key}" || -z "${value}" ]]; then
    _cache_log_error "cache_set: key and value are required"
    return 1
  fi

  local sanitized
  sanitized=$(_cache_sanitize_key "${key}") || {
    _cache_log_error "cache_set: invalid cache key '${key}'"
    return 1
  }

  cache_init >/dev/null || return 1

  local entry_file
  entry_file=$(_cache_entry_path "${sanitized}") || return 1
  local entry_dir="${entry_file:h}"
  mkdir -p "${entry_dir}" 2>/dev/null || {
    _cache_log_error "cache_set: failed to create directory '${entry_dir}'"
    return 1
  }
  chmod 700 "${entry_dir}" 2>/dev/null || true

  local now
  now=$(_cache_now)
  local expires_at=0
  local effective_ttl=0

  if [[ -n "${ttl_seconds}" ]]; then
    if [[ ! "${ttl_seconds}" =~ ^[0-9]+$ ]]; then
      _cache_log_error "cache_set: ttl_seconds must be a non-negative integer, got '${ttl_seconds}'"
      return 1
    fi
    effective_ttl="${ttl_seconds}"
    if (( effective_ttl > 0 )); then
      expires_at=$(( now + effective_ttl ))
    fi
  else
    # Auto-detect JWT 'exp' claim if value is a 3-part JWT
    local -a parts
    parts=( ${(s:.:)value} )
    if (( ${#parts} == 3 )) && typeset -f jwt_get_claim >/dev/null; then
      local jwt_exp
      jwt_exp=$(jwt_get_claim "${value}" ".exp" 2>/dev/null)
      if [[ -n "${jwt_exp}" && "${jwt_exp}" =~ ^[0-9]+$ ]] && (( jwt_exp > 0 )); then
        expires_at="${jwt_exp}"
        effective_ttl=$(( jwt_exp > now ? jwt_exp - now : 0 ))
      fi
    fi
  fi

  local tmp_file="${entry_file}.tmp.$$"
  jq -n \
    --arg key "${sanitized}" \
    --arg value "${value}" \
    --argjson created_at "${now}" \
    --argjson expires_at "${expires_at}" \
    --argjson ttl "${effective_ttl}" \
    '{key: $key, value: $value, created_at: $created_at, expires_at: $expires_at, ttl: $ttl}' > "${tmp_file}" 2>/dev/null || {
    rm -f "${tmp_file}" 2>/dev/null
    _cache_log_error "cache_set: failed to serialize cache entry for '${sanitized}'"
    return 1
  }

  chmod 600 "${tmp_file}" 2>/dev/null || true
  mv -f "${tmp_file}" "${entry_file}" || {
    rm -f "${tmp_file}" 2>/dev/null
    _cache_log_error "cache_set: failed to write cache entry '${entry_file}'"
    return 1
  }

  return 0
}

# /**
#  * @function cache_get
#  * @description Retrieves a valid (non-expired) secret or token from the cache. Removes and fails if expired.
#  * @param {string} key - Cache key or organized path (e.g., "myapp/prod/jwt_token").
#  * @return {string} Prints the cached secret value to stdout on success; returns 1 if missing or expired.
#  * @example
#  *   token=$(cache_get "payments/prod/jwt") || token=$(login_and_get_token)
#  */
cache_get() {
  local key="$1"
  if [[ -z "${key}" ]]; then
    return 1
  fi

  local entry_file
  entry_file=$(_cache_entry_path "${key}") || return 1
  [[ -f "${entry_file}" ]] || return 1

  if _cache_is_entry_expired "${entry_file}"; then
    rm -f "${entry_file}" 2>/dev/null
    return 1
  fi

  local val
  val=$(_cache_read_field "${entry_file}" "value")
  if [[ -z "${val}" ]]; then
    return 1
  fi

  printf '%s\n' "${val}"
  return 0
}

# /**
#  * @function cache_has
#  * @description Checks whether a valid, non-expired secret exists in the cache for the given key.
#  * @param {string} key - Cache key or organized path.
#  * @return {number} 0 if present and valid, 1 if missing or expired.
#  * @example
#  *   if cache_has "payments/prod/jwt"; then
#  *     echo "Using cached token"
#  *   fi
#  */
cache_has() {
  local key="$1"
  local entry_file
  entry_file=$(_cache_entry_path "${key}") || return 1
  [[ -f "${entry_file}" ]] || return 1

  if _cache_is_entry_expired "${entry_file}"; then
    rm -f "${entry_file}" 2>/dev/null
    return 1
  fi

  return 0
}

# /**
#  * @function cache_ttl
#  * @description Returns the remaining time-to-live in seconds for a cached secret (0 if persistent / no expiry).
#  * @param {string} key - Cache key or organized path.
#  * @return {string} Remaining seconds (or 0 for persistent entries); returns 1 if missing or expired.
#  * @example
#  *   remaining=$(cache_ttl "payments/prod/jwt")
#  */
cache_ttl() {
  local key="$1"
  local entry_file
  entry_file=$(_cache_entry_path "${key}") || return 1
  [[ -f "${entry_file}" ]] || return 1

  if _cache_is_entry_expired "${entry_file}"; then
    rm -f "${entry_file}" 2>/dev/null
    return 1
  fi

  local expires_at
  expires_at=$(_cache_read_field "${entry_file}" "expires_at")
  if [[ -z "${expires_at}" || ! "${expires_at}" =~ ^[0-9]+$ ]] || (( expires_at == 0 )); then
    echo "0"
    return 0
  fi

  local now
  now=$(_cache_now)
  local remaining=$(( expires_at - now ))
  (( remaining < 0 )) && remaining=0
  echo "${remaining}"
  return 0
}

# /**
#  * @function cache_remove
#  * @description Removes a cached secret entry and cleans up any empty parent directories under SECRETS_DIR.
#  * @param {string} key - Cache key or organized path.
#  * @return {number} 0 if removed, 1 if not found or invalid key.
#  * @example
#  *   cache_remove "payments/prod/jwt"
#  */
cache_remove() {
  local key="$1"
  local entry_file
  entry_file=$(_cache_entry_path "${key}") || return 1
  if [[ ! -f "${entry_file}" ]]; then
    return 1
  fi

  rm -f "${entry_file}" || return 1

  # Prune empty parent directories up to base_dir
  local base_dir
  base_dir=$(_cache_base_dir)
  local parent="${entry_file:h}"
  while [[ "${parent}" != "${base_dir}" && "${parent}" == "${base_dir}/"* ]]; do
    rmdir "${parent}" 2>/dev/null || break
    parent="${parent:h}"
  done

  return 0
}

# /**
#  * @function cache_clear
#  * @description Clears all cached secrets, or all secrets under a specific app/env prefix.
#  * @param {string} [prefix] - Optional key prefix (e.g., "payments/prod" or "payments").
#  * @return {number} 0 on success, 1 on invalid prefix.
#  * @example
#  *   cache_clear "payments/staging"
#  *   cache_clear
#  */
cache_clear() {
  local prefix="${1:-}"
  local base_dir
  base_dir=$(_cache_base_dir)

  [[ -d "${base_dir}" ]] || return 0

  if [[ -z "${prefix}" ]]; then
    rm -rf "${base_dir:?}"/* 2>/dev/null
    _cache_log_info "Cleared all cached secrets in ${base_dir}"
    return 0
  fi

  local sanitized
  sanitized=$(_cache_sanitize_key "${prefix}") || {
    _cache_log_error "cache_clear: invalid prefix '${prefix}'"
    return 1
  }

  local target_dir="${base_dir}/${sanitized}"
  local target_file="${base_dir}/${sanitized}.json"
  if [[ -d "${target_dir}" ]]; then
    rm -rf "${target_dir}"
  fi
  if [[ -f "${target_file}" ]]; then
    rm -f "${target_file}"
  fi

  return 0
}

# /**
#  * @function cache_prune
#  * @description Scans the secrets cache directory and removes all expired entries and empty subdirectories. Prints the count of pruned entries.
#  * @param None
#  * @return {number} 0 on success.
#  * @example
#  *   pruned_count=$(cache_prune)
#  */
cache_prune() {
  local base_dir
  base_dir=$(_cache_base_dir)
  if [[ ! -d "${base_dir}" ]]; then
    echo "0"
    return 0
  fi

  local count=0
  local entry_file
  for entry_file in "${base_dir}"/**/*.json(N); do
    if _cache_is_entry_expired "${entry_file}"; then
      rm -f "${entry_file}" 2>/dev/null && (( count++ ))
    fi
  done

  # Clean up any empty subdirectories
  find "${base_dir}" -mindepth 1 -type d -empty -delete 2>/dev/null || true

  echo "${count}"
  return 0
}

# /**
#  * @function cache_list
#  * @description Lists cached secret keys and their expiry status (never prints secret values).
#  * @param {string} [prefix] - Optional key prefix filter (e.g., "payments/prod").
#  * @return {number} 0 on success.
#  * @example
#  *   cache_list "payments"
#  */
cache_list() {
  local prefix="${1:-}"
  local base_dir
  base_dir=$(_cache_base_dir)
  [[ -d "${base_dir}" ]] || return 0

  local search_dir="${base_dir}"
  if [[ -n "${prefix}" ]]; then
    local sanitized
    sanitized=$(_cache_sanitize_key "${prefix}") || return 1
    search_dir="${base_dir}/${sanitized}"
    [[ -d "${search_dir}" ]] || return 0
  fi

  local now
  now=$(_cache_now)
  local entry_file rel_key expires_at status_str
  for entry_file in "${search_dir}"/**/*.json(N); do
    rel_key="${entry_file#${base_dir}/}"
    rel_key="${rel_key%.json}"
    expires_at=$(_cache_read_field "${entry_file}" "expires_at")

    if _cache_is_entry_expired "${entry_file}"; then
      status_str="expired"
    elif [[ -z "${expires_at}" || ! "${expires_at}" =~ ^[0-9]+$ ]] || (( expires_at == 0 )); then
      status_str="persistent"
    else
      status_str="valid ($(( expires_at - now ))s remaining)"
    fi

    printf '%s\t%s\n' "${rel_key}" "${status_str}"
  done

  return 0
}

# /**
#  * @function cache_get_or_set
#  * @description Returns the cached secret if valid; otherwise executes the provided command, caches its stdout, and prints it.
#  * @param {string} key - Cache key or organized path (e.g., "myapp/prod/jwt").
#  * @param {number} ttl_seconds - TTL in seconds (0 = persistent/auto-detect JWT exp; pass "" or 0 as appropriate).
#  * @param {string} command... - Command and arguments to execute on cache miss to obtain the secret.
#  * @return {number} 0 on success, non-zero if the command fails or produces empty output.
#  * @example
#  *   token=$(cache_get_or_set "payments/prod/jwt" 3600 my_login_func "prod")
#  */
cache_get_or_set() {
  local key="$1"
  local ttl_seconds="$2"
  shift 2 2>/dev/null || {
    _cache_log_error "cache_get_or_set: usage: cache_get_or_set <key> <ttl_seconds> <command...>"
    return 1
  }

  if (( $# == 0 )); then
    _cache_log_error "cache_get_or_set: callback command is required"
    return 1
  fi

  local cached
  if cached=$(cache_get "${key}"); then
    printf '%s\n' "${cached}"
    return 0
  fi

  local fresh
  fresh=$("$@") || return $?
  if [[ -z "${fresh}" ]]; then
    _cache_log_error "cache_get_or_set: command produced empty secret for '${key}'"
    return 1
  fi

  cache_set "${key}" "${fresh}" "${ttl_seconds}" || return 1
  printf '%s\n' "${fresh}"
  return 0
}
