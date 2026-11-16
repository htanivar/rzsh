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

  # For renames, extract the target (new) filename
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
