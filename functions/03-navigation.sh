# functions/03-navigation.sh

# Protect against double sourcing
if [[ -n "${_NAVIGATION_SH_SOURCED:-}" ]]; then
  return 0
fi
readonly _NAVIGATION_SH_SOURCED=1

# Ensure config is sourced if available
if [[ -f "${PROJECT_ROOT:-.}/config/config.sh" ]]; then
  source "${PROJECT_ROOT:-.}/config/config.sh"
fi

# /**
#  * @function current_directory
#  * @description Returns the absolute path of the current working directory.
#  * @param None
#  * @return {string} The absolute path.
#  * @example
#  *   local cur
#  *   cur=$(current_directory)
#  */
current_directory() {
  echo "${PWD}"
}

# /**
#  * @function dir_up
#  * @description Returns the path resulting from moving up 'n' directories from the current directory.
#  * @param {number} [n=1] - The number of directories to move up.
#  * @return {string} The resolved directory path.
#  * @example
#  *   local parent
#  *   parent=$(dir_up 2)
#  */
dir_up() {
  local n="${1:-1}"
  local p="${PWD}"
  local i
  for (( i = 0; i < n; i++ )); do
    p="${p:h}"
  done
  echo "${p}"
}

# /**
#  * @function absolute_path
#  * @description Converts a relative path into an absolute path using Zsh modifiers.
#  * @param {string} relative_path - The relative path to resolve.
#  * @return {string} The absolute path.
#  * @example
#  *   local abs
#  *   abs=$(absolute_path "./config")
#  */
absolute_path() {
  local rel_path="$1"
  echo "${rel_path:A}"
}

# /**
#  * @function to_project_root
#  * @description Changes the current working directory to the project root directory.
#  * @param None
#  * @return {number} 0 on success, or 1 if PROJECT_ROOT is not set or directory change fails.
#  * @example
#  *   to_project_root
#  */
to_project_root() {
  if [[ -z "${PROJECT_ROOT}" ]]; then
    return 1
  fi
  cd "${PROJECT_ROOT}" || return 1
}

# /**
#  * @function get_project_root
#  * @description Returns the absolute path of the project root directory.
#  * @param None
#  * @return {string} The project root path.
#  * @example
#  *   local root
#  *   root=$(get_project_root)
#  */
get_project_root() {
  echo "${PROJECT_ROOT:-}"
}

# /**
#  * @function is_inside_git_repo
#  * @description Checks if the current directory is inside a Git repository.
#  * @param None
#  * @return {number} 0 if inside a Git repository, 1 otherwise.
#  * @example
#  *   if is_inside_git_repo; then
#  *     echo "Inside Git"
#  *   fi
#  */
is_inside_git_repo() {
  if ! command -v git &>/dev/null; then
    return 1
  fi
  git rev-parse --is-inside-work-tree &>/dev/null
}

# /**
#  * @function normalize_path
#  * @description Normalizes a path by resolving relative components (. and ..) and symbolic links.
#  * @param {string} path - The path to normalize.
#  * @return {string} The normalized path.
#  * @example
#  *   local clean
#  *   clean=$(normalize_path "/a/b/../c")
#  */
normalize_path() {
  local p="$1"
  echo "${p:A}"
}

# /**
#  * @function ensure_directory_exists
#  * @description Creates the specified directory and any parent directories if they do not exist.
#  * @param {string} path - The directory path to ensure exists.
#  * @return {number} 0 on success, or 1 on failure.
#  * @example
#  *   ensure_directory_exists "/tmp/my_app/logs"
#  */
ensure_directory_exists() {
  local p="$1"
  if [[ -z "${p}" ]]; then
    return 1
  fi
  mkdir -p "${p}"
}
