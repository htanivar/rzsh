#!/usr/bin/env zsh

# 1. Load the framework via RZSH_DIR (this imports all helper functions automatically)
source "${RZSH_DIR}/config/config.sh"
init_config
init_logging

is_inside_git_repo || error_exit "Not inside a Git repository."

# 2. Detect default branch and ask if user wants to change it (e.g., to compare 2 release branches)
target_branch=$(git_detect_default_branch || git_get_current_branch)
log_info "Default Branch: ${target_branch}"
if confirm "Change target branch (e.g., to compare 2 release branches)?" "n"; then
  target_branch=$(git_pick_branch "Select target branch:") || exit 1
fi

# 3. Pick release branch to check
release_branch=$(git_pick_branch "Select release branch:" "release/*") || exit 1

# 4. Highlight commits not backported to target branch
git_report_missed_commits "${target_branch}" "${release_branch}" "./logs/backport_report.md"
