# functions/09-file.sh

# Protect against double sourcing
if [[ -n "${_FILE_SH_SOURCED:-}" ]]; then
  return 0
fi
readonly _FILE_SH_SOURCED=1

# Ensure config is sourced if available
if [[ -f "${RZSH_DIR:-${PROJECT_ROOT:-.}}/config/config.sh" ]]; then
  source "${RZSH_DIR:-${PROJECT_ROOT:-.}}/config/config.sh"
fi
# Source user-actions for confirm if available
if [[ -f "${RZSH_DIR:-${PROJECT_ROOT:-.}}/functions/07-user-actions.sh" ]]; then
  source "${RZSH_DIR:-${PROJECT_ROOT:-.}}/functions/07-user-actions.sh"
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
#  * @function file_read_to_array
#  * @description Reads a file line-by-line into a Zsh array variable for iteration/looping.
#  * @param {string} file - The file path to read.
#  * @param {string} [array_name=FILE_LINES] - Name of the target array variable to populate.
#  * @param {number} [skip_empty=0] - Set to 1 to skip blank/empty lines.
#  * @return {number} 0 on success, 1 if the file does not exist or array_name is invalid.
#  * @example
#  *   local -a lines
#  *   file_read_to_array "hosts.txt" "lines" 1
#  *   for line in "${lines[@]}"; do
#  *     echo "${line}"
#  *   done
#  */
file_read_to_array() {
  local _file="$1"
  local _array_name="${2:-FILE_LINES}"
  local _skip_empty="${3:-0}"

  if [[ ! -f "${_file}" ]]; then
    return 1
  fi

  if [[ ! "${_array_name}" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
    return 1
  fi

  local -a _lines
  local _line
  while IFS= read -r _line || [[ -n "${_line}" ]]; do
    if (( _skip_empty == 1 )) && [[ -z "${_line//[[:space:]]/}" ]]; then
      continue
    fi
    _lines+=("${_line}")
  done < "${_file}"

  set -A "${_array_name}" "${_lines[@]}"
  return 0
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
#  *   file_copy "old.txt" "ask.txt"
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

# /**
#  * @function file_equals
#  * @description Checks whether two files have identical byte-for-byte contents.
#  * @param {string} file1 - First file path.
#  * @param {string} file2 - Second file path.
#  * @return {number} 0 if identical, 1 if different, 2 if either file does not exist.
#  * @example
#  *   if file_equals "a.txt" "b.txt"; then
#  *     echo "Files are identical"
#  *   fi
#  */
file_equals() {
  local file1="$1"
  local file2="$2"
  if [[ -z "${file1}" || -z "${file2}" || ! -f "${file1}" || ! -f "${file2}" ]]; then
    return 2
  fi
  cmp -s "${file1}" "${file2}"
}

# /**
#  * @function file_compare
#  * @description Compares two files (size, SHA-256 hash, line count, unified diff) and prints/writes a Markdown report.
#  * @param {string} [options] - -h/--help, -o/--output <file>, -s/--silent, -u/--unified <lines>.
#  * @param {string} file1 - First (base) file path.
#  * @param {string} file2 - Second (target) file path.
#  * @return {number} 0 if identical, 1 if different, 2 on error/missing file.
#  * @example
#  *   file_compare -o report.md config_v1.env config_v2.env
#  */
file_compare() {
  local show_help_fc
  show_help_fc() {
    cat << 'EOF'
Usage: file_compare [options] <file1> <file2>

Options:
  -h, --help             Show this help message.
  -o, --output <file>    Write the Markdown comparison report to <file>.
  -s, --silent           Suppress stdout output (still writes to -o if specified).
  -u, --unified <lines>  Number of unified diff context lines (default: 3).

Exit Codes:
  0  Files are identical.
  1  Files differ.
  2  Invalid arguments or missing file.
EOF
  }

  local output_file=""
  local silent_mode=0
  local context_lines=3
  local -a pos_args

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        show_help_fc
        return 0
        ;;
      -o|--output)
        if [[ -z "${2:-}" ]]; then
          printf '[ERROR] Option %s requires a file path.\n' "$1" >&2
          return 2
        fi
        output_file="$2"
        shift 2
        ;;
      -s|--silent)
        silent_mode=1
        shift
        ;;
      -u|--unified)
        if [[ -z "${2:-}" || ! "${2}" =~ ^[0-9]+$ ]]; then
          printf '[ERROR] Option %s requires a non-negative integer.\n' "$1" >&2
          return 2
        fi
        context_lines="$2"
        shift 2
        ;;
      -*)
        printf '[ERROR] Unknown option: %s. Use -h or --help.\n' "$1" >&2
        return 2
        ;;
      *)
        pos_args+=("$1")
        shift
        ;;
    esac
  done

  if (( ${#pos_args} != 2 )); then
    printf '[ERROR] file_compare requires exactly 2 file paths. Use -h or --help.\n' >&2
    return 2
  fi

  local file1="${pos_args[1]}"
  local file2="${pos_args[2]}"

  if [[ ! -f "${file1}" ]]; then
    printf '[ERROR] File not found: %s\n' "${file1}" >&2
    return 2
  fi
  if [[ ! -f "${file2}" ]]; then
    printf '[ERROR] File not found: %s\n' "${file2}" >&2
    return 2
  fi

  local size1 size2 hash1 hash2 lines1 lines2
  size1=$(file_get_size "${file1}" 2>/dev/null || wc -c < "${file1}" | tr -d ' ')
  size2=$(file_get_size "${file2}" 2>/dev/null || wc -c < "${file2}" | tr -d ' ')
  hash1=$(file_hash "${file1}" sha256 2>/dev/null || sha256sum "${file1}" | awk '{print $1}')
  hash2=$(file_hash "${file2}" sha256 2>/dev/null || sha256sum "${file2}" | awk '{print $1}')
  lines1=$(wc -l < "${file1}" | tr -d ' ')
  lines2=$(wc -l < "${file2}" | tr -d ' ')

  local status_label="DIFFERENT"
  local ret_code=1
  local diff_output=""
  if cmp -s "${file1}" "${file2}"; then
    status_label="IDENTICAL"
    ret_code=0
  else
    diff_output=$(diff -u -U "${context_lines}" "${file1}" "${file2}" 2>&1 || true)
  fi

  local md_report
  md_report=$(cat <<EOF
# File Comparison Report

- **File 1:** \`${file1}\`
- **File 2:** \`${file2}\`
- **Status:** **${status_label}**

| Metric | File 1 | File 2 |
| :--- | :--- | :--- |
| Size (bytes) | ${size1} | ${size2} |
| Lines | ${lines1} | ${lines2} |
| SHA-256 | \`${hash1}\` | \`${hash2}\` |
EOF
)

  if (( ret_code == 1 )); then
    md_report+=$'\n\n## Unified Diff\n\n```diff\n'"${diff_output}"$'\n```'
  fi

  if [[ -n "${output_file}" ]]; then
    mkdir -p "${output_file:h}" 2>/dev/null || true
    printf '%s\n' "${md_report}" > "${output_file}"
  fi

  if (( silent_mode == 0 )); then
    printf '%s\n' "${md_report}"
  fi

  return ${ret_code}
}
