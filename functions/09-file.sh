# functions/09-file.sh

# Protect against double sourcing
if [[ -n "${_FILE_SH_SOURCED:-}" ]]; then
  return 0
fi
readonly _FILE_SH_SOURCED=1

# Ensure config is sourced if available
if [[ -f "${PROJECT_ROOT:-.}/config/config.sh" ]]; then
  source "${PROJECT_ROOT:-.}/config/config.sh"
fi
# Source user-actions for confirm if available
if [[ -f "${PROJECT_ROOT:-.}/functions/07-user-actions.sh" ]]; then
  source "${PROJECT_ROOT:-.}/functions/07-user-actions.sh"
fi

# /**
#  * @function file_exists
#  * @description Checks if a path exists and points to a regular file.
#  * @param {string} file - The file path to check.
#  * @return {number} 0 if file exists, 1 otherwise.
#  * @example
#  *   if file_exists "/etc/passwd"; then
#  *     echo "Exists"
#  *   fi
#  */
file_exists() {
  local file="$1"
  if [[ -f "${file}" ]]; then
    return 0
  fi
  return 1
}

# /**
#  * @function file_read
#  * @description Reads and prints the entire contents of a file to stdout.
#  * @param {string} file - The file to read.
#  * @return {number} 0 on success, or non-zero on failure.
#  * @example
#  *   local content
#  *   content=$(file_read "data.txt")
#  */
file_read() {
  local file="$1"
  if [[ ! -f "${file}" ]]; then
    return 1
  fi
  cat "${file}"
}

# /**
#  * @function file_write
#  * @description Writes the specified content to a file, overwriting its previous contents.
#  * @param {string} file - The target file path.
#  * @param {string} content - The content to write.
#  * @return {number} 0 on success.
#  * @example
#  *   file_write "test.txt" "Hello World"
#  */
file_write() {
  local file="$1"
  local content="$2"
  print -- "${content}" > "${file}"
}

# /**
#  * @function file_append
#  * @description Appends the specified content to the end of a file.
#  * @param {string} file - The target file path.
#  * @param {string} content - The content to append.
#  * @return {number} 0 on success.
#  * @example
#  *   file_append "test.txt" "New line contents"
#  */
file_append() {
  local file="$1"
  local content="$2"
  print -- "${content}" >> "${file}"
}

# /**
#  * @function file_copy
#  * @description Copies a file from source to destination.
#  * @param {string} source - Source file path.
#  * @param {string} dest - Destination file path.
#  * @return {number} 0 on success.
#  * @example
#  *   file_copy "old.txt" "new.txt"
#  */
file_copy() {
  local src="$1"
  local dest="$2"
  cp "${src}" "${dest}"
}

# /**
#  * @function file_move
#  * @description Moves or renames a file from source to destination.
#  * @param {string} source - Source file path.
#  * @param {string} dest - Destination file path.
#  * @return {number} 0 on success.
#  * @example
#  *   file_move "draft.txt" "final.txt"
#  */
file_move() {
  local src="$1"
  local dest="$2"
  mv "${src}" "${dest}"
}

# /**
#  * @function file_delete
#  * @description Deletes a file. Requires confirmation unless --force or -f is passed.
#  * @param {string} file - File path to delete.
#  * @param {string} [option] - Pass '--force' or '-f' to skip interactive confirmation.
#  * @return {number} 0 on success or if file doesn't exist, 1 on failure or if canceled.
#  * @example
#  *   file_delete "temp.txt" "--force"
#  */
file_delete() {
  local file="$1"
  local force="$2"
  if [[ ! -e "${file}" ]]; then
    return 0
  fi
  if [[ "${force}" == "--force" || "${force}" == "-f" ]]; then
    rm -f "${file}"
    return $?
  fi
  if typeset -f confirm >/dev/null; then
    if confirm "Are you sure you want to delete ${file}?" "n"; then
      rm -f "${file}"
      return $?
    else
      return 1
    fi
  else
    rm -f "${file}"
    return $?
  fi
}

# /**
#  * @function file_get_size
#  * @description Prints the size of a file in bytes.
#  * @param {string} file - File path.
#  * @return {number} 0 on success, 1 on failure.
#  * @example
#  *   local sz
#  *   sz=$(file_get_size "data.bin")
#  */
file_get_size() {
  local file="$1"
  if [[ ! -f "${file}" ]]; then
    return 1
  fi
  zmodload zsh/stat 2>/dev/null
  if whence zstat &>/dev/null; then
    zstat +size "${file}"
  else
    stat -c %s "${file}" 2>/dev/null || stat -f %z "${file}" 2>/dev/null
  fi
}

# /**
#  * @function file_get_permissions
#  * @description Returns the permissions of a file in octal format (e.g. 644).
#  * @param {string} file - File path.
#  * @return {string} The octal permissions.
#  * @example
#  *   local perms
#  *   perms=$(file_get_permissions "run.sh")
#  */
file_get_permissions() {
  local file="$1"
  if [[ ! -e "${file}" ]]; then
    return 1
  fi
  stat -c "%a" "${file}" 2>/dev/null || stat -f "%Lp" "${file}" 2>/dev/null
}

# /**
#  * @function file_set_permissions
#  * @description Changes the permissions of a file.
#  * @param {string} file - File path.
#  * @param {string} perms - Octal permissions (e.g. 755).
#  * @return {number} 0 on success.
#  * @example
#  *   file_set_permissions "run.sh" "755"
#  */
file_set_permissions() {
  local file="$1"
  local perms="$2"
  chmod "${perms}" "${file}"
}

# /**
#  * @function file_get_owner
#  * @description Prints the username of the owner of a file.
#  * @param {string} file - File path.
#  * @return {string} Owner username.
#  * @example
#  *   local owner
#  *   owner=$(file_get_owner "config.json")
#  */
file_get_owner() {
  local file="$1"
  if [[ ! -e "${file}" ]]; then
    return 1
  fi
  stat -c "%U" "${file}" 2>/dev/null || stat -f "%Su" "${file}" 2>/dev/null
}

# /**
#  * @function file_get_group
#  * @description Prints the group name of a file.
#  * @param {string} file - File path.
#  * @return {string} Group name.
#  * @example
#  *   local grp
#  *   grp=$(file_get_group "config.json")
#  */
file_get_group() {
  local file="$1"
  if [[ ! -e "${file}" ]]; then
    return 1
  fi
  stat -c "%G" "${file}" 2>/dev/null || stat -f "%Sg" "${file}" 2>/dev/null
}

# /**
#  * @function file_backup
#  * @description Creates a backup copy of a file with a timestamp suffix.
#  * @param {string} file - The file path to backup.
#  * @return {string} The created backup file path.
#  * @example
#  *   local backup_path
#  *   backup_path=$(file_backup "database.db")
#  */
file_backup() {
  local file="$1"
  if [[ ! -f "${file}" ]]; then
    return 1
  fi
  local ts
  ts=$(date +%Y%m%d_%H%M%S)
  local backup="${file}.${ts}.bak"
  cp "${file}" "${backup}"
  echo "${backup}"
}

# /**
#  * @function file_restore
#  * @description Restores a file from a timestamped backup path.
#  * @param {string} backup_file - The backup file path.
#  * @return {number} 0 on success.
#  * @example
#  *   file_restore "database.db.20260708_120000.bak"
#  */
file_restore() {
  local backup="$1"
  if [[ ! -f "${backup}" ]]; then
    return 1
  fi
  
  local dest="${backup%.[0-9]*_*.bak}"
  if [[ "${dest}" == "${backup}" ]]; then
    dest="${backup%.bak}"
  fi
  
  cp "${backup}" "${dest}"
}

# /**
#  * @function file_backup_and_restore
#  * @description High-level wrapper to backup or restore files.
#  * @param {string} action - 'backup' or 'restore'.
#  * @param {string} file - Target file path.
#  * @param {string} [backup_path] - Specific backup path (required for restore).
#  * @return {string|number} Backup file path on backup success, or 0 on restore success.
#  * @example
#  *   file_backup_and_restore "backup" "settings.conf"
#  */
file_backup_and_restore() {
  local action="$1"
  local file="$2"
  local backup_path="${3:-}"
  
  if [[ "${action}" == "backup" ]]; then
    file_backup "${file}"
  elif [[ "${action}" == "restore" ]]; then
    # If backup_path is empty, use the file parameter as the backup source
    if [[ -z "${backup_path}" ]]; then
      file_restore "${file}"
    else
      file_restore "${backup_path}"
    fi
  else
    return 1
  fi
}

# /**
#  * @function file_hash
#  * @description Calculates the cryptographic hash of a file.
#  * @param {string} file - File path.
#  * @param {string} [algorithm=sha256] - Hash algorithm (md5, sha1, sha256).
#  * @return {string} The hash value hex digest.
#  * @example
#  *   local hash
#  *   hash=$(file_hash "file.iso" "sha256")
#  */
file_hash() {
  local file="$1"
  local algo="${2:-sha256}"
  
  if [[ ! -f "${file}" ]]; then
    return 1
  fi
  
  case "${algo:l}" in
    md5)    md5sum "${file}" | cut -d' ' -f1 ;;
    sha1)   sha1sum "${file}" | cut -d' ' -f1 ;;
    sha256) sha256sum "${file}" | cut -d' ' -f1 ;;
    *)      return 1 ;;
  esac
}

# /**
#  * @function file_tail
#  * @description Outputs the last N lines of a file.
#  * @param {string} file - File path.
#  * @param {number} [lines=10] - Number of lines to output.
#  * @return {number} 0 on success.
#  * @example
#  *   file_tail "log.txt" 20
#  */
file_tail() {
  local file="$1"
  local lines="${2:-10}"
  if [[ ! -f "${file}" ]]; then
    return 1
  fi
  tail -n "${lines}" "${file}"
}

# /**
#  * @function file_head
#  * @description Outputs the first N lines of a file.
#  * @param {string} file - File path.
#  * @param {number} [lines=10] - Number of lines to output.
#  * @return {number} 0 on success.
#  * @example
#  *   file_head "log.txt" 5
#  */
file_head() {
  local file="$1"
  local lines="${2:-10}"
  if [[ ! -f "${file}" ]]; then
    return 1
  fi
  head -n "${lines}" "${file}"
}

# /**
#  * @function file_grep
#  * @description Searches for a pattern in a file.
#  * @param {string} file - File path.
#  * @param {string} pattern - Search pattern.
#  * @return {number} 0 if pattern found, 1 otherwise.
#  * @example
#  *   file_grep "log.txt" "ERROR"
#  */
file_grep() {
  local file="$1"
  local pattern="$2"
  if [[ ! -f "${file}" ]]; then
    return 1
  fi
  grep "${pattern}" "${file}"
}
