# functions/05-git.sh

# Protect against double sourcing
if [[ -n "${_GIT_SH_SOURCED:-}" ]]; then
  return 0
fi
readonly _GIT_SH_SOURCED=1

# Ensure config & logs are sourced if available
if [[ -f "${PROJECT_ROOT:-.}/config/config.sh" ]]; then
  source "${PROJECT_ROOT:-.}/config/config.sh"
fi
if [[ -f "${PROJECT_ROOT:-.}/functions/01-logs.sh" ]]; then
  source "${PROJECT_ROOT:-.}/functions/01-logs.sh"
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
