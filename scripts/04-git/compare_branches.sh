#!/usr/bin/env zsh
# scripts/04-git/compare_branches.sh
# Compare two git branches, output a structured summary, and show contents in separate sections.

# Resolve PROJECT_ROOT if not set
if [[ -z "${PROJECT_ROOT:-}" ]]; then
  export PROJECT_ROOT="${0:A:h:h:h}"
fi

# Source framework config and functions
source "${PROJECT_ROOT}/config/config.sh"
init_config || {
  printf "Error: Failed to initialize framework configuration.\n" >&2
  exit 1
}

# Ensure validation module is sourced
if ! typeset -f validate_command_exists >/dev/null; then
  if [[ -f "${PROJECT_ROOT}/functions/04-validation.sh" ]]; then
    source "${PROJECT_ROOT}/functions/04-validation.sh"
  fi
fi

# Ensure git functions are sourced
if ! typeset -f git_get_current_branch >/dev/null; then
  if [[ -f "${PROJECT_ROOT}/functions/05-git.sh" ]]; then
    source "${PROJECT_ROOT}/functions/05-git.sh"
  fi
fi

# Ensure error functions are sourced
if ! typeset -f error_exit >/dev/null; then
  if [[ -f "${PROJECT_ROOT}/functions/02-errors.sh" ]]; then
    source "${PROJECT_ROOT}/functions/02-errors.sh"
  fi
fi

# Ensure string functions are sourced
if ! typeset -f str_pad_right >/dev/null; then
  if [[ -f "${PROJECT_ROOT}/functions/11-string.sh" ]]; then
    source "${PROJECT_ROOT}/functions/11-string.sh"
  fi
fi

# Ensure navigation functions are sourced
if ! typeset -f is_inside_git_repo >/dev/null; then
  if [[ -f "${PROJECT_ROOT}/functions/03-navigation.sh" ]]; then
    source "${PROJECT_ROOT}/functions/03-navigation.sh"
  fi
fi

# 1. Parse arguments and check help
show_help() {
  cat << EOF
Usage: $0 [options] [<branch_a>] [<branch_b>]

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
      show_help
      exit 0
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
      error_exit "Unknown option: $1. Use -h or --help for usage." 1
      ;;
    *)
      branches+=("$1")
      shift
      ;;
  esac
done

# 2. Check if inside git repo
if ! is_inside_git_repo; then
  error_exit "Not inside a Git repository." 1
fi

local git_root
git_root=$(git_get_root)
# Go to git root to run all diff commands from there
cd "${git_root}" || error_exit "Failed to navigate to Git repository root: ${git_root}" 1

# 3. Determine branches to compare
local branch_a=""
local branch_b=""
local current_branch
current_branch=$(git_get_current_branch)

if [[ ${#branches} -eq 0 ]]; then
  # Default comparison: compare current branch with default branch (main/master)
  branch_a="${current_branch}"
  # Detect default branch
  if git_branch_exists "main"; then
    branch_b="main"
  elif git_branch_exists "master"; then
    branch_b="master"
  else
    error_exit "Could not detect default branch (neither 'main' nor 'master' exists). Please specify branches explicitly." 1
  fi
elif [[ ${#branches} -eq 1 ]]; then
  # One branch specified: compare current branch with it
  branch_a="${current_branch}"
  branch_b="${branches[1]}"
elif [[ ${#branches} -eq 2 ]]; then
  # Two branches specified
  branch_a="${branches[1]}"
  branch_b="${branches[2]}"
else
  error_exit "Too many arguments. Expected 0, 1, or 2 branch names." 1
fi

# Validate branch existence
if ! git_branch_exists "${branch_a}"; then
  error_exit "Branch '${branch_a}' does not exist." 1
fi
if ! git_branch_exists "${branch_b}"; then
  error_exit "Branch '${branch_b}' does not exist." 1
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

local line diff_status file1 file2
for line in "${diff_lines[@]}"; do
  [[ -z "${line}" ]] && continue
  IFS=$'\t' read -r diff_status file1 file2 <<< "${line}"
  
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

append_file_list_md() {
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

append_file_list_term() {
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
local rf
for rf in "${renamed_files[@]}"; do
  local new_part="${rf##* -> }"
  all_changed_files+=("${new_part}")
done

# Include deleted files as well to show their removed diff
all_changed_files+=( "${deleted_files[@]}" )

# Unique elements
all_changed_files=( ${(u)all_changed_files} )

local f_path
for f_path in "${all_changed_files[@]}"; do
  [[ -z "${f_path}" ]] && continue
  
  # Determine status for this file
  local f_status="Modified"
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
  local diff_content
  diff_content=$(git diff "${branch_a}" "${branch_b}" -- "${f_path}" 2>/dev/null)
  
  # If diff is empty (e.g. rename without changes, or binary differences)
  if [[ -z "${diff_content}" ]]; then
    if git diff --numstat "${branch_a}" "${branch_b}" -- "${f_path}" | grep -q '^-'; then
      diff_content="[Binary file differences]"
    else
      diff_content="[No content changes or file is metadata-only]"
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
  local status_color="${yellow}"
  [[ "${f_status}" == "Added" ]] && status_color="${green}"
  [[ "${f_status}" == "Deleted" ]] && status_color="${red}"
  [[ "${f_status}" == "Renamed" ]] && status_color="${cyan}"
  
  terminal_output+="${bold}--------------------------------------------------------------------------------${reset}\n"
  terminal_output+="${bold}File: ${f_path} (${status_color}${f_status}${reset}${bold})${reset}\n"
  terminal_output+="${bold}--------------------------------------------------------------------------------${reset}\n"
  
  if [[ "${diff_content}" == "["* ]]; then
    terminal_output+="  ${magenta}${diff_content}${reset}\n\n"
  else
    local diff_line
    local -a diff_lines_arr
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

exit 0
