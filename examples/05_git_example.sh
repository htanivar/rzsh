#!/usr/bin/env zsh
# examples/05_git_example.sh
# Non-technical guide to Git commands and branch states.

source "$(dirname "$0")/../config/config.sh"
init_config

# 1. Get current branch
local branch=$(git_get_current_branch)
echo "Active Git branch: ${branch}"

# 2. Check if clean
if git_is_clean; then
  echo "No uncommitted modifications in repository."
else
  echo "Working copy has uncommitted modifications."
fi

# 3. Print status message summary
echo "Git Status Summary:"
git_status_message

# 4. Get active commit hash
local hash=$(git_get_commit_hash)
echo "Active Commit Hash (SHA-1): ${hash}"

# 5. Compare current branch with another branch (e.g. main)
local target_cmp="main"
if [[ "${branch}" == "main" ]] && git_branch_exists "master"; then
  target_cmp="master"
fi

if git_branch_exists "${target_cmp}"; then
  echo "Comparing current branch with ${target_cmp}..."
  git_compare_branches --silent --output "${PROJECT_ROOT}/logs/compare_example.md" "${target_cmp}" "${branch}"
  echo "Comparison report written to logs/compare_example.md"
fi

