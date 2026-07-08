#!/usr/bin/env zsh
# examples/03_navigation_example.sh
# Non-technical guide to folder navigation and project paths.

source "$(dirname "$0")/../config/config.sh"
init_config

# 1. Get the directory containing this script
local current_dir=$(get_current_directory)
echo "This script is located in: ${current_dir}"

# 2. Go two folders up
local parent_dir=$(dir_up 2)
echo "Two folders above this script is: ${parent_dir}"

# 3. Get canonical absolute path
local raw_path="../functions/01-logs.sh"
local clean_path=$(get_absolute_path "${raw_path}")
echo "Relative path '${raw_path}' resolves to absolute: ${clean_path}"

# 4. Locate project root
local root=$(get_project_root)
echo "Framework project root is: ${root}"

# 5. Check if inside Git
if is_inside_git_repo; then
  echo "Yes, the current folder is inside a Git repository."
fi

# 6. Ensure folder exists
ensure_directory_exists "${PROJECT_ROOT}/logs/backup_folder"
echo "Verified that logs/backup_folder directory exists."
