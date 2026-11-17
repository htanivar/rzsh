#!/usr/bin/env zsh
# examples/05_git_example.sh
# Breadcrumb: README.md -> GLOSSARY.md -> docs/05-git.md -> examples/05_git_example.sh -> tests/05-git.test.sh
# Non-technical guide to Git commands and branch states.
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

if [[ -z "${RZSH_DIR:-}" ]]; then
  printf '[WARN] RZSH_DIR is not set. Please set export RZSH_DIR="%s" in your environment (e.g., ~/.zshrc).\n' "${0:A:h:h}" >&2
  export RZSH_DIR="${0:A:h:h}"
fi

source "${RZSH_DIR}/config/config.sh"
init_config

# 1. Get repository root & current branch
git_root=$(git_get_root)
echo "Git Repository Root: ${git_root}"

branch=$(git_get_current_branch)
echo "Active Git branch: ${branch}"

# 2. Detect default branch & resolve ref
if default_branch=$(git_detect_default_branch); then
  echo "Detected default branch: ${default_branch} (ref: $(git_resolve_ref "${default_branch}"))"
else
  echo "No default branch (origin/HEAD, develop, main, master) detected."
fi

# 3. Check if clean
if git_is_clean; then
  echo "No uncommitted modifications in repository."
else
  echo "Working copy has uncommitted modifications."
fi

# 4. Print status message summary
echo "Git Status Summary:"
git_status_message

# 5. Get active commit hash, message, and formatted summary
hash=$(git_get_commit_hash)
msg=$(git_get_commit_message "HEAD")
formatted=$(git_format_commit "HEAD")
echo "Active Commit Hash (SHA-1): ${hash}"
echo "Active Commit Message: ${msg}"
echo "Formatted Commit: ${formatted}"

# 6. List available branches (optionally filtered by glob pattern, e.g. "release/*")
echo "Available Branches:"
git_list_branches

# Interactive branch picker (uncomment to test interactively):
# picked_branch=$(git_pick_branch "Select a branch to inspect" "release/*")
# echo "You selected: ${picked_branch}"

# 7. Compare current branch with another branch (e.g. default_branch or main)
target_cmp="${default_branch:-main}"
if [[ "${branch}" == "${target_cmp}" ]] && git_branch_exists "master"; then
  target_cmp="master"
fi

if git_branch_exists "${target_cmp}"; then
  echo "Comparing current branch with ${target_cmp}..."
  git_compare_branches --silent --output "${PROJECT_ROOT}/logs/compare_example.md" "${target_cmp}" "${branch}"
  echo "Comparison report written to logs/compare_example.md"

  # 8. Check for commits in current branch not yet backported to target_cmp
  echo "Checking missed commits (${branch} -> ${target_cmp})..."
  missed_shas=( ${(f)"$(git_get_missed_commits "${target_cmp}" "${branch}")"} )
  echo "Missed commit count: ${#missed_shas}"
  git_report_missed_commits "${target_cmp}" "${branch}" "${PROJECT_ROOT}/logs/missed_commits_example.md" 1
  echo "Backport report written to logs/missed_commits_example.md"
fi

# 9. Compare 3 branches (release/x, release/x-1, default) when release branches exist
# git_compare_three_branches --output "${PROJECT_ROOT}/logs/three_branch_example.md" release/2.2.0 release/2.1.0 develop

