# functions/10-directory.sh

# Protect against double sourcing
if [[ -n "${_DIRECTORY_SH_SOURCED:-}" ]]; then
  return 0
fi
readonly _DIRECTORY_SH_SOURCED=1

# Ensure config is sourced if available
if [[ -f "${PROJECT_ROOT:-.}/config/config.sh" ]]; then
  source "${PROJECT_ROOT:-.}/config/config.sh"
fi
# Source user-actions for confirm if available
if [[ -f "${PROJECT_ROOT:-.}/functions/07-user-actions.sh" ]]; then
  source "${PROJECT_ROOT:-.}/functions/07-user-actions.sh"
fi

# /**
#  * @function dir_exists
#  * @description Checks if a path exists and is a directory.
#  * @param {string} dir - Directory path.
#  * @return {number} 0 if directory exists, 1 otherwise.
#  * @example
#  *   if dir_exists "/var/log"; then
#  *     echo "Directory exists"
#  *   fi
#  */
dir_exists() {
  local dir="$1"
  if [[ -d "${dir}" ]]; then
    return 0
  fi
  return 1
}

# /**
#  * @function dir_create
#  * @description Creates a directory, including any necessary parent directories.
#  * @param {string} dir - Directory path.
#  * @return {number} 0 on success.
#  * @example
#  *   dir_create "/tmp/my_app/temp"
#  */
dir_create() {
  local dir="$1"
  mkdir -p "${dir}"
}

# /**
#  * @function dir_delete
#  * @description Deletes a directory recursively. Requires confirmation unless --force or -f is passed.
#  * @param {string} dir - Directory path.
#  * @param {string} [option] - Pass '--force' or '-f' to skip interactive confirmation.
#  * @return {number} 0 on success, 1 on failure or if canceled.
#  * @example
#  *   dir_delete "/tmp/my_app/temp" "--force"
#  */
dir_delete() {
  local dir="$1"
  local force="$2"
  if [[ ! -d "${dir}" ]]; then
    return 0
  fi
  if [[ "${force}" == "--force" || "${force}" == "-f" ]]; then
    rm -rf "${dir}"
    return $?
  fi
  if typeset -f confirm >/dev/null; then
    if confirm "Are you sure you want to delete directory ${dir}?" "n"; then
      rm -rf "${dir}"
      return $?
    else
      return 1
    fi
  else
    rm -rf "${dir}"
    return $?
  fi
}

# /**
#  * @function dir_copy
#  * @description Recursively copies a directory to a destination.
#  * @param {string} source - Source directory.
#  * @param {string} dest - Destination directory.
#  * @return {number} 0 on success.
#  * @example
#  *   dir_copy "/tmp/src" "/tmp/dest"
#  */
dir_copy() {
  local src="$1"
  local dest="$2"
  cp -r "${src}" "${dest}"
}

# /**
#  * @function dir_move
#  * @description Moves or renames a directory to a new destination.
#  * @param {string} source - Source directory.
#  * @param {string} dest - Destination directory.
#  * @return {number} 0 on success.
#  * @example
#  *   dir_move "/tmp/src" "/tmp/moved"
#  */
dir_move() {
  local src="$1"
  local dest="$2"
  mv "${src}" "${dest}"
}

# /**
#  * @function dir_list
#  * @description Lists files and folders directly inside a directory that match a pattern.
#  * @param {string} dir - Directory path.
#  * @param {string} [pattern=*] - Glob pattern to filter results.
#  * @return {string} Newline-separated list of filenames.
#  * @example
#  *   dir_list "/tmp" "*.txt"
#  */
dir_list() {
  local dir="$1"
  local pattern="${2:-*}"
  
  if [[ ! -d "${dir}" ]]; then
    return 1
  fi
  
  local files
  files=( "${dir}"/$~pattern(N) )
  
  local f
  for f in "${files[@]}"; do
    echo "${f:t}"
  done
}

# /**
#  * @function dir_size
#  * @description Calculates the total size of all files in a directory in bytes.
#  * @param {string} dir - Directory path.
#  * @return {number} Directory size in bytes.
#  * @example
#  *   local sz
#  *   sz=$(dir_size "/var/log")
#  */
dir_size() {
  local dir="$1"
  if [[ ! -d "${dir}" ]]; then
    return 1
  fi
  
  local sz
  sz=$(du -sb "${dir}" 2>/dev/null | cut -f1)
  if [[ -z "${sz}" ]]; then
    sz=$(du -sk "${dir}" 2>/dev/null | cut -f1)
    if [[ -n "${sz}" ]]; then
      echo $(( sz * 1024 ))
    else
      echo 0
    fi
  else
    echo "${sz}"
  fi
}

# /**
#  * @function dir_is_empty
#  * @description Checks if a directory is empty.
#  * @param {string} dir - Directory path.
#  * @return {number} 0 if empty, 1 otherwise.
#  * @example
#  *   if dir_is_empty "/tmp/empty_dir"; then
#  *     echo "Is empty"
#  *   fi
#  */
dir_is_empty() {
  local dir="$1"
  if [[ ! -d "${dir}" ]]; then
    return 1
  fi
  
  local files
  files=( "${dir}"/*(N) "${dir}"/.*(N) )
  files=( ${files:#*/.} )
  files=( ${files:#*/..} )
  
  if (( ${#files} == 0 )); then
    return 0
  else
    return 1
  fi
}

# /**
#  * @function dir_clean
#  * @description Deletes all files and directories inside a directory without deleting the directory itself.
#  * @param {string} dir - Directory path.
#  * @return {number} 0 on success.
#  * @example
#  *   dir_clean "/tmp/logs"
#  */
dir_clean() {
  local dir="$1"
  if [[ ! -d "${dir}" ]]; then
    return 1
  fi
  
  rm -rf "${dir}"/* "${dir}"/.*(N) 2>/dev/null
  return 0
}

# /**
#  * @function dir_tree
#  * @description Prints a tree-like visualization of a directory structure.
#  * @param {string} dir - Directory path.
#  * @return {string} Tree output.
#  * @example
#  *   dir_tree "/tmp/app"
#  */
dir_tree() {
  local dir="$1"
  if [[ ! -d "${dir}" ]]; then
    return 1
  fi
  
  if command -v tree &>/dev/null; then
    tree "${dir}"
    return 0
  fi
  
  _walk_tree() {
    local current_dir="$1"
    local prefix="$2"
    local files
    files=( "${current_dir}"/*(N) )
    local i
    for (( i = 1; i <= ${#files}; i++ )); do
      local f="${files[i]}"
      local is_last=$(( i == ${#files} ))
      local pointer
      local next_prefix
      if (( is_last == 1 )); then
        pointer="└── "
        next_prefix="${prefix}    "
      else
        pointer="├── "
        next_prefix="${prefix}│   "
      fi
      echo "${prefix}${pointer}${f:t}"
      if [[ -d "${f}" ]]; then
        _walk_tree "${f}" "${next_prefix}"
      fi
    done
  }
  
  echo "${dir:t}"
  _walk_tree "${dir}" ""
}

# /**
#  * @function dir_sync
#  * @description Synchronizes the contents of a source directory to a destination directory.
#  * @param {string} source - Source directory.
#  * @param {string} dest - Destination directory.
#  * @return {number} 0 on success.
#  * @example
#  *   dir_sync "/tmp/src" "/tmp/dest"
#  */
dir_sync() {
  local src="$1"
  local dest="$2"
  
  if [[ ! -d "${src}" ]]; then
    return 1
  fi
  
  if command -v rsync &>/dev/null; then
    rsync -a --delete "${src}/" "${dest}/"
  else
    mkdir -p "${dest}"
    cp -ru "${src}"/. "${dest}/"
  fi
}

# /**
#  * @function dir_watch
#  * @description Watches a directory for file system changes and runs a callback function.
#  * @param {string} dir - Directory path.
#  * @param {string} callback - Callback function name.
#  * @param {number} [iterations=5] - Number of iterations to poll in non-interactive/test environments. Pass '0' for infinite.
#  * @return {void}
#  * @example
#  *   on_change() {
#  *     echo "Change detected: $1"
#  *   }
#  *   dir_watch "/tmp/app" "on_change" 3
#  */
dir_watch() {
  local dir="$1"
  local callback="$2"
  local max_iter="${3:-5}"
  
  if [[ ! -d "${dir}" ]]; then
    return 1
  fi

  local last_hash=""
  local curr_hash
  local iter=0
  
  while true; do
    if (( max_iter > 0 && iter >= max_iter )); then
      break
    fi
    
    curr_hash=$(find "${dir}" -type f -printf "%T@ %p\n" 2>/dev/null | sha256sum)
    if [[ -n "${last_hash}" && "${last_hash}" != "${curr_hash}" ]]; then
      "${callback}" "${dir}" "modify"
    fi
    last_hash="${curr_hash}"
    
    if (( max_iter > 0 )); then
      (( iter++ ))
    fi
    sleep 0.2
  done
}
