# functions/05-git.sh

# Protect against double sourcing
if [[ -n "${_GIT_SH_SOURCED:-}" ]]; then
  return 0
fi
readonly _GIT_SH_SOURCED=1

# Ensure config & logs are sourced if available
if [[ -f "${RZSH_DIR:-${PROJECT_ROOT:-.}}/config/config.sh" ]]; then
  source "${RZSH_DIR:-${PROJECT_ROOT:-.}}/config/config.sh"
fi
if [[ -f "${RZSH_DIR:-${PROJECT_ROOT:-.}}/functions/01-logs.sh" ]]; then
  source "${RZSH_DIR:-${PROJECT_ROOT:-.}}/functions/01-logs.sh"
fi

# /**
#  * @function git_get_current_branch
#  * @description Outputs the name of the current Git branch.
#  * @param None
#  * @return {string} The active branch name.
#  * @example
#  *   local branch
#  *   branch=$(git_get_current_branch)
#  */
git_get_current_branch() {
  git branch --show-current 2>/dev/null || git rev-parse --abbrev-ref HEAD 2>/dev/null
}

# /**
#  * @function git_is_clean
#  * @description Checks if the working tree has no uncommitted changes (both tracked and untracked).
#  * @param None
#  * @return {number} 0 if clean, 1 if dirty.
#  * @example
#  *   if git_is_clean; then
#  *     echo "Working tree clean"
#  *   fi
#  */
git_is_clean() {
  git diff --quiet 2>/dev/null && git diff --cached --quiet 2>/dev/null
}

# /**
#  * @function git_get_root
#  * @description Returns the absolute path of the root directory of the current Git repository.
#  * @param None
#  * @return {string} The absolute path of Git root.
#  * @example
#  *   local git_root
#  *   git_root=$(git_get_root)
#  */
git_get_root() {
  git rev-parse --show-toplevel 2>/dev/null
}

# /**
#  * @function git_status_message
#  * @description Returns a short status message summary of the current Git repository.
#  * @param None
#  * @return {string} Short status output.
#  * @example
#  *   git_status_message
#  */
git_status_message() {
  git status --short 2>/dev/null
}

# /**
#  * @function git_commit
#  * @description Stages all changes and commits them with the given message.
#  * @param {string} message - Commit message.
#  * @return {number} 0 on success, or non-zero on failure.
#  * @example
#  *   git_commit "fix: update configurations"
#  */
git_commit() {
  local msg="$1"
  if [[ -z "${msg}" ]]; then
    return 1
  fi
  git add -A && git commit -m "${msg}"
}

# /**
#  * @function git_push
#  * @description Pushes the current branch to the origin remote.
#  * @param None
#  * @return {number} 0 on success.
#  * @example
#  *   git_push
#  */
git_push() {
  local branch
  branch=$(git_get_current_branch)
  if [[ -z "${branch}" ]]; then
    return 1
  fi
  git push origin "${branch}"
}

# /**
#  * @function git_pull
#  * @description Pulls changes for the current branch from origin remote.
#  * @param None
#  * @return {number} 0 on success.
#  * @example
#  *   git_pull
#  */
git_pull() {
  local branch
  branch=$(git_get_current_branch)
  if [[ -z "${branch}" ]]; then
    return 1
  fi
  git pull origin "${branch}"
}

# /**
#  * @function git_safe_pull
#  * @description Safely pulls changes by stashing local changes, pulling, and then popping the stash.
#  * @param None
#  * @return {number} Exit code of the pull command.
#  * @example
#  *   git_safe_pull
#  */
git_safe_pull() {
  local stashed=0
  if ! git_is_clean; then
    git stash -u &>/dev/null
    stashed=1
  fi
  
  git_pull
  local pull_status=$?
  
  if (( stashed == 1 )); then
    git stash pop &>/dev/null
  fi
  
  return ${pull_status}
}

# /**
#  * @function git_branch_exists
#  * @description Checks if a branch exists locally or on the remote origin.
#  * @param {string} branch - The branch name to verify.
#  * @return {number} 0 if exists, 1 otherwise.
#  * @example
#  *   if git_branch_exists "main"; then
#  *     echo "Main branch exists"
#  *   fi
#  */
git_branch_exists() {
  local branch="$1"
  if [[ -z "${branch}" ]]; then
    return 1
  fi
  git show-ref --verify --quiet "refs/heads/${branch}" || git show-ref --verify --quiet "refs/remotes/origin/${branch}"
}

# /**
#  * @function git_get_commit_hash
#  * @description Returns the full SHA-1 hash of the current HEAD commit.
#  * @param None
#  * @return {string} The commit hash.
#  * @example
#  *   local commit
#  *   commit=$(git_get_commit_hash)
#  */
git_get_commit_hash() {
  git rev-parse HEAD 2>/dev/null
}

# /**
#  * @function git_get_commit_message
#  * @description Returns the subject line of the commit message for the specified commit hash.
#  * @param {string} [hash=HEAD] - The commit hash.
#  * @return {string} The commit subject message.
#  * @example
#  *   local msg
#  *   msg=$(git_get_commit_message "f3c8b90")
#  */
git_get_commit_message() {
  local commit_hash="${1:-HEAD}"
  git log -1 --format="%s" "${commit_hash}" 2>/dev/null
}

# /**
#  * @function git_compare_branches
#  * @description Compares two git branches, outputs a structured summary, and optionally writes a Markdown report.
#  * @param {string} [--help|-h] - Show help message.
#  * @param {string} [--output|-o <file>] - Write the Markdown report to a specific file.
#  * @param {string} [--silent|-s] - Do not output details to stdout.
#  * @param {string} [branch_a] - The first branch to compare (default: current branch).
#  * @param {string} [branch_b] - The second branch to compare (default: default branch of repo).
#  * @return {number} 0 on success, or 1 on failure.
#  * @example
#  *   git_compare_branches --silent --output "./report.md" main feature
#  */
git_compare_branches() {
  # Ensure navigation functions are sourced
  if ! typeset -f is_inside_git_repo >/dev/null; then
    if [[ -f "${RZSH_DIR:-${PROJECT_ROOT:-.}}/functions/03-navigation.sh" ]]; then
      source "${RZSH_DIR:-${PROJECT_ROOT:-.}}/functions/03-navigation.sh"
    fi
  fi

  show_help_func() {
    cat << EOF
Usage: git_compare_branches [options] [<branch_a>] [<branch_b>]

Options:
  -h, --help           Show this help message.
  -o, --output <file>  Write the Markdown report to a specific file.
  -s, --silent         Do not output details to stdout (still writes to file if specified).

Arguments:
  <branch_a>           The first branch to compare (default: current branch).
  <branch_b>           The second branch to compare (default: default branch of repo).

If no branches are specified:
  Compares current branch against the default branch (usually 'main' or 'master').
If one branch is specified:
  Compares the specified branch against the current branch.
EOF
  }

  local output_file=""
  local silent_mode=0
  local -a branches

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        show_help_func
        return 0
        ;;
      -o|--output)
        output_file="$2"
        shift 2
        ;;
      -s|--silent)
        silent_mode=1
        shift
        ;;
      -*)
        log_error "Unknown option: $1. Use -h or --help for usage."
        return 1
        ;;
      *)
        branches+=("$1")
        shift
        ;;
    esac
  done

  # 2. Check if inside git repo
  if ! is_inside_git_repo; then
    log_error "Not inside a Git repository."
    return 1
  fi

  local git_root
  git_root=$(git_get_root)
  local orig_pwd="${PWD}"
  # Go to git root to run all diff commands from there
  cd "${git_root}" || {
    log_error "Failed to navigate to Git repository root: ${git_root}"
    return 1
  }

  restore_and_return() {
    local ret_code="$1"
    cd "${orig_pwd}" 2>/dev/null
    return "${ret_code}"
  }

  # 3. Determine branches to compare
  local branch_a=""
  local branch_b=""
  local current_branch
  current_branch=$(git_get_current_branch)

  if [[ ${#branches} -eq 0 ]]; then
    # Default comparison: compare default branch (base) with current branch (target)
    local default_branch=""
    if git_branch_exists "main"; then
      default_branch="main"
    elif git_branch_exists "master"; then
      default_branch="master"
    else
      log_error "Could not detect default branch (neither 'main' nor 'master' exists). Please specify branches explicitly."
      restore_and_return 1
    fi
    branch_a="${default_branch}"
    branch_b="${current_branch}"
  elif [[ ${#branches} -eq 1 ]]; then
    # One branch specified: compare it (base) with current branch (target)
    branch_a="${branches[1]}"
    branch_b="${current_branch}"
  elif [[ ${#branches} -eq 2 ]]; then
    # Two branches specified
    branch_a="${branches[1]}"
    branch_b="${branches[2]}"
  else
    log_error "Too many arguments. Expected 0, 1, or 2 branch names."
    restore_and_return 1
  fi

  # Validate branch existence
  if ! git_branch_exists "${branch_a}"; then
    log_error "Branch '${branch_a}' does not exist."
    restore_and_return 1
  fi
  if ! git_branch_exists "${branch_b}"; then
    log_error "Branch '${branch_b}' does not exist."
    restore_and_return 1
  fi

  log_info "Comparing branch '${branch_a}' (base) with '${branch_b}' (target)..."

  # 4. Get diff name status
  local -a diff_lines
  diff_lines=( ${(f)"$(git diff --name-status "${branch_a}" "${branch_b}" 2>/dev/null)"} )

  local -a added_files
  local -a modified_files
  local -a deleted_files
  local -a renamed_files
  local -a other_files

  local -a ignore_folders
  ignore_folders=( ${(s:,:)GIT_IGNORE_FOLDERS} )

  local line diff_status file1 file2 should_ignore folder
  for line in "${diff_lines[@]}"; do
    [[ -z "${line}" ]] && continue
    IFS=$'\t' read -r diff_status file1 file2 <<< "${line}"
    
    should_ignore=0
    for folder in "${ignore_folders[@]}"; do
      [[ -z "${folder}" ]] && continue
      if [[ "${file1}" == "${folder}" ]] || [[ "${file1}" == "${folder}"/* ]] || [[ "${file1}" == */"${folder}"/* ]]; then
        should_ignore=1
        break
      fi
      if [[ -n "${file2}" ]]; then
        if [[ "${file2}" == "${folder}" ]] || [[ "${file2}" == "${folder}"/* ]] || [[ "${file2}" == */"${folder}"/* ]]; then
          should_ignore=1
          break
        fi
      fi
    done

    if (( should_ignore == 1 )); then
      continue
    fi
    
    if [[ "${diff_status}" == A ]]; then
      added_files+=("${file1}")
    elif [[ "${diff_status}" == M ]]; then
      modified_files+=("${file1}")
    elif [[ "${diff_status}" == D ]]; then
      deleted_files+=("${file1}")
    elif [[ "${diff_status}" =~ ^R ]]; then
      renamed_files+=("${file1} -> ${file2}")
    else
      other_files+=("${file1}")
    fi
  done

  local total_changes=$(( ${#added_files} + ${#modified_files} + ${#deleted_files} + ${#renamed_files} + ${#other_files} ))

  # 5. Build terminal presentation & file representation
  local terminal_output=""
  local markdown_report=""

  # Setup color codes (using variables for cleaner look)
  local reset="\e[0m"
  local bold="\e[1m"
  local red="\e[31m"
  local green="\e[32m"
  local yellow="\e[33m"
  local blue="\e[34m"
  local magenta="\e[35m"
  local cyan="\e[36m"

  # Markdown Report Header
  markdown_report+="# Git Branch Comparison Report\n"
  markdown_report+="* **Generated at:** $(date)\n"
  markdown_report+="* **Base Branch:** \`${branch_a}\`\n"
  markdown_report+="* **Target Branch:** \`${branch_b}\`\n"
  markdown_report+="* **Total Files Changed:** ${total_changes}\n\n"

  # Terminal Header
  terminal_output+="${bold}================================================================================${reset}\n"
  terminal_output+="${bold}  Git Branch Comparison Report${reset}\n"
  terminal_output+="${bold}================================================================================${reset}\n"
  terminal_output+="* Base Branch:   ${cyan}${branch_a}${reset}\n"
  terminal_output+="* Target Branch: ${cyan}${branch_b}${reset}\n"
  terminal_output+="* Total Changes: ${bold}${total_changes}${reset}\n\n"

  # Add Summary of Categories
  markdown_report+="## Summary of Changes\n"
  markdown_report+="| Change Type | Count |\n"
  markdown_report+="|---|---|\n"
  markdown_report+="| [A] Added | ${#added_files} |\n"
  markdown_report+="| [M] Modified | ${#modified_files} |\n"
  markdown_report+="| [D] Deleted | ${#deleted_files} |\n"
  markdown_report+="| [R] Renamed | ${#renamed_files} |\n"
  markdown_report+="| [Other] Others | ${#other_files} |\n\n"

  terminal_output+="${bold}Summary of Changes:${reset}\n"
  terminal_output+="  [A] Added:     ${green}${#added_files}${reset}\n"
  terminal_output+="  [M] Modified:  ${yellow}${#modified_files}${reset}\n"
  terminal_output+="  [D] Deleted:   ${red}${#deleted_files}${reset}\n"
  terminal_output+="  [R] Renamed:   ${cyan}${#renamed_files}${reset}\n"
  if (( ${#other_files} > 0 )); then
    terminal_output+="  [Other] Other: ${magenta}${#other_files}${reset}\n"
  fi
  terminal_output+="\n"

  # List Files changed
  markdown_report+="## Files Changed\n"
  terminal_output+="${bold}Files Changed:${reset}\n"

  local append_file_list_md() {
    local list_name="$1"
    local -a files
    files=( "${@:2}" )
    if [[ ${#files} -gt 0 ]]; then
      markdown_report+="### ${list_name}\n"
      local f
      for f in "${files[@]}"; do
        markdown_report+="- ${f}\n"
      done
      markdown_report+="\n"
    fi
  }

  local append_file_list_term() {
    local prefix_color="$1"
    local prefix_char="$2"
    local -a files
    files=( "${@:3}" )
    local f
    for f in "${files[@]}"; do
      terminal_output+="  ${prefix_color}[${prefix_char}]${reset} ${f}\n"
    done
  }

  append_file_list_md "Added Files" "${added_files[@]}"
  append_file_list_md "Modified Files" "${modified_files[@]}"
  append_file_list_md "Deleted Files" "${deleted_files[@]}"
  append_file_list_md "Renamed Files" "${renamed_files[@]}"
  append_file_list_md "Other Files" "${other_files[@]}"

  append_file_list_term "${green}" "A" "${added_files[@]}"
  append_file_list_term "${yellow}" "M" "${modified_files[@]}"
  append_file_list_term "${red}" "D" "${deleted_files[@]}"
  append_file_list_term "${cyan}" "R" "${renamed_files[@]}"
  append_file_list_term "${magenta}" "O" "${other_files[@]}"

  terminal_output+="\n"

  # Section: Content Changes
  markdown_report+="## Detailed Content Changes\n\n"
  terminal_output+="${bold}================================================================================${reset}\n"
  terminal_output+="${bold}  Detailed Content Changes${reset}\n"
  terminal_output+="${bold}================================================================================${reset}\n\n"

  # Combine changed files for diff review
  local -a all_changed_files
  all_changed_files=( "${added_files[@]}" "${modified_files[@]}" "${other_files[@]}" )

  # For renames, extract the target (ask) filename
  local rf new_part
  for rf in "${renamed_files[@]}"; do
    new_part="${rf##* -> }"
    all_changed_files+=("${new_part}")
  done

  # Include deleted files as well to show their removed diff
  all_changed_files+=( "${deleted_files[@]}" )

  # Unique elements
  all_changed_files=( ${(u)all_changed_files} )

  local f_path f_status diff_content status_color diff_line
  local -a diff_lines_arr
  for f_path in "${all_changed_files[@]}"; do
    [[ -z "${f_path}" ]] && continue
    
    # Determine status for this file
    f_status="Modified"
    if [[ ${added_files[(Ie)${f_path}]} -ne 0 ]]; then
      f_status="Added"
    elif [[ ${deleted_files[(Ie)${f_path}]} -ne 0 ]]; then
      f_status="Deleted"
    elif [[ "${renamed_files[@]}" == *"${f_path}"* ]]; then
      f_status="Renamed"
    elif [[ ${other_files[(Ie)${f_path}]} -ne 0 ]]; then
      f_status="Other"
    fi
    
    # Get git diff for this file
    diff_content=""
    if [[ "${f_status}" == "Deleted" ]]; then
      diff_content="[File deleted]"
    else
      diff_content=$(git diff "${branch_a}" "${branch_b}" -- "${f_path}" 2>/dev/null)
      
      # If diff is empty (e.g. rename without changes, or binary differences)
      if [[ -z "${diff_content}" ]]; then
        if git diff --numstat "${branch_a}" "${branch_b}" -- "${f_path}" | grep -q '^-'; then
          diff_content="[Binary file differences]"
        else
          diff_content="[No content changes or file is metadata-only]"
        fi
      fi
    fi
    
    # Markdown representation
    markdown_report+="### File: \`${f_path}\` (${f_status})\n"
    if [[ "${diff_content}" == "["* ]]; then
      markdown_report+="*${diff_content}*\n\n"
    else
      markdown_report+="\`\`\`diff\n${diff_content}\n\`\`\`\n\n"
    fi
    
    # Terminal representation
    status_color="${yellow}"
    [[ "${f_status}" == "Added" ]] && status_color="${green}"
    [[ "${f_status}" == "Deleted" ]] && status_color="${red}"
    [[ "${f_status}" == "Renamed" ]] && status_color="${cyan}"
    
    terminal_output+="${bold}--------------------------------------------------------------------------------${reset}\n"
    terminal_output+="${bold}File: ${f_path} (${status_color}${f_status}${reset}${bold})${reset}\n"
    terminal_output+="${bold}--------------------------------------------------------------------------------${reset}\n"
    
    if [[ "${diff_content}" == "["* ]]; then
      terminal_output+="  ${magenta}${diff_content}${reset}\n\n"
    else
      diff_lines_arr=( ${(f)diff_content} )
      for diff_line in "${diff_lines_arr[@]}"; do
        if [[ "${diff_line}" =~ "^\\+\\+\\+" ]] || [[ "${diff_line}" =~ "^---" ]]; then
          terminal_output+="${cyan}${diff_line}${reset}\n"
        elif [[ "${diff_line}" =~ "^\\+" ]]; then
          terminal_output+="${green}${diff_line}${reset}\n"
        elif [[ "${diff_line}" =~ "^-" ]]; then
          terminal_output+="${red}${diff_line}${reset}\n"
        elif [[ "${diff_line}" =~ "^@@" ]]; then
          terminal_output+="${blue}${diff_line}${reset}\n"
        else
          terminal_output+="${diff_line}\n"
        fi
      done
      terminal_output+="\n"
    fi
  done

  # 6. Output processing
  if [[ "${silent_mode}" -ne 1 ]]; then
    printf "%b" "${terminal_output}"
  fi

  # 7. Write to output file if specified, or default to an evidence directory
  if [[ -n "${output_file}" ]]; then
    local out_dir="${output_file:h}"
    if [[ ! -d "${out_dir}" ]]; then
      mkdir -p "${out_dir}"
    fi
    printf "%b" "${markdown_report}" > "${output_file}"
    log_info "Markdown report successfully written to: ${output_file:A}"
  else
    local ts
    ts=$(date +%Y%m%d_%H%M%S)
    local default_ev_dir="${PROJECT_ROOT}/evidence/branch_comparison_${ts}"
    mkdir -p "${default_ev_dir}"
    printf "%b" "${markdown_report}" > "${default_ev_dir}/comparison_report.md"
    log_info "Markdown report saved by default to evidence: ${default_ev_dir}/comparison_report.md"
  fi

  restore_and_return 0
}

# /**
#  * @function git_detect_default_branch
#  * @description Detects the repository's default branch (origin/HEAD, develop, main, or master).
#  * @param None
#  * @return {string} Outputs the detected default branch name, or returns 1 if none found.
#  * @example
#  *   local default_branch
#  *   default_branch=$(git_detect_default_branch)
#  */
git_detect_default_branch() {
  local origin_head
  origin_head=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)
  if [[ -n "${origin_head}" ]]; then
    origin_head="${origin_head#origin/}"
    if git_branch_exists "${origin_head}"; then
      echo "${origin_head}"
      return 0
    fi
  fi

  local candidate
  for candidate in develop main master; do
    if git_branch_exists "${candidate}"; then
      echo "${candidate}"
      return 0
    fi
  done

  return 1
}

# /**
#  * @function git_resolve_ref
#  * @description Resolves a branch name to a local ref or origin remote ref.
#  * @param {string} branch - Branch name to resolve.
#  * @return {string} Resolved ref name.
#  */
git_resolve_ref() {
  local branch="$1"
  if [[ -z "${branch}" ]]; then
    return 1
  fi
  if git show-ref --verify --quiet "refs/heads/${branch}"; then
    echo "${branch}"
  elif git show-ref --verify --quiet "refs/remotes/origin/${branch}"; then
    echo "origin/${branch}"
  else
    echo "${branch}"
  fi
}

# /**
#  * @function git_list_branches
#  * @description Lists unique local and origin branch names, optionally filtered by a glob pattern.
#  * @param {string} [pattern] - Optional glob pattern (e.g., "release/*").
#  * @return {string} Newline-separated list of branch names.
#  */
git_list_branches() {
  local pattern="$1"
  local -a branches
  local ref_line clean_ref

  while IFS= read -r ref_line; do
    clean_ref="${ref_line#origin/}"
    [[ -z "${clean_ref}" || "${clean_ref}" == "HEAD" ]] && continue
    if [[ -z "${pattern}" || "${clean_ref}" == ${~pattern} ]]; then
      branches+=("${clean_ref}")
    fi
  done < <(git for-each-ref --format='%(refname:short)' refs/heads refs/remotes/origin 2>/dev/null)

  branches=( ${(u)branches} )
  printf "%s\n" "${branches[@]}"
}

# /**
#  * @function git_get_missed_commits
#  * @description Outputs SHAs of commits in source_branch that have not been backported to target_branch.
#  * @param {string} target_branch - Target/default branch (e.g., develop).
#  * @param {string} source_branch - Source/release branch (e.g., release/1.0.0).
#  * @return {string} Newline-separated list of missed commit SHAs.
#  */
git_get_missed_commits() {
  local target_branch="$1"
  local source_branch="$2"
  if [[ -z "${target_branch}" || -z "${source_branch}" ]]; then
    return 1
  fi

  local target_ref source_ref
  target_ref=$(git_resolve_ref "${target_branch}")
  source_ref=$(git_resolve_ref "${source_branch}")

  local cherry_line sign sha
  while IFS= read -r cherry_line; do
    [[ -z "${cherry_line}" ]] && continue
    sign="${cherry_line%% *}"
    if [[ "${sign}" == "+" ]]; then
      sha="${cherry_line#* }"
      echo "${sha%% *}"
    fi
  done < <(git cherry -v "${target_ref}" "${source_ref}" 2>/dev/null)
}

# /**
#  * @function git_format_commit
#  * @description Formats a commit as "<short_hash> | <date> | <author> | <subject>".
#  * @param {string} [commit_hash=HEAD] - Commit hash.
#  * @return {string} Formatted commit summary line.
#  */
git_format_commit() {
  local commit_hash="${1:-HEAD}"
  git log -1 --format="%h | %ad | %an | %s" --date=short "${commit_hash}" 2>/dev/null
}

# /**
#  * @function git_pick_branch
#  * @description Prompts the user to select a branch (optionally filtered by pattern, falling back to all branches).
#  * @param {string} prompt - Prompt message.
#  * @param {string} [pattern] - Optional glob pattern (e.g., "release/*").
#  * @return {string} Selected branch name.
#  */
git_pick_branch() {
  local prompt="$1"
  local pattern="$2"
  local -a candidates
  candidates=( ${(f)"$(git_list_branches "${pattern}")"} )
  if [[ ${#candidates} -eq 0 && -n "${pattern}" ]]; then
    candidates=( ${(f)"$(git_list_branches)"} )
  fi

  if [[ ${#candidates} -gt 0 ]]; then
    select_option "${prompt}" "${candidates[@]}"
  else
    read_input "${prompt}"
  fi
}

# /**
#  * @function git_report_missed_commits
#  * @description Prints (and optionally writes to Markdown) commits in release_branch missing from target_branch.
#  * @param {string} target_branch - Target/default branch.
#  * @param {string} release_branch - Release branch to check.
#  * @param {string} [output_file] - Optional Markdown report path.
#  * @param {number} [silent_mode=0] - 1 to suppress stdout.
#  * @return {number} 0 on success, 1 on invalid branch.
#  */
git_report_missed_commits() {
  local target_branch="$1"
  local release_branch="$2"
  local output_file="$3"
  local silent_mode="${4:-0}"

  if ! git_branch_exists "${target_branch}"; then
    log_error "Target branch '${target_branch}' does not exist."
    return 1
  fi
  if ! git_branch_exists "${release_branch}"; then
    log_error "Release branch '${release_branch}' does not exist."
    return 1
  fi

  local -a missed_shas
  missed_shas=( ${(f)"$(git_get_missed_commits "${target_branch}" "${release_branch}")"} )

  local bold="\033[1m" red="\033[31m" green="\033[32m" yellow="\033[33m" cyan="\033[36m" reset="\033[0m"
  local term_out="" md_out=""
  md_out+="# Release Backport Check\n\n"
  md_out+="- **Release Branch:** \`${release_branch}\`\n"
  md_out+="- **Target Branch:** \`${target_branch}\`\n"
  md_out+="- **Missing (Not Backported):** ${#missed_shas}\n\n"

  term_out+="${bold}================================================================================${reset}\n"
  term_out+="${bold}  Release Backport Check: ${cyan}${release_branch}${reset}${bold} -> ${cyan}${target_branch}${reset}\n"
  term_out+="${bold}================================================================================${reset}\n"
  term_out+="  Missing commits: ${#missed_shas}\n\n"

  if [[ ${#missed_shas} -eq 0 ]]; then
    term_out+="${green}All commits from '${release_branch}' are present in '${target_branch}'.${reset}\n"
    md_out+="All commits from \`${release_branch}\` are present in \`${target_branch}\`.\n"
  else
    term_out+="${red}${bold}Commits in '${release_branch}' NOT backported to '${target_branch}':${reset}\n"
    md_out+="## Missing Commits\n\n"
    local sha info
    for sha in "${missed_shas[@]}"; do
      [[ -z "${sha}" ]] && continue
      info=$(git_format_commit "${sha}")
      term_out+="  ${yellow}[MISSING]${reset} ${info}\n"
      md_out+="- \`${info}\`\n"
    done
    md_out+="\n"
  fi

  [[ "${silent_mode}" -ne 1 ]] && printf "%b" "${term_out}"

  if [[ -n "${output_file}" ]]; then
    mkdir -p "${output_file:h}"
    printf "%b" "${md_out}" > "${output_file}"
    log_info "Markdown report written to: ${output_file:A}"
  fi
}

# /**
#  * @function git_compare_three_branches
#  * @description Compares two release branches (release/x and release/x-1) against a default branch
#  *              to find missing commits (backport gaps) and content differences across all 3 links:
#  *              release/x -> default, release/x-1 -> default, and release/x-1 -> release/x.
#  * @param {string} [--help|-h] - Show help message.
#  * @param {string} [--output|-o <file>] - Write the Markdown report to a specific file.
#  * @param {string} [--silent|-s] - Do not output details to stdout.
#  * @param {string} <release_x> - Current/newer release branch (e.g., release/2.2.0).
#  * @param {string} <release_prev> - Previous release branch (e.g., release/2.1.0).
#  * @param {string} [default_branch] - Default/develop branch (auto-detected via git_detect_default_branch if omitted).
#  * @return {number} 0 on success, or 1 on failure.
#  * @example
#  *   git_compare_three_branches --output "./three_branch_report.md" release/2.2.0 release/2.1.0 develop
#  */
git_compare_three_branches() {
  if ! typeset -f is_inside_git_repo >/dev/null; then
    if [[ -f "${RZSH_DIR:-${PROJECT_ROOT:-.}}/functions/03-navigation.sh" ]]; then
      source "${RZSH_DIR:-${PROJECT_ROOT:-.}}/functions/03-navigation.sh"
    fi
  fi

  local show_help_3way
  show_help_3way() {
    cat << EOF
Usage: git_compare_three_branches [options] <release_x> <release_prev> [<default_branch>]

Options:
  -h, --help           Show this help message.
  -o, --output <file>  Write the Markdown report to a specific file.
  -s, --silent         Do not output details to stdout (still writes to file if specified).

Arguments:
  <release_x>          Current/newer release branch (e.g., release/2.2.0).
  <release_prev>       Previous release branch (e.g., release/2.1.0).
  [<default_branch>]   Default/develop branch (auto-detected if omitted).

Comparisons performed:
  1. <release_x>    -> <default_branch>  (commits & content in release/x missing from default)
  2. <release_prev> -> <default_branch>  (commits & content in release/x-1 missing from default)
  3. <release_prev> -> <release_x>       (commits & content in release/x-1 missing from release/x)
EOF
  }

  local output_file=""
  local silent_mode=0
  local -a pos_args

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        show_help_3way
        return 0
        ;;
      -o|--output)
        if [[ -z "${2:-}" ]]; then
          log_error "Option $1 requires a file path."
          return 1
        fi
        output_file="$2"
        shift 2
        ;;
      -s|--silent)
        silent_mode=1
        shift
        ;;
      -*)
        log_error "Unknown option: $1. Use -h or --help for usage."
        return 1
        ;;
      *)
        pos_args+=("$1")
        shift
        ;;
    esac
  done

  if [[ ${#pos_args} -lt 2 ]]; then
    log_error "Expected at least 2 branches: <release_x> <release_prev> [<default_branch>]. Use -h or --help for usage."
    return 1
  elif [[ ${#pos_args} -gt 3 ]]; then
    log_error "Too many arguments. Expected 2 or 3 branch names."
    return 1
  fi

  if ! is_inside_git_repo; then
    log_error "Not inside a Git repository."
    return 1
  fi

  local git_root orig_pwd
  git_root=$(git_get_root)
  orig_pwd="${PWD}"
  cd "${git_root}" || {
    log_error "Failed to navigate to Git repository root: ${git_root}"
    return 1
  }

  local restore_dir_3way
  restore_dir_3way() {
    local ret_code="$1"
    cd "${orig_pwd}" 2>/dev/null
    return "${ret_code}"
  }

  local release_x="${pos_args[1]}"
  local release_prev="${pos_args[2]}"
  local default_branch="${pos_args[3]:-}"

  if [[ -z "${default_branch}" ]]; then
    default_branch=$(git_detect_default_branch)
    if [[ -z "${default_branch}" ]]; then
      log_error "Could not detect default branch. Please specify <default_branch> explicitly."
      restore_dir_3way 1
      return 1
    fi
  fi

  local b
  for b in "${release_x}" "${release_prev}" "${default_branch}"; do
    if ! git_branch_exists "${b}"; then
      log_error "Branch '${b}' does not exist."
      restore_dir_3way 1
      return 1
    fi
  done

  log_info "Comparing 3 branches: '${release_x}', '${release_prev}', and '${default_branch}'..."

  local bold="\e[1m" red="\e[31m" green="\e[32m" yellow="\e[33m" cyan="\e[36m" reset="\e[0m"
  local term_body="" md_body="" summary_rows=""

  local -a link_sources link_targets link_titles
  link_sources=( "${release_x}" "${release_prev}" "${release_prev}" )
  link_targets=( "${default_branch}" "${default_branch}" "${release_x}" )
  link_titles=(
    "${release_x} -> ${default_branch}"
    "${release_prev} -> ${default_branch}"
    "${release_prev} -> ${release_x}"
  )

  local i src tgt title
  local -a missed_shas
  local sha info commit_patch tmp_pair_report pair_files_changed pair_sections

  for (( i = 1; i <= 3; i++ )); do
    src="${link_sources[i]}"
    tgt="${link_targets[i]}"
    title="${link_titles[i]}"

    missed_shas=( ${(f)"$(git_get_missed_commits "${tgt}" "${src}")"} )
    missed_shas=( ${missed_shas:#} )

    # Reuse git_compare_branches for branch-level content comparison
    tmp_pair_report=$(mktemp)
    pair_files_changed="0"
    pair_sections=""
    if git_compare_branches --silent --output "${tmp_pair_report}" "${tgt}" "${src}" >/dev/null 2>&1 && [[ -s "${tmp_pair_report}" ]]; then
      pair_files_changed=$(grep -m1 'Total Files Changed:' "${tmp_pair_report}" | sed -E 's/.*Total Files Changed:\*\* ([0-9]+).*/\1/')
      [[ -z "${pair_files_changed}" ]] && pair_files_changed="0"
      pair_sections=$(sed -n '/^## Summary of Changes/,$p' "${tmp_pair_report}" | sed -e 's/^### /##### /' -e 's/^## /#### /')
    else
      local tgt_ref src_ref fallback_stat
      tgt_ref=$(git_resolve_ref "${tgt}")
      src_ref=$(git_resolve_ref "${src}")
      fallback_stat=$(git diff --stat "${tgt_ref}" "${src_ref}" 2>/dev/null)
      if [[ -n "${fallback_stat}" ]]; then
        pair_files_changed=$(git diff --name-only "${tgt_ref}" "${src_ref}" 2>/dev/null | wc -l | tr -d ' ')
        pair_sections="\`\`\`\n${fallback_stat}\n\`\`\`\n"
      fi
    fi
    rm -f "${tmp_pair_report}"

    summary_rows+="| \`${title}\` | ${#missed_shas} | ${pair_files_changed} |\n"

    # Terminal section
    term_body+="${bold}--------------------------------------------------------------------------------${reset}\n"
    term_body+="${bold}  Link ${i}: ${cyan}${src}${reset}${bold} -> ${cyan}${tgt}${reset}\n"
    term_body+="${bold}--------------------------------------------------------------------------------${reset}\n"
    term_body+="  Missing commits: ${#missed_shas} | Branch file diffs: ${pair_files_changed}\n\n"

    # Markdown section
    md_body+="## ${i}. ${title}\n\n"
    md_body+="- **Source Branch:** \`${src}\`\n"
    md_body+="- **Target Branch:** \`${tgt}\`\n"
    md_body+="- **Missing Commits:** ${#missed_shas}\n"
    md_body+="- **Branch Files Changed:** ${pair_files_changed}\n\n"
    md_body+="### Missing Commits\n\n"

    if [[ ${#missed_shas} -eq 0 ]]; then
      term_body+="  ${green}No missing commits from '${src}' in '${tgt}'.${reset}\n\n"
      md_body+="All commits from \`${src}\` are present in \`${tgt}\`.\n\n"
    else
      for sha in "${missed_shas[@]}"; do
        [[ -z "${sha}" ]] && continue
        info=$(git_format_commit "${sha}")
        commit_patch=$(git show --no-color --format="" "${sha}" 2>/dev/null)
        term_body+="  ${yellow}[MISSING]${reset} ${info}\n"
        md_body+="- \`${info}\`\n"
        if [[ -n "${commit_patch}" ]]; then
          md_body+="\n\`\`\`diff\n${commit_patch}\n\`\`\`\n\n"
        fi
      done
      term_body+="\n"
    fi

    md_body+="### Branch Content Comparison (\`${tgt}\` vs \`${src}\`)\n\n"
    if [[ -n "${pair_sections}" ]]; then
      md_body+="${pair_sections}\n\n"
    else
      md_body+="No content differences found between \`${tgt}\` and \`${src}\`.\n\n"
    fi
  done

  local term_header="" md_header=""
  term_header+="${bold}================================================================================${reset}\n"
  term_header+="${bold}  3-Branch Release Comparison Report${reset}\n"
  term_header+="${bold}================================================================================${reset}\n"
  term_header+="* Release (x):    ${cyan}${release_x}${reset}\n"
  term_header+="* Release (x-1):  ${cyan}${release_prev}${reset}\n"
  term_header+="* Default Branch: ${cyan}${default_branch}${reset}\n\n"

  md_header+="# 3-Branch Release Comparison Report\n\n"
  md_header+="* **Generated at:** $(date)\n"
  md_header+="* **Release (x):** \`${release_x}\`\n"
  md_header+="* **Release (x-1):** \`${release_prev}\`\n"
  md_header+="* **Default Branch:** \`${default_branch}\`\n\n"
  md_header+="## Missing Links Summary\n\n"
  md_header+="| Comparison Link | Missing Commits | Branch Files Changed |\n"
  md_header+="|---|---|---|\n"
  md_header+="${summary_rows}\n"

  if [[ "${silent_mode}" -ne 1 ]]; then
    printf "%b" "${term_header}${term_body}"
  fi

  local full_md="${md_header}${md_body}"
  if [[ -n "${output_file}" ]]; then
    local out_dir="${output_file:h}"
    [[ ! -d "${out_dir}" ]] && mkdir -p "${out_dir}"
    printf "%b" "${full_md}" > "${output_file}"
    log_info "Markdown report successfully written to: ${output_file:A}"
  else
    local ts default_ev_dir
    ts=$(date +%Y%m%d_%H%M%S)
    default_ev_dir="${PROJECT_ROOT}/evidence/three_branch_comparison_${ts}"
    mkdir -p "${default_ev_dir}"
    printf "%b" "${full_md}" > "${default_ev_dir}/three_branch_report.md"
    log_info "Markdown report saved by default to evidence: ${default_ev_dir}/three_branch_report.md"
  fi

  restore_dir_3way 0
}

# /**
#  * @function git_compare_commits
#  * @description Compares two Git commits, tags, or refs (defaulting the second ref to HEAD) and generates a Markdown report with commit metadata, changed files, diff stats, and optional patch diff.
#  * @param {string} [options] - -h/--help, -o/--output <file>, -s/--silent, --diff.
#  * @param {string} ref1 - Base commit hash, tag, or branch ref.
#  * @param {string} [ref2=HEAD] - Target commit hash, tag, or branch ref.
#  * @return {number} 0 on success, 1 on error or invalid ref.
#  * @example
#  *   git_compare_commits --diff -o commit_diff.md HEAD~2 HEAD
#  */
git_compare_commits() {
  if ! typeset -f is_inside_git_repo >/dev/null; then
    if [[ -f "${RZSH_DIR:-${PROJECT_ROOT:-.}}/functions/03-navigation.sh" ]]; then
      source "${RZSH_DIR:-${PROJECT_ROOT:-.}}/functions/03-navigation.sh"
    fi
  fi

  local show_help_gcc
  show_help_gcc() {
    cat << 'EOF'
Usage: git_compare_commits [options] <ref1> [<ref2>]

Options:
  -h, --help            Show this help message.
  -o, --output <file>   Write the Markdown comparison report to <file>.
  -s, --silent          Suppress stdout output (still writes to -o if specified).
      --diff            Include full unified patch diff in the report.

Arguments:
  <ref1>                Base commit SHA, tag, or branch ref.
  [<ref2>]              Target commit SHA, tag, or branch ref (defaults to HEAD).
EOF
  }

  local output_file=""
  local silent_mode=0
  local include_diff=0
  local -a pos_args

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        show_help_gcc
        return 0
        ;;
      -o|--output)
        if [[ -z "${2:-}" ]]; then
          log_error "Option $1 requires a file path."
          return 1
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
      -*)
        log_error "Unknown option: $1. Use -h or --help for usage."
        return 1
        ;;
      *)
        pos_args+=("$1")
        shift
        ;;
    esac
  done

  if (( ${#pos_args} < 1 || ${#pos_args} > 2 )); then
    log_error "git_compare_commits requires 1 or 2 refs: <ref1> [<ref2>]. Use -h or --help."
    return 1
  fi

  if ! is_inside_git_repo; then
    log_error "Not inside a Git repository."
    return 1
  fi

  local ref1="${pos_args[1]}"
  local ref2="${pos_args[2]:-HEAD}"

  local sha1 sha2
  sha1=$(git rev-parse --verify "${ref1}^{commit}" 2>/dev/null) || {
    log_error "Invalid Git ref: ${ref1}"
    return 1
  }
  sha2=$(git rev-parse --verify "${ref2}^{commit}" 2>/dev/null) || {
    log_error "Invalid Git ref: ${ref2}"
    return 1
  }

  local meta1 meta2
  meta1=$(git show -s --format='%h | %an | %ad | %s' --date=short "${sha1}" 2>/dev/null)
  meta2=$(git show -s --format='%h | %an | %ad | %s' --date=short "${sha2}" 2>/dev/null)

  local commits_ahead commits_behind name_status diff_stat
  commits_ahead=$(git log --oneline "${sha1}..${sha2}" 2>/dev/null)
  commits_behind=$(git log --oneline "${sha2}..${sha1}" 2>/dev/null)
  name_status=$(git diff --name-status "${sha1}" "${sha2}" 2>/dev/null)
  diff_stat=$(git diff --stat "${sha1}" "${sha2}" 2>/dev/null)

  local status_label="DIFFERENT"
  if [[ "${sha1}" == "${sha2}" || -z "${name_status}" ]]; then
    status_label="IDENTICAL"
  fi

  local md_report
  md_report=$(cat <<EOF
# Git Commit Comparison Report

- **Base Ref (\`${ref1}\`):** \`${meta1}\`
- **Target Ref (\`${ref2}\`):** \`${meta2}\`
- **Tree Status:** **${status_label}**

## Commits in \`${ref2}\` not in \`${ref1}\`
\`\`\`text
${commits_ahead:-None}
\`\`\`

## Commits in \`${ref1}\` not in \`${ref2}\`
\`\`\`text
${commits_behind:-None}
\`\`\`

## Changed Files (\`--name-status\`)
\`\`\`text
${name_status:-No file differences}
\`\`\`

## Diff Stat
\`\`\`text
${diff_stat:-No diff stat}
\`\`\`
EOF
)

  if (( include_diff == 1 )); then
    local patch_diff
    patch_diff=$(git diff "${sha1}" "${sha2}" 2>/dev/null)
    md_report+=$'\n\n## Unified Patch Diff\n\n```diff\n'"${patch_diff:-No differences}"$'\n```'
  fi

  if [[ -n "${output_file}" ]]; then
    mkdir -p "${output_file:h}" 2>/dev/null || true
    printf '%s\n' "${md_report}" > "${output_file}"
  fi

  if (( silent_mode == 0 )); then
    printf '%s\n' "${md_report}"
  fi

  return 0
}

# ==============================================================================
# Comprehensive Git Comparison Suite (Branch, Commit, Tag, Release, Content, Worktree)
# ==============================================================================

# /**
#  * @function git_tag_exists
#  * @description Checks if a Git tag exists in the repository.
#  * @param {string} tag - The tag name to verify.
#  * @return {number} 0 if exists, 1 otherwise.
#  */
git_tag_exists() {
  local tag="$1"
  [[ -z "${tag}" ]] && return 1
  git rev-parse --verify --quiet "refs/tags/${tag}" >/dev/null 2>&1
}

# /**
#  * @function git_list_tags
#  * @description Lists Git tags sorted by creator date (newest first), optionally filtered by a glob pattern.
#  * @param {string} [pattern] - Optional glob pattern (e.g., "v1.*").
#  * @return {string} Newline-separated list of tag names.
#  */
git_list_tags() {
  local pattern="$1"
  if [[ -n "${pattern}" ]]; then
    git tag -l "${pattern}" --sort=-creatordate 2>/dev/null
  else
    git tag -l --sort=-creatordate 2>/dev/null
  fi
}

# Internal helper: check if a path matches any entry in GIT_IGNORE_FOLDERS
_git_is_ignored_path() {
  local file_path="$1"
  [[ -z "${file_path}" || -z "${GIT_IGNORE_FOLDERS:-}" ]] && return 1

  local -a ignore_folders
  ignore_folders=( ${(s:,:)GIT_IGNORE_FOLDERS} )
  local folder
  for folder in "${ignore_folders[@]}"; do
    [[ -z "${folder}" ]] && continue
    if [[ "${file_path}" == "${folder}" ]] || [[ "${file_path}" == "${folder}"/* ]] || [[ "${file_path}" == */"${folder}"/* ]]; then
      return 0
    fi
  done
  return 1
}

# Internal helper: print colorized diff lines to terminal_output variable
_git_colorize_diff_lines() {
  local diff_text="$1"
  local green="\e[32m" red="\e[31m" cyan="\e[36m" blue="\e[34m" reset="\e[0m"
  local -a lines
  lines=( ${(f)diff_text} )
  local line out=""
  for line in "${lines[@]}"; do
    if [[ "${line}" =~ "^\\+\\+\\+" ]] || [[ "${line}" =~ "^---" ]]; then
      out+="${cyan}${line}${reset}\n"
    elif [[ "${line}" =~ "^\\+" ]]; then
      out+="${green}${line}${reset}\n"
    elif [[ "${line}" =~ "^-" ]]; then
      out+="${red}${line}${reset}\n"
    elif [[ "${line}" =~ "^@@" ]]; then
      out+="${blue}${line}${reset}\n"
    else
      out+="${line}\n"
    fi
  done
  printf '%s' "${out}"
}

# Internal helper: unified comparison report generator for refs, tags, commits, releases, content, and worktree
_git_generate_compare_report() {
  if ! typeset -f is_inside_git_repo >/dev/null; then
    if [[ -f "${RZSH_DIR:-${PROJECT_ROOT:-.}}/functions/03-navigation.sh" ]]; then
      source "${RZSH_DIR:-${PROJECT_ROOT:-.}}/functions/03-navigation.sh"
    fi
  fi

  local cmp_type="Ref"
  local source_label="" target_label=""
  local source_ref="" target_ref=""
  local output_file=""
  local silent_mode=0
  local include_diff=1
  local include_commits=1
  local worktree_mode="" # "", "worktree", or "staged"
  local -a filter_paths

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --type) cmp_type="$2"; shift 2 ;;
      --source-label) source_label="$2"; shift 2 ;;
      --target-label) target_label="$2"; shift 2 ;;
      --source-ref) source_ref="$2"; shift 2 ;;
      --target-ref) target_ref="$2"; shift 2 ;;
      --output) output_file="$2"; shift 2 ;;
      --silent) silent_mode="$2"; shift 2 ;;
      --include-diff) include_diff="$2"; shift 2 ;;
      --include-commits) include_commits="$2"; shift 2 ;;
      --worktree-mode) worktree_mode="$2"; shift 2 ;;
      --path) filter_paths+=("$2"); shift 2 ;;
      *) shift ;;
    esac
  done

  if ! is_inside_git_repo; then
    log_error "Not inside a Git repository."
    return 1
  fi

  local git_root orig_pwd
  git_root=$(git_get_root)
  orig_pwd="${PWD}"
  cd "${git_root}" || {
    log_error "Failed to navigate to Git repository root: ${git_root}"
    return 1
  }

  local -a pathspec_args
  if (( ${#filter_paths} > 0 )); then
    pathspec_args=( "--" "${filter_paths[@]}" )
  fi

  # Collect diff --name-status and --stat
  local -a diff_lines
  local diff_stat=""
  if [[ "${worktree_mode}" == "staged" ]]; then
    diff_lines=( ${(f)"$(git diff --cached --name-status "${source_ref}" "${pathspec_args[@]}" 2>/dev/null)"} )
    diff_stat=$(git diff --cached --stat "${source_ref}" "${pathspec_args[@]}" 2>/dev/null)
  elif [[ "${worktree_mode}" == "worktree" ]]; then
    diff_lines=( ${(f)"$(git diff --name-status "${source_ref}" "${pathspec_args[@]}" 2>/dev/null)"} )
    diff_stat=$(git diff --stat "${source_ref}" "${pathspec_args[@]}" 2>/dev/null)
  else
    diff_lines=( ${(f)"$(git diff --name-status "${source_ref}" "${target_ref}" "${pathspec_args[@]}" 2>/dev/null)"} )
    diff_stat=$(git diff --stat "${source_ref}" "${target_ref}" "${pathspec_args[@]}" 2>/dev/null)
  fi

  local -a added_files modified_files deleted_files renamed_files other_files
  local line diff_status file1 file2
  for line in "${diff_lines[@]}"; do
    [[ -z "${line}" ]] && continue
    IFS=$'\t' read -r diff_status file1 file2 <<< "${line}"

    if _git_is_ignored_path "${file1}" || { [[ -n "${file2}" ]] && _git_is_ignored_path "${file2}"; }; then
      continue
    fi

    if [[ "${diff_status}" == A ]]; then
      added_files+=("${file1}")
    elif [[ "${diff_status}" == M ]]; then
      modified_files+=("${file1}")
    elif [[ "${diff_status}" == D ]]; then
      deleted_files+=("${file1}")
    elif [[ "${diff_status}" =~ ^R ]]; then
      renamed_files+=("${file1} -> ${file2}")
    else
      other_files+=("${file1}")
    fi
  done

  local total_changes=$(( ${#added_files} + ${#modified_files} + ${#deleted_files} + ${#renamed_files} + ${#other_files} ))

  # Commit metadata & scope creep summary
  local source_meta="" target_meta="" commits_ahead="" commits_behind="" authors_list=""
  if [[ -z "${worktree_mode}" ]]; then
    source_meta=$(git show -s --format='%h | %an | %ad | %s' --date=short "${source_ref}" 2>/dev/null)
    target_meta=$(git show -s --format='%h | %an | %ad | %s' --date=short "${target_ref}" 2>/dev/null)
    if (( include_commits == 1 )); then
      commits_ahead=$(git log --format="%h | %ad | %an | %s" --date=short "${source_ref}..${target_ref}" "${pathspec_args[@]}" 2>/dev/null)
      commits_behind=$(git log --format="%h | %ad | %an | %s" --date=short "${target_ref}..${source_ref}" "${pathspec_args[@]}" 2>/dev/null)
      authors_list=$(git log --format="%an" "${source_ref}..${target_ref}" "${pathspec_args[@]}" 2>/dev/null | sort -u)
    fi
  else
    source_meta=$(git show -s --format='%h | %an | %ad | %s' --date=short "${source_ref}" 2>/dev/null)
    target_meta="${target_label}"
  fi

  local status_badge="🟢 IDENTICAL"
  local status_term="\e[32mIDENTICAL\e[0m"
  if (( total_changes > 0 )) || [[ -n "${commits_ahead}" ]] || [[ -n "${commits_behind}" ]]; then
    status_badge="🟡 CHANGED"
    status_term="\e[33mCHANGED\e[0m"
  fi

  # Terminal ANSI colors
  local reset="\e[0m" bold="\e[1m" red="\e[31m" green="\e[32m" yellow="\e[33m" blue="\e[34m" magenta="\e[35m" cyan="\e[36m"
  local term_out="" md_out=""

  # Build Markdown Header
  md_out+="# Git ${cmp_type} Comparison Report\n\n"
  md_out+="* **Generated at:** $(date)\n"
  md_out+="* **Comparison Type:** \`${cmp_type}\`\n"
  md_out+="* **Source (Base):** \`${source_label}\` (\`${source_meta:-N/A}\`)\n"
  md_out+="* **Target:** \`${target_label}\` (\`${target_meta:-N/A}\`)\n"
  if (( ${#filter_paths} > 0 )); then
    md_out+="* **Path Filter:** \`${filter_paths[*]}\`\n"
  fi
  md_out+="* **Status:** ${status_badge}\n"
  md_out+="* **Total Files Changed:** ${total_changes}\n\n"

  # Build Terminal Header
  term_out+="${bold}================================================================================${reset}\n"
  term_out+="${bold}  Git ${cmp_type} Comparison Report${reset}\n"
  term_out+="${bold}================================================================================${reset}\n"
  term_out+="* Source (Base): ${cyan}${source_label}${reset}\n"
  term_out+="* Target:        ${cyan}${target_label}${reset}\n"
  if (( ${#filter_paths} > 0 )); then
    term_out+="* Path Filter:   ${magenta}${filter_paths[*]}${reset}\n"
  fi
  term_out+="* Status:        ${status_term}\n"
  term_out+="* Total Changes: ${bold}${total_changes}${reset}\n\n"

  # Commit / Scope Creep Section
  if [[ -z "${worktree_mode}" && ${include_commits} -eq 1 ]]; then
    local ahead_count=0 behind_count=0
    [[ -n "${commits_ahead}" ]] && ahead_count=$(printf '%s\n' "${commits_ahead}" | wc -l | tr -d ' ')
    [[ -n "${commits_behind}" ]] && behind_count=$(printf '%s\n' "${commits_behind}" | wc -l | tr -d ' ')

    md_out+="## Commit & Scope Summary\n\n"
    md_out+="| Metric | Count |\n|---|---|\n"
    md_out+="| 🟢 Commits in Target (\`${target_label}\`) not in Source (\`${source_label}\`) | ${ahead_count} |\n"
    md_out+="| 🔴 Commits in Source (\`${source_label}\`) not in Target (\`${target_label}\`) | ${behind_count} |\n\n"

    if [[ -n "${authors_list}" ]]; then
      md_out+="**Contributors in Target:** $(printf '%s' "${authors_list}" | tr '\n' ', ' | sed 's/, $//')\n\n"
    fi

    md_out+="### Commits in \`${target_label}\` not in \`${source_label}\`\n"
    if [[ -n "${commits_ahead}" ]]; then
      md_out+="\`\`\`text\n${commits_ahead}\n\`\`\`\n\n"
    else
      md_out+="*None*\n\n"
    fi

    md_out+="### Commits in \`${source_label}\` not in \`${target_label}\`\n"
    if [[ -n "${commits_behind}" ]]; then
      md_out+="\`\`\`text\n${commits_behind}\n\`\`\`\n\n"
    else
      md_out+="*None*\n\n"
    fi

    term_out+="${bold}Commit & Scope Summary:${reset}\n"
    term_out+="  ${green}Ahead  (in ${target_label} only):${reset} ${ahead_count}\n"
    term_out+="  ${red}Behind (in ${source_label} only):${reset} ${behind_count}\n\n"
  fi

  # Summary of File Changes
  md_out+="## Summary of Changes\n\n"
  md_out+="| Change Type | Count |\n|---|---|\n"
  md_out+="| 🟢 [A] Added | ${#added_files} |\n"
  md_out+="| 🟡 [M] Modified | ${#modified_files} |\n"
  md_out+="| 🔴 [D] Deleted | ${#deleted_files} |\n"
  md_out+="| 🔵 [R] Renamed | ${#renamed_files} |\n"
  md_out+="| 🟣 [O] Other | ${#other_files} |\n\n"

  term_out+="${bold}Summary of Changes:${reset}\n"
  term_out+="  [A] Added:     ${green}${#added_files}${reset}\n"
  term_out+="  [M] Modified:  ${yellow}${#modified_files}${reset}\n"
  term_out+="  [D] Deleted:   ${red}${#deleted_files}${reset}\n"
  term_out+="  [R] Renamed:   ${cyan}${#renamed_files}${reset}\n"
  if (( ${#other_files} > 0 )); then
    term_out+="  [O] Other:     ${magenta}${#other_files}${reset}\n"
  fi
  term_out+="\n"

  # Diff Stat
  if [[ -n "${diff_stat}" ]]; then
    md_out+="## Diff Stat\n\n\`\`\`text\n${diff_stat}\n\`\`\`\n\n"
  fi

  # Files Changed List
  md_out+="## Files Changed\n\n"
  term_out+="${bold}Files Changed:${reset}\n"

  local _append_md_group() {
    local title="$1" badge="$2"
    shift 2
    local -a items
    items=( "$@" )
    if (( ${#items} > 0 )); then
      md_out+="### ${badge} ${title}\n"
      local item
      for item in "${items[@]}"; do
        md_out+="- \`${item}\`\n"
      done
      md_out+="\n"
    fi
  }

  local _append_term_group() {
    local color="$1" code="$2"
    shift 2
    local -a items
    items=( "$@" )
    local item
    for item in "${items[@]}"; do
      term_out+="  ${color}[${code}]${reset} ${item}\n"
    done
  }

  _append_md_group "Added Files" "🟢" "${added_files[@]}"
  _append_md_group "Modified Files" "🟡" "${modified_files[@]}"
  _append_md_group "Deleted Files" "🔴" "${deleted_files[@]}"
  _append_md_group "Renamed Files" "🔵" "${renamed_files[@]}"
  _append_md_group "Other Files" "🟣" "${other_files[@]}"

  _append_term_group "${green}" "A" "${added_files[@]}"
  _append_term_group "${yellow}" "M" "${modified_files[@]}"
  _append_term_group "${red}" "D" "${deleted_files[@]}"
  _append_term_group "${cyan}" "R" "${renamed_files[@]}"
  _append_term_group "${magenta}" "O" "${other_files[@]}"
  term_out+="\n"

  # Detailed Content Changes (Color-coded via ```diff in Markdown and ANSI in terminal)
  if (( include_diff == 1 && total_changes > 0 )); then
    md_out+="## Detailed Content Changes\n\n"
    term_out+="${bold}================================================================================${reset}\n"
    term_out+="${bold}  Detailed Content Changes${reset}\n"
    term_out+="${bold}================================================================================${reset}\n\n"

    local -a all_files
    all_files=( "${added_files[@]}" "${modified_files[@]}" "${other_files[@]}" )
    local rf
    for rf in "${renamed_files[@]}"; do
      all_files+=("${rf##* -> }")
    done
    all_files+=( "${deleted_files[@]}" )
    all_files=( ${(u)all_files} )

    local f_path f_status f_badge f_color diff_content
    for f_path in "${all_files[@]}"; do
      [[ -z "${f_path}" ]] && continue
      f_status="Modified"; f_badge="🟡"; f_color="${yellow}"
      if [[ ${added_files[(Ie)${f_path}]} -ne 0 ]]; then
        f_status="Added"; f_badge="🟢"; f_color="${green}"
      elif [[ ${deleted_files[(Ie)${f_path}]} -ne 0 ]]; then
        f_status="Deleted"; f_badge="🔴"; f_color="${red}"
      elif [[ "${renamed_files[*]}" == *"${f_path}"* ]]; then
        f_status="Renamed"; f_badge="🔵"; f_color="${cyan}"
      elif [[ ${other_files[(Ie)${f_path}]} -ne 0 ]]; then
        f_status="Other"; f_badge="🟣"; f_color="${magenta}"
      fi

      if [[ "${worktree_mode}" == "staged" ]]; then
        diff_content=$(git diff --cached "${source_ref}" -- "${f_path}" 2>/dev/null)
      elif [[ "${worktree_mode}" == "worktree" ]]; then
        diff_content=$(git diff "${source_ref}" -- "${f_path}" 2>/dev/null)
      else
        diff_content=$(git diff "${source_ref}" "${target_ref}" -- "${f_path}" 2>/dev/null)
      fi

      if [[ -z "${diff_content}" ]]; then
        if [[ "${f_status}" == "Deleted" ]]; then
          diff_content="[File deleted]"
        else
          diff_content="[Binary or metadata-only changes]"
        fi
      fi

      md_out+="### ${f_badge} File: \`${f_path}\` (${f_status})\n"
      if [[ "${diff_content}" == "["* ]]; then
        md_out+="*${diff_content}*\n\n"
      else
        md_out+="\`\`\`diff\n${diff_content}\n\`\`\`\n\n"
      fi

      term_out+="${bold}--------------------------------------------------------------------------------${reset}\n"
      term_out+="${bold}File: ${f_path} (${f_color}${f_status}${reset}${bold})${reset}\n"
      term_out+="${bold}--------------------------------------------------------------------------------${reset}\n"
      if [[ "${diff_content}" == "["* ]]; then
        term_out+="  ${magenta}${diff_content}${reset}\n\n"
      else
        term_out+="$(_git_colorize_diff_lines "${diff_content}")\n"
      fi
    done
  fi

  if (( silent_mode == 0 )); then
    printf "%b" "${term_out}"
  fi

  local type_slug="${${cmp_type:l}// /_}"
  if [[ -n "${output_file}" ]]; then
    local out_dir="${output_file:h}"
    [[ ! -d "${out_dir}" ]] && mkdir -p "${out_dir}"
    printf "%b" "${md_out}" > "${output_file}"
    log_info "Markdown report successfully written to: ${output_file:A}"
  else
    local ts default_ev_dir
    ts=$(date +%Y%m%d_%H%M%S)
    default_ev_dir="${PROJECT_ROOT}/evidence/${type_slug}_comparison_${ts}"
    mkdir -p "${default_ev_dir}"
    printf "%b" "${md_out}" > "${default_ev_dir}/comparison_report.md"
    log_info "Markdown report saved by default to evidence: ${default_ev_dir}/comparison_report.md"
  fi

  cd "${orig_pwd}" 2>/dev/null
  return 0
}

# /**
#  * @function git_compare_tags
#  * @description Compares two Git tags (or auto-detects the latest two tags) and generates a colorized terminal summary and Markdown report.
#  * @param {string} [options] - -h/--help, -o/--output <file>, -s/--silent, --no-diff.
#  * @param {string} [tag_a] - Source/base tag (defaults to second-latest tag if 0 args).
#  * @param {string} [tag_b] - Target tag (defaults to HEAD if 1 arg, or latest tag if 0 args).
#  * @return {number} 0 on success, 1 on failure.
#  * @example
#  *   git_compare_tags -o tag_report.md v1.0.0 v1.1.0
#  */
git_compare_tags() {
  local show_help_tags
  show_help_tags() {
    cat << 'EOF'
Usage: git_compare_tags [options] [<tag_a>] [<tag_b>]

Options:
  -h, --help            Show this help message.
  -o, --output <file>   Write the Markdown report to <file>.
  -s, --silent          Suppress stdout output.
      --no-diff         Omit per-file unified diffs from the report.

Arguments:
  <tag_a>               Base tag (if omitted, uses second-latest tag).
  <tag_b>               Target tag (if 1 arg given, defaults to HEAD; if 0 args, uses latest tag).
EOF
  }

  local output_file="" silent_mode=0 include_diff=1
  local -a pos_args
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help) show_help_tags; return 0 ;;
      -o|--output)
        [[ -z "${2:-}" ]] && { log_error "Option $1 requires a file path."; return 1; }
        output_file="$2"; shift 2 ;;
      -s|--silent) silent_mode=1; shift ;;
      --no-diff) include_diff=0; shift ;;
      -*) log_error "Unknown option: $1. Use -h or --help."; return 1 ;;
      *) pos_args+=("$1"); shift ;;
    esac
  done

  local tag_a="" tag_b=""
  if (( ${#pos_args} == 0 )); then
    local -a recent_tags
    recent_tags=( ${(f)"$(git_list_tags)"} )
    recent_tags=( ${recent_tags:#} )
    if (( ${#recent_tags} < 2 )); then
      log_error "Fewer than 2 tags found in repository. Specify tags explicitly."
      return 1
    fi
    tag_a="${recent_tags[2]}"
    tag_b="${recent_tags[1]}"
  elif (( ${#pos_args} == 1 )); then
    tag_a="${pos_args[1]}"
    tag_b="HEAD"
  elif (( ${#pos_args} == 2 )); then
    tag_a="${pos_args[1]}"
    tag_b="${pos_args[2]}"
  else
    log_error "Too many arguments. Expected 0, 1, or 2 tag names."
    return 1
  fi

  if ! git_tag_exists "${tag_a}"; then
    log_error "Tag '${tag_a}' does not exist."
    return 1
  fi
  if [[ "${tag_b}" != "HEAD" ]] && ! git_tag_exists "${tag_b}"; then
    log_error "Tag '${tag_b}' does not exist."
    return 1
  fi

  local -a args
  args=( --type "Tag" --source-label "${tag_a}" --target-label "${tag_b}" --source-ref "${tag_a}" --target-ref "${tag_b}" --silent "${silent_mode}" --include-diff "${include_diff}" )
  [[ -n "${output_file}" ]] && args+=( --output "${output_file}" )
  _git_generate_compare_report "${args[@]}"
}

# /**
#  * @function git_compare_releases
#  * @description Compares two releases (branches like release/1.0.0 or tags like v1.0.0) to pinpoint scope creep, commit gaps, and file diffs.
#  * @param {string} [options] - -h/--help, -o/--output <file>, -s/--silent, --no-diff.
#  * @param {string} [release_a] - Base/previous release branch or tag.
#  * @param {string} [release_b] - Target/new release branch or tag (defaults to current branch if 1 arg).
#  * @return {number} 0 on success, 1 on failure.
#  * @example
#  *   git_compare_releases -o release_diff.md release/1.0.0 release/1.1.0
#  */
git_compare_releases() {
  local show_help_rel
  show_help_rel() {
    cat << 'EOF'
Usage: git_compare_releases [options] [<release_a>] [<release_b>]

Options:
  -h, --help            Show this help message.
  -o, --output <file>   Write the Markdown report to <file>.
  -s, --silent          Suppress stdout output.
      --no-diff         Omit per-file unified diffs from the report.

Arguments:
  <release_a>           Base/previous release (branch e.g. release/1.0.0 or tag e.g. v1.0.0).
  <release_b>           Target/current release (defaults to current branch if 1 arg given).
EOF
  }

  local output_file="" silent_mode=0 include_diff=1
  local -a pos_args
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help) show_help_rel; return 0 ;;
      -o|--output)
        [[ -z "${2:-}" ]] && { log_error "Option $1 requires a file path."; return 1; }
        output_file="$2"; shift 2 ;;
      -s|--silent) silent_mode=1; shift ;;
      --no-diff) include_diff=0; shift ;;
      -*) log_error "Unknown option: $1. Use -h or --help."; return 1 ;;
      *) pos_args+=("$1"); shift ;;
    esac
  done

  local rel_a="" rel_b=""
  if (( ${#pos_args} == 0 )); then
    local -a rel_branches
    rel_branches=( ${(f)"$(git_list_branches "release/*")"} )
    rel_branches=( ${rel_branches:#} )
    if (( ${#rel_branches} >= 2 )); then
      rel_a="${rel_branches[-2]}"
      rel_b="${rel_branches[-1]}"
    else
      local -a rel_tags
      rel_tags=( ${(f)"$(git_list_tags)"} )
      rel_tags=( ${rel_tags:#} )
      if (( ${#rel_tags} >= 2 )); then
        rel_a="${rel_tags[2]}"
        rel_b="${rel_tags[1]}"
      else
        log_error "Could not auto-detect two releases (branches 'release/*' or tags). Specify explicitly."
        return 1
      fi
    fi
  elif (( ${#pos_args} == 1 )); then
    rel_a="${pos_args[1]}"
    rel_b=$(git_get_current_branch)
    [[ -z "${rel_b}" ]] && rel_b="HEAD"
  elif (( ${#pos_args} == 2 )); then
    rel_a="${pos_args[1]}"
    rel_b="${pos_args[2]}"
  else
    log_error "Too many arguments. Expected 0, 1, or 2 release refs."
    return 1
  fi

  local ref_a ref_b
  ref_a=$(git_resolve_ref "${rel_a}")
  ref_b=$(git_resolve_ref "${rel_b}")

  if ! git rev-parse --verify "${ref_a}^{commit}" >/dev/null 2>&1; then
    log_error "Release ref '${rel_a}' does not exist."
    return 1
  fi
  if ! git rev-parse --verify "${ref_b}^{commit}" >/dev/null 2>&1; then
    log_error "Release ref '${rel_b}' does not exist."
    return 1
  fi

  local -a args
  args=( --type "Release" --source-label "${rel_a}" --target-label "${rel_b}" --source-ref "${ref_a}" --target-ref "${ref_b}" --silent "${silent_mode}" --include-diff "${include_diff}" )
  [[ -n "${output_file}" ]] && args+=( --output "${output_file}" )
  _git_generate_compare_report "${args[@]}"
}

# /**
#  * @function git_compare_content
#  * @description Compares file or directory content between two Git refs (branch, commit, tag) optionally scoped by --path.
#  * @param {string} [options] - -h/--help, -o/--output <file>, -s/--silent, -p/--path <path>.
#  * @param {string} source_ref - Base Git ref (branch, commit, or tag).
#  * @param {string} [target_ref=HEAD] - Target Git ref.
#  * @return {number} 0 on success, 1 on failure.
#  * @example
#  *   git_compare_content -p functions/05-git.sh -o content_diff.md main HEAD
#  */
git_compare_content() {
  local show_help_cnt
  show_help_cnt() {
    cat << 'EOF'
Usage: git_compare_content [options] <source_ref> [<target_ref>]

Options:
  -h, --help            Show this help message.
  -o, --output <file>   Write the Markdown report to <file>.
  -s, --silent          Suppress stdout output.
  -p, --path <path>     Limit content comparison to a specific file or directory (repeatable).

Arguments:
  <source_ref>          Base branch, commit, or tag.
  [<target_ref>]        Target branch, commit, or tag (defaults to HEAD).
EOF
  }

  local output_file="" silent_mode=0
  local -a pos_args filter_paths
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help) show_help_cnt; return 0 ;;
      -o|--output)
        [[ -z "${2:-}" ]] && { log_error "Option $1 requires a file path."; return 1; }
        output_file="$2"; shift 2 ;;
      -s|--silent) silent_mode=1; shift ;;
      -p|--path)
        [[ -z "${2:-}" ]] && { log_error "Option $1 requires a path."; return 1; }
        filter_paths+=("$2"); shift 2 ;;
      -*) log_error "Unknown option: $1. Use -h or --help."; return 1 ;;
      *) pos_args+=("$1"); shift ;;
    esac
  done

  if (( ${#pos_args} < 1 || ${#pos_args} > 2 )); then
    log_error "git_compare_content requires 1 or 2 refs: <source_ref> [<target_ref>]."
    return 1
  fi

  local src="${pos_args[1]}" tgt="${pos_args[2]:-HEAD}"
  local src_ref tgt_ref
  src_ref=$(git_resolve_ref "${src}")
  tgt_ref=$(git_resolve_ref "${tgt}")

  if ! git rev-parse --verify "${src_ref}^{commit}" >/dev/null 2>&1; then
    log_error "Invalid source ref: ${src}"
    return 1
  fi
  if ! git rev-parse --verify "${tgt_ref}^{commit}" >/dev/null 2>&1; then
    log_error "Invalid target ref: ${tgt}"
    return 1
  fi

  local -a args
  args=( --type "Content" --source-label "${src}" --target-label "${tgt}" --source-ref "${src_ref}" --target-ref "${tgt_ref}" --silent "${silent_mode}" --include-diff 1 )
  [[ -n "${output_file}" ]] && args+=( --output "${output_file}" )
  local p
  for p in "${filter_paths[@]}"; do
    args+=( --path "${p}" )
  done
  _git_generate_compare_report "${args[@]}"
}

# /**
#  * @function git_compare_working_tree
#  * @description Compares the working tree or staged index against HEAD (or a specified ref) and generates a Markdown report.
#  * @param {string} [options] - -h/--help, -o/--output <file>, -s/--silent, --staged, -p/--path <path>.
#  * @param {string} [base_ref=HEAD] - Base ref to compare against.
#  * @return {number} 0 on success, 1 on failure.
#  * @example
#  *   git_compare_working_tree --staged -o staged_changes.md
#  */
git_compare_working_tree() {
  local show_help_wt
  show_help_wt() {
    cat << 'EOF'
Usage: git_compare_working_tree [options] [<base_ref>]

Options:
  -h, --help            Show this help message.
  -o, --output <file>   Write the Markdown report to <file>.
  -s, --silent          Suppress stdout output.
      --staged          Compare only staged changes (--cached) against <base_ref>.
  -p, --path <path>     Limit comparison to a specific file or directory (repeatable).

Arguments:
  [<base_ref>]          Base ref to compare against (defaults to HEAD).
EOF
  }

  local output_file="" silent_mode=0 staged_only=0
  local -a pos_args filter_paths
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help) show_help_wt; return 0 ;;
      -o|--output)
        [[ -z "${2:-}" ]] && { log_error "Option $1 requires a file path."; return 1; }
        output_file="$2"; shift 2 ;;
      -s|--silent) silent_mode=1; shift ;;
      --staged) staged_only=1; shift ;;
      -p|--path)
        [[ -z "${2:-}" ]] && { log_error "Option $1 requires a path."; return 1; }
        filter_paths+=("$2"); shift 2 ;;
      -*) log_error "Unknown option: $1. Use -h or --help."; return 1 ;;
      *) pos_args+=("$1"); shift ;;
    esac
  done

  if (( ${#pos_args} > 1 )); then
    log_error "Too many arguments. Expected at most 1 base ref."
    return 1
  fi

  local base_ref="${pos_args[1]:-HEAD}"
  local resolved_base
  resolved_base=$(git_resolve_ref "${base_ref}")
  if ! git rev-parse --verify "${resolved_base}^{commit}" >/dev/null 2>&1; then
    log_error "Invalid base ref: ${base_ref}"
    return 1
  fi

  local wt_mode="worktree" tgt_label="Working Tree"
  if (( staged_only == 1 )); then
    wt_mode="staged"
    tgt_label="Staged Index"
  fi

  local -a args
  args=( --type "Worktree" --source-label "${base_ref}" --target-label "${tgt_label}" --source-ref "${resolved_base}" --target-ref "${tgt_label}" --worktree-mode "${wt_mode}" --silent "${silent_mode}" --include-diff 1 --include-commits 0 )
  [[ -n "${output_file}" ]] && args+=( --output "${output_file}" )
  local p
  for p in "${filter_paths[@]}"; do
    args+=( --path "${p}" )
  done
  _git_generate_compare_report "${args[@]}"
}

# /**
#  * @function git_compare
#  * @description Unified Git comparison dispatcher supporting branch, commit, tag, release, content, worktree, and three-way comparisons.
#  * @param {string} --type|-t <type> - Comparison type: branch, commit, tag, release, content, worktree, three-way.
#  * @param {string} [options] - Type-specific options (-o/--output, -s/--silent, -p/--path, --diff, --no-diff, --staged).
#  * @return {number} 0 on success, 1 on error.
#  * @example
#  *   git_compare --type tag -o tag_diff.md v1.0.0 v1.1.0
#  *   git_compare -t release release/1.0.0 release/1.1.0
#  */
git_compare() {
  local show_help_cmp
  show_help_cmp() {
    cat << 'EOF'
Usage: git_compare --type <type> [options] [<source>] [<target>] [<extra>]

Types (-t, --type):
  branch      Compare two branches (delegates to git_compare_branches)
  commit      Compare two commits or refs (delegates to git_compare_commits)
  tag         Compare two tags (delegates to git_compare_tags)
  release     Compare two release branches or tags (delegates to git_compare_releases)
  content     Compare file/directory content between two refs (delegates to git_compare_content)
  worktree    Compare working tree or staged index against a base ref (delegates to git_compare_working_tree)
  three-way   Compare two release branches against default branch (delegates to git_compare_three_branches)

Options:
  -t, --type <type>     Comparison type (default: branch).
      --list-types      List supported comparison types and exit.
  -h, --help            Show this help message.
  All other options (-o/--output, -s/--silent, -p/--path, --diff, --no-diff, --staged) are forwarded.
EOF
  }

  local cmp_type="branch"
  local -a forward_args

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        show_help_cmp
        return 0
        ;;
      --list-types)
        printf '%s\n' "branch" "commit" "tag" "release" "content" "worktree" "three-way"
        return 0
        ;;
      -t|--type)
        if [[ -z "${2:-}" ]]; then
          log_error "Option $1 requires a comparison type."
          return 1
        fi
        cmp_type="${2:l}"
        shift 2
        ;;
      *)
        forward_args+=("$1")
        shift
        ;;
    esac
  done

  case "${cmp_type}" in
    branch|branches)
      git_compare_branches "${forward_args[@]}"
      ;;
    commit|commits)
      git_compare_commits "${forward_args[@]}"
      ;;
    tag|tags)
      git_compare_tags "${forward_args[@]}"
      ;;
    release|releases)
      git_compare_releases "${forward_args[@]}"
      ;;
    content)
      git_compare_content "${forward_args[@]}"
      ;;
    worktree|working-tree|working_tree)
      git_compare_working_tree "${forward_args[@]}"
      ;;
    three-way|three_way|3way)
      git_compare_three_branches "${forward_args[@]}"
      ;;
    *)
      log_error "Unsupported comparison type: '${cmp_type}'. Use --list-types to see supported types."
      return 1
      ;;
  esac
}
