# functions/10-directory.sh

# Protect against double sourcing
if [[ -n "${_DIRECTORY_SH_SOURCED:-}" ]]; then
  return 0
fi
readonly _DIRECTORY_SH_SOURCED=1

# Ensure config is sourced if available
if [[ -f "${RZSH_DIR:-${PROJECT_ROOT:-.}}/config/config.sh" ]]; then
  source "${RZSH_DIR:-${PROJECT_ROOT:-.}}/config/config.sh"
fi
# Source user-actions for confirm if available
if [[ -f "${RZSH_DIR:-${PROJECT_ROOT:-.}}/functions/07-user-actions.sh" ]]; then
  source "${RZSH_DIR:-${PROJECT_ROOT:-.}}/functions/07-user-actions.sh"
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
#  * @description Moves or renames a directory to a ask destination.
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
    local i f is_last pointer next_prefix
    for (( i = 1; i <= ${#files}; i++ )); do
      f="${files[i]}"
      is_last=$(( i == ${#files} ))
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

# /**
#  * @function dir_compare
#  * @description Recursively compares two directories and generates a Markdown report of added, removed, modified, and identical files.
#  * @param {string} [options] - -h/--help, -o/--output <file>, -s/--silent, --diff, --ignore <csv>.
#  * @param {string} dir1 - First (base) directory path.
#  * @param {string} dir2 - Second (target) directory path.
#  * @return {number} 0 if directories are identical, 1 if differences exist, 2 on invalid arguments or missing directory.
#  * @example
#  *   dir_compare --diff -o dir_report.md ./build_v1 ./build_v2
#  */
dir_compare() {
  local show_help_dc
  show_help_dc() {
    cat << 'EOF'
Usage: dir_compare [options] <dir1> <dir2>

Options:
  -h, --help            Show this help message.
  -o, --output <file>   Write the Markdown comparison report to <file>.
  -s, --silent          Suppress stdout output (still writes to -o if specified).
      --diff            Include unified diffs for modified files.
      --ignore <csv>    Comma-separated folder/file names to ignore (default: $GIT_IGNORE_FOLDERS or ".git,.idea,vendor").

Exit Codes:
  0  Directories have identical file contents.
  1  Differences found between directories.
  2  Invalid arguments or missing directory.
EOF
  }

  local output_file=""
  local silent_mode=0
  local include_diff=0
  local ignore_csv="${GIT_IGNORE_FOLDERS:-.git,.idea,vendor}"
  local -a pos_args

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        show_help_dc
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
      --diff)
        include_diff=1
        shift
        ;;
      --ignore)
        if [[ -z "${2:-}" ]]; then
          printf '[ERROR] Option %s requires a comma-separated list.\n' "$1" >&2
          return 2
        fi
        ignore_csv="$2"
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
    printf '[ERROR] dir_compare requires exactly 2 directory paths. Use -h or --help.\n' >&2
    return 2
  fi

  local dir1="${pos_args[1]:A}"
  local dir2="${pos_args[2]:A}"

  if [[ ! -d "${pos_args[1]}" ]]; then
    printf '[ERROR] Directory not found: %s\n' "${pos_args[1]}" >&2
    return 2
  fi
  if [[ ! -d "${pos_args[2]}" ]]; then
    printf '[ERROR] Directory not found: %s\n' "${pos_args[2]}" >&2
    return 2
  fi

  local -a ignore_list
  if [[ -n "${ignore_csv}" ]]; then
    ignore_list=( ${(s:,:)ignore_csv} )
  fi

  # Helper to collect sorted relative file paths under a directory, respecting ignore_list
  local _collect_rel_files
  _collect_rel_files() {
    local base="$1"
    local -a find_args
    find_args=( "${base}" )
    if (( ${#ignore_list} > 0 )); then
      local pat first=1
      find_args+=( "(" )
      for pat in "${ignore_list[@]}"; do
        pat="${pat// /}"
        [[ -z "${pat}" ]] && continue
        if (( first == 0 )); then
          find_args+=( "-o" )
        fi
        find_args+=( "-name" "${pat}" )
        first=0
      done
      if (( first == 0 )); then
        find_args+=( ")" "-prune" "-o" )
      else
        find_args=( "${base}" )
      fi
    fi
    find_args+=( "-type" "f" "-print" )
    find "${find_args[@]}" 2>/dev/null | sed "s|^${base}/||" | LC_ALL=C sort
  }

  local -a files1 files2
  files1=( ${(f)"$(_collect_rel_files "${dir1}")"} )
  files2=( ${(f)"$(_collect_rel_files "${dir2}")"} )

  local -A map1 map2 all_keys
  local f
  for f in "${files1[@]}"; do
    [[ -n "${f}" ]] || continue
    map1[${f}]=1
    all_keys[${f}]=1
  done
  for f in "${files2[@]}"; do
    [[ -n "${f}" ]] || continue
    map2[${f}]=1
    all_keys[${f}]=1
  done

  local -a only1 only2 modified identical
  only1=()
  only2=()
  modified=()
  identical=()

  for f in "${(@ko)all_keys}"; do
    if [[ -n "${map1[${f}]:-}" && -z "${map2[${f}]:-}" ]]; then
      only1+=("${f}")
    elif [[ -z "${map1[${f}]:-}" && -n "${map2[${f}]:-}" ]]; then
      only2+=("${f}")
    else
      if cmp -s "${dir1}/${f}" "${dir2}/${f}"; then
        identical+=("${f}")
      else
        modified+=("${f}")
      fi
    fi
  done

  local status_label="IDENTICAL"
  local ret_code=0
  if (( ${#only1} > 0 || ${#only2} > 0 || ${#modified} > 0 )); then
    status_label="DIFFERENT"
    ret_code=1
  fi

  local md_report
  md_report=$(cat <<EOF
# Directory Comparison Report

- **Directory 1:** \`${dir1}\`
- **Directory 2:** \`${dir2}\`
- **Status:** **${status_label}**

| Category | Count |
| :--- | :---: |
| Only in Directory 1 | ${#only1} |
| Only in Directory 2 | ${#only2} |
| Modified | ${#modified} |
| Identical | ${#identical} |
EOF
)

  if (( ${#only1} > 0 )); then
    md_report+=$'\n\n## Only in Directory 1\n'
    for f in "${only1[@]}"; do
      md_report+=$'\n- `'"${f}"'`'
    done
  fi

  if (( ${#only2} > 0 )); then
    md_report+=$'\n\n## Only in Directory 2\n'
    for f in "${only2[@]}"; do
      md_report+=$'\n- `'"${f}"'`'
    done
  fi

  if (( ${#modified} > 0 )); then
    md_report+=$'\n\n## Modified Files\n'
    for f in "${modified[@]}"; do
      md_report+=$'\n- `'"${f}"'`'
      if (( include_diff == 1 )); then
        local d_out
        d_out=$(diff -u "${dir1}/${f}" "${dir2}/${f}" 2>&1 || true)
        md_report+=$'\n\n```diff\n'"${d_out}"$'\n```'
      fi
    done
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
