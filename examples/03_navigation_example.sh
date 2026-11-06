#!/usr/bin/env zsh
# examples/03_navigation_example.sh
# Non-technical guide to folder navigation and project paths.
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

if [[ -z "${RZSH_DIR:-}" ]]; then
  printf '[WARN] RZSH_DIR is not set. Please set export RZSH_DIR="%s" in your environment (e.g., ~/.zshrc).\n' "${0:A:h:h}" >&2
  export RZSH_DIR="${0:A:h:h}"
fi

source "${RZSH_DIR}/config/config.sh"
init_config

# 1. Get the directory containing this script
current_dir=$(get_current_directory)
echo "This script is located in: ${current_dir}"

# 2. Go two folders up
parent_dir=$(dir_up 2)
echo "Two folders above this script is: ${parent_dir}"

# 3. Get canonical absolute path
raw_path="../functions/01-logs.sh"
clean_path=$(get_absolute_path "${raw_path}")
echo "Relative path '${raw_path}' resolves to absolute: ${clean_path}"

# 4. Locate project root
root=$(get_project_root)
echo "Framework project root is: ${root}"

# 5. Check if inside Git
if is_inside_git_repo; then
  echo "Yes, the current folder is inside a Git repository."
fi

# 6. Ensure folder exists
ensure_directory_exists "${PROJECT_ROOT}/logs/backup_folder"
echo "Verified that logs/backup_folder directory exists."

# 7. Change directory
target_dir="${PROJECT_ROOT}/logs/backup_folder"
if change_directory "${target_dir}"; then
  echo "Successfully changed directory to: ${PWD}"
  # Change back to project root
  change_directory "${PROJECT_ROOT}"
else
  echo "Failed to change directory."
fi
rm -rf "${PROJECT_ROOT}/logs/backup_folder"

