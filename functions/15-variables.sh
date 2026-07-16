# functions/15-variables.sh

# Protect against double sourcing
if [[ -n "${_VARIABLES_SH_SOURCED:-}" ]]; then
  return 0
fi
readonly _VARIABLES_SH_SOURCED=1

# Ensure config is sourced if available
if [[ -f "${PROJECT_ROOT:-.}/config/config.sh" ]]; then
  source "${PROJECT_ROOT:-.}/config/config.sh"
fi

# Ensure arrays are initialized if not already
if [[ ${(t)REPO_NAMES} != *array* ]]; then
  typeset -g -a REPO_NAMES
fi
if [[ ${(t)REPO_LOCATIONS} != *association* ]]; then
  typeset -g -A REPO_LOCATIONS
fi

# /**
#  * @function config_get_var
#  * @description Retrieves the value of a global configuration variable, returning a default value if the variable is unset or empty.
#  * @param {string} var_name - The name of the configuration variable.
#  * @param {string} [default_value] - Optional fallback value.
#  * @return {string} The configuration value or the fallback default.
#  * @example
#  *   local level
#  *   level=$(config_get_var LOG_LEVEL "INFO")
#  */
config_get_var() {
  local var_name="$1"
  local default_val="$2"
  if [[ -z "${var_name}" ]]; then
    return 1
  fi
  local val="${(P)var_name}"
  echo "${val:-${default_val}}"
}

# /**
#  * @function config_set_var
#  * @description Sets the value of a global configuration variable dynamically.
#  * @param {string} var_name - The name of the configuration variable.
#  * @param {string} value - The value to assign to the variable.
#  * @return {number} 0 on success, or non-zero on failure.
#  * @example
#  *   config_set_var LOG_LEVEL "DEBUG"
#  */
config_set_var() {
  local var_name="$1"
  local value="$2"
  if [[ -z "${var_name}" ]]; then
    return 1
  fi
  typeset -g "${var_name}=${value}"
  return 0
}

# /**
#  * @function config_unset_var
#  * @description Unsets/removes a global configuration variable.
#  * @param {string} var_name - The name of the configuration variable to unset.
#  * @return {number} 0 on success, or non-zero on failure.
#  * @example
#  *   config_unset_var LOG_LEVEL
#  */
config_unset_var() {
  local var_name="$1"
  if [[ -z "${var_name}" ]]; then
    return 1
  fi
  unset "${var_name}"
  return 0
}

# /**
#  * @function config_get_repo_location
#  * @description Gets the location of a repository from the REPO_LOCATIONS configuration map.
#  * @param {string} repo_name - The name of the repository.
#  * @return {string} The repository directory location path.
#  * @example
#  *   local loc
#  *   loc=$(config_get_repo_location "service1")
#  */
config_get_repo_location() {
  local repo_name="$1"
  if [[ -z "${repo_name}" ]]; then
    return 1
  fi
  local ref="REPO_LOCATIONS[${repo_name}]"
  echo "${(P)ref}"
}

# /**
#  * @function config_set_repo_location
#  * @description Configures the directory path of a repository inside REPO_LOCATIONS, and registers it in REPO_NAMES if not already present.
#  * @param {string} repo_name - The name of the repository.
#  * @param {string} location - The absolute path of the repository.
#  * @return {number} 0 on success, or non-zero on failure.
#  * @example
#  *   config_set_repo_location "service4" "/home/ubuntu/service4"
#  */
config_set_repo_location() {
  local repo_name="$1"
  local location="$2"
  if [[ -z "${repo_name}" || -z "${location}" ]]; then
    return 1
  fi
  # Ensure repo name is added to REPO_NAMES if not already present
  if [[ ${REPO_NAMES[(Ie)${repo_name}]} -eq 0 ]]; then
    REPO_NAMES+=("${repo_name}")
  fi
  eval "REPO_LOCATIONS[\$repo_name]=\$location"
  return 0
}

# /**
#  * @function config_unset_repo_location
#  * @description Unregisters a repository's location from REPO_LOCATIONS and removes it from the REPO_NAMES list.
#  * @param {string} repo_name - The name of the repository to remove.
#  * @return {number} 0 on success, or non-zero on failure.
#  * @example
#  *   config_unset_repo_location "service1"
#  */
config_unset_repo_location() {
  local repo_name="$1"
  if [[ -z "${repo_name}" ]]; then
    return 1
  fi
  unset "REPO_LOCATIONS[$repo_name]"
  REPO_NAMES=(${REPO_NAMES:#${repo_name}})
  return 0
}

# /**
#  * @function config_list_repos
#  * @description Prints all registered repository names and their mapped locations.
#  * @return {number} 0 on success.
#  * @example
#  *   config_list_repos
#  */
config_list_repos() {
  local repo_name
  for repo_name in "${REPO_NAMES[@]}"; do
    local ref="REPO_LOCATIONS[${repo_name}]"
    local location="${(P)ref}"
    printf "%s: %s\n" "${repo_name}" "${location:-(not set)}"
  done
  return 0
}
