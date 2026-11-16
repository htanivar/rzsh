#!/usr/bin/env bash
# ==============================================================================
# Script Name: git-doctor.sh
# Path:        scripts/lib/git/git-doctor.sh
# Description: Self-analyzing, interactive Git diagnostic & repair utility.
#              Detects common issues with pushing, merging, conflicts, remotes,
#              branch divergence, and GitHub PR workflows (e.g., origin/HEAD
#              missing, auto-merge disabled, merge conflicts, detached HEAD,
#              lock files). Explains each problem using the structured format:
#                - Issue
#                - Suggestion
#                - Preferred
#                - Caution
#              and offers interactive fixes, diff inspection, and branch comparison.
#
# Usage:
#   Direct execution:
#     ./scripts/lib/git/git-doctor.sh [options]
#   Or sourced as a library:
#     source scripts/lib/git/git-doctor.sh
#     git_doctor_run
# ==============================================================================

# Ensure safe execution without breaking parent shell when sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    set -uo pipefail
fi

# ------------------------------------------------------------------------------
# Color & Formatting Definitions
# ------------------------------------------------------------------------------
if [[ -t 1 ]]; then
    GD_RED='\033[0;31m'
    GD_GREEN='\033[0;32m'
    GD_YELLOW='\033[1;33m'
    GD_BLUE='\033[0;34m'
    GD_MAGENTA='\033[0;35m'
    GD_CYAN='\033[0;36m'
    GD_BOLD='\033[1m'
    GD_DIM='\033[2m'
    GD_RESET='\033[0m'
else
    GD_RED=''
    GD_GREEN=''
    GD_YELLOW=''
    GD_BLUE=''
    GD_MAGENTA=''
    GD_CYAN=''
    GD_BOLD=''
    GD_DIM=''
    GD_RESET=''
fi

# Global state counters
GD_ISSUES_FOUND=0
GD_ISSUES_FIXED=0
GD_AUTO_MODE=false

# ------------------------------------------------------------------------------
# UI & Output Helpers
# ------------------------------------------------------------------------------
git_doctor_banner() {
    echo -e "${GD_CYAN}${GD_BOLD}"
    echo "=============================================================================="
    echo "  🩺 GIT DOCTOR - Interactive Git Diagnostic, Diff & Recovery Assistant"
    echo "=============================================================================="
    echo -e "${GD_RESET}"
}

git_doctor_section() {
    echo -e "\n${GD_BLUE}${GD_BOLD}▶ $1${GD_RESET}"
    echo -e "${GD_DIM}------------------------------------------------------------------------------${GD_RESET}"
}

git_doctor_info() {
    echo -e "${GD_CYAN}[INFO]${GD_RESET} $*"
}

git_doctor_success() {
    echo -e "${GD_GREEN}[OK]${GD_RESET}   $*"
}

git_doctor_warn() {
    echo -e "${GD_YELLOW}[WARN]${GD_RESET} $*"
}

git_doctor_error() {
    echo -e "${GD_RED}[ERR]${GD_RESET}  $*"
}

# Structured Issue Report matching requested specification:
#   Issue:
#   Suggestion:
#   Preferred:
#   Caution:
git_doctor_report_issue() {
    local title="$1"
    local issue_desc="$2"
    local suggestion_desc="$3"
    local preferred_desc="$4"
    local caution_desc="$5"

    ((GD_ISSUES_FOUND++)) || true

    echo ""
    echo -e "${GD_RED}${GD_BOLD}⚠ DETECTED PROBLEM #${GD_ISSUES_FOUND}: ${title}${GD_RESET}"
    echo -e "${GD_DIM}==============================================================================${GD_RESET}"
    echo -e "${GD_BOLD}${GD_RED}Issue:${GD_RESET}      ${issue_desc}"
    echo -e "${GD_BOLD}${GD_CYAN}Suggestion:${GD_RESET} ${suggestion_desc}"
    echo -e "${GD_BOLD}${GD_GREEN}Preferred:${GD_RESET}  ${preferred_desc}"
    echo -e "${GD_BOLD}${GD_YELLOW}Caution:${GD_RESET}    ${caution_desc}"
    echo -e "${GD_DIM}==============================================================================${GD_RESET}"
}

git_doctor_confirm() {
    local prompt="${1:-Apply preferred fix now?}"
    if [[ "${GD_AUTO_MODE}" == "true" ]]; then
        echo -e "${GD_CYAN}${prompt} [y/N]: y (auto-mode)${GD_RESET}"
        return 0
    fi
    local ans
    read -r -p "$(echo -e "${GD_BOLD}${prompt} [y/N]: ${GD_RESET}")" ans
    case "${ans}" in
        [yY]|[yY][eE][sS]) return 0 ;;
        *) return 1 ;;
    esac
}

git_doctor_choose() {
    local prompt="$1"
    shift
    local options=("$@")
    echo -e "\n${GD_BOLD}${prompt}${GD_RESET}"
    local i=1
    for opt in "${options[@]}"; do
        echo -e "  ${GD_CYAN}${i})${GD_RESET} ${opt}"
        ((i++))
    done
    local choice
    while true; do
        read -r -p "$(echo -e "${GD_BOLD}Select an option [1-${#options[@]}]: ${GD_RESET}")" choice
        if [[ "${choice}" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#options[@]} )); then
            return $((choice - 1))
        fi
        echo -e "${GD_YELLOW}Invalid selection. Please enter a number between 1 and ${#options[@]}.${GD_RESET}"
    done
}

# ------------------------------------------------------------------------------
# Helper: Detect Default Base Branch Safely
# ------------------------------------------------------------------------------
git_doctor_detect_base_branch() {
    local remote="${1:-origin}"
    local base=""

    # 1. Try symbolic-ref on remote HEAD
    base="$(git symbolic-ref --quiet --short "refs/remotes/${remote}/HEAD" 2>/dev/null | sed "s|^${remote}/||" || true)"
    if [[ -n "${base}" ]]; then
        echo "${base}"
        return 0
    fi

    # 2. Try querying GitHub CLI if available
    if command -v gh >/dev/null 2>&1; then
        base="$(gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name' 2>/dev/null || true)"
        if [[ -n "${base}" && "${base}" != "null" ]]; then
            echo "${base}"
            return 0
        fi
    fi

    # 3. Try common default branch names in remote refs
    local candidate
    for candidate in main master develop trunk; do
        if git show-ref --verify --quiet "refs/remotes/${remote}/${candidate}" 2>/dev/null || \
           git show-ref --verify --quiet "refs/heads/${candidate}" 2>/dev/null; then
            echo "${candidate}"
            return 0
        fi
    done

    return 1
}

# ------------------------------------------------------------------------------
# Check 1: Inside a Valid Git Repository & Stale Lock Files
# ------------------------------------------------------------------------------
git_doctor_check_repo_and_locks() {
    git_doctor_section "1. Repository Integrity & Lock Check"

    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        git_doctor_report_issue \
            "Not a Git Repository" \
            "The current directory ($(pwd)) is not inside a valid Git working tree." \
            "1) Navigate (cd) to your project root directory, or 2) Initialize a new repository with 'git init'." \
            "Change directory to the existing repository root before running git operations." \
            "Running 'git init' in the wrong folder creates an empty nested repository instead of fixing your project."
        return 1
    fi

    local git_dir
    git_dir="$(git rev-parse --git-dir 2>/dev/null)"
    git_doctor_success "Git repository detected (${git_dir})."

    # Check for stale .git/index.lock or other lock files
    if [[ -f "${git_dir}/index.lock" ]]; then
        git_doctor_report_issue \
            "Stale Git Lock File (${git_dir}/index.lock)" \
            "A '${git_dir}/index.lock' file exists. Another git process may have crashed or is currently running, blocking all new commits, merges, or checkouts." \
            "1) Verify no other git process is active ('ps aux | grep git') and remove '${git_dir}/index.lock'. 2) Wait if an IDE or background fetch is still running." \
            "Check for active git processes and safely delete '${git_dir}/index.lock'." \
            "Deleting index.lock while another git process is actively writing to the index can corrupt the staging area."

        if git_doctor_confirm "Remove stale '${git_dir}/index.lock' now?"; then
            rm -f "${git_dir}/index.lock" && {
                git_doctor_success "Removed ${git_dir}/index.lock."
                ((GD_ISSUES_FIXED++)) || true
            }
        fi
    else
        git_doctor_success "No stale lock files found."
    fi
    return 0
}

# ------------------------------------------------------------------------------
# Check 2: Remote 'origin' & refs/remotes/origin/HEAD Symbolic Ref
# ------------------------------------------------------------------------------
git_doctor_check_remote_head() {
    git_doctor_section "2. Remote Configuration & Default Base Branch (origin/HEAD)"

    if ! git remote get-url origin >/dev/null 2>&1; then
        git_doctor_report_issue \
            "Missing 'origin' Remote" \
            "No remote named 'origin' is configured for this repository. Push, pull, and PR scripts cannot communicate with a remote server." \
            "1) Add a remote using 'git remote add origin <url>'. 2) Check existing remotes with 'git remote -v'." \
            "Configure 'origin' pointing to your primary remote repository URL." \
            "Pushing to the wrong remote URL may expose code to an unintended repository."

        if git_doctor_confirm "Would you like to configure the 'origin' remote URL now?"; then
            local remote_url
            read -r -p "Enter remote origin URL: " remote_url
            if [[ -n "${remote_url}" ]]; then
                git remote add origin "${remote_url}" && {
                    git_doctor_success "Added remote 'origin' -> ${remote_url}"
                    ((GD_ISSUES_FIXED++)) || true
                }
            fi
        fi
        return 0
    fi

    local origin_url
    origin_url="$(git remote get-url origin 2>/dev/null)"
    git_doctor_success "Remote 'origin' configured: ${origin_url}"

    # Check refs/remotes/origin/HEAD symbolic ref
    # Matches exact error: "fatal: ref refs/remotes/origin/HEAD is not a symbolic ref"
    if ! git symbolic-ref -q refs/remotes/origin/HEAD >/dev/null 2>&1; then
        local guessed_base
        guessed_base="$(git_doctor_detect_base_branch origin || echo "main")"

        git_doctor_report_issue \
            "Missing Remote Default Branch Reference (refs/remotes/origin/HEAD is not a symbolic ref)" \
            "Git does not have 'refs/remotes/origin/HEAD' set locally (error: 'fatal: ref refs/remotes/origin/HEAD is not a symbolic ref'). Because of this, automation scripts fail to detect the base branch ('Base branch detected: <empty>')." \
            "1) Run 'git remote set-head origin --auto' to query the remote server for its default branch. 2) Manually set it locally via 'git remote set-head origin ${guessed_base}'." \
            "Run 'git remote set-head origin --auto' (with fallback to 'git remote set-head origin ${guessed_base}') so Git and PR scripts always know the default base branch." \
            "'git remote set-head origin --auto' requires network access to the remote. Setting the wrong branch manually could cause scripts to target the wrong base branch for diffs or PRs."

        git_doctor_choose "How would you like to fix refs/remotes/origin/HEAD?" \
            "[Preferred] Auto-detect from remote ('git remote set-head origin --auto', fallback to '${guessed_base}')" \
            "Set manually to '${guessed_base}' ('git remote set-head origin ${guessed_base}')" \
            "Specify a custom default branch name" \
            "Skip for now"
        local choice=$?

        case ${choice} in
            0)
                git_doctor_info "Running: git remote set-head origin --auto ..."
                if git remote set-head origin --auto 2>/dev/null; then
                    local resolved
                    resolved="$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null)"
                    git_doctor_success "Successfully set origin/HEAD -> ${resolved}"
                    ((GD_ISSUES_FIXED++)) || true
                else
                    git_doctor_warn "Network auto-detection failed or offline. Falling back to 'git remote set-head origin ${guessed_base}'..."
                    if git remote set-head origin "${guessed_base}" 2>/dev/null; then
                        git_doctor_success "Successfully set origin/HEAD -> origin/${guessed_base}"
                        ((GD_ISSUES_FIXED++)) || true
                    else
                        git_doctor_error "Could not set origin/HEAD to ${guessed_base}. Fetching remote branch first may be needed."
                    fi
                fi
                ;;
            1)
                if git remote set-head origin "${guessed_base}"; then
                    git_doctor_success "Successfully set origin/HEAD -> origin/${guessed_base}"
                    ((GD_ISSUES_FIXED++)) || true
                fi
                ;;
            2)
                local custom_branch
                read -r -p "Enter default branch name (e.g. main, master, develop): " custom_branch
                if [[ -n "${custom_branch}" ]] && git remote set-head origin "${custom_branch}"; then
                    git_doctor_success "Successfully set origin/HEAD -> origin/${custom_branch}"
                    ((GD_ISSUES_FIXED++)) || true
                fi
                ;;
            3)
                git_doctor_info "Skipped fixing origin/HEAD."
                ;;
        esac
    else
        local current_head
        current_head="$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null)"
        git_doctor_success "Remote HEAD symbolic ref is valid: ${current_head}"
    fi
}

# ------------------------------------------------------------------------------
# Check 3: Detached HEAD or Stuck Merge / Rebase / Cherry-Pick State
# ------------------------------------------------------------------------------
git_doctor_check_state_and_conflicts() {
    git_doctor_section "3. Branch State, In-Progress Operations & Merge Conflicts"

    local git_dir
    git_dir="$(git rev-parse --git-dir 2>/dev/null)"

    # Detached HEAD check
    local current_branch
    current_branch="$(git symbolic-ref --quiet --short HEAD 2>/dev/null || true)"
    if [[ -z "${current_branch}" ]]; then
        local sha
        sha="$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")"
        git_doctor_report_issue \
            "Detached HEAD State (at ${sha})" \
            "You are not on any named branch (HEAD points directly to commit ${sha}). Commits made now will be orphaned when you switch branches." \
            "1) Create a new branch here to keep your work: 'git switch -c <new-branch>'. 2) Checkout an existing branch: 'git checkout <branch>'." \
            "Create or switch to a named branch with 'git switch -c recovery-${sha}' so no commits are lost." \
            "Switching away from a detached HEAD without creating a branch will make any new commits unreachable and eventually garbage-collected."

        git_doctor_choose "How would you like to resolve Detached HEAD?" \
            "[Preferred] Create and switch to a new branch at current commit (${sha})" \
            "Switch to an existing branch" \
            "Skip for now"
        local dh_choice=$?
        case ${dh_choice} in
            0)
                local new_br
                read -r -p "Enter new branch name [default: recovery-${sha}]: " new_br
                new_br="${new_br:-recovery-${sha}}"
                if git checkout -b "${new_br}"; then
                    git_doctor_success "Created and switched to branch '${new_br}'."
                    ((GD_ISSUES_FIXED++)) || true
                fi
                ;;
            1)
                git branch -a
                local target_br
                read -r -p "Enter branch name to switch to: " target_br
                if [[ -n "${target_br}" ]] && git checkout "${target_br}"; then
                    git_doctor_success "Switched to branch '${target_br}'."
                    ((GD_ISSUES_FIXED++)) || true
                fi
                ;;
        esac
    else
        git_doctor_success "Current branch: ${current_branch}"
    fi

    # Check for unfinished merge, rebase, or cherry-pick
    if [[ -f "${git_dir}/MERGE_HEAD" ]]; then
        git_doctor_report_issue \
            "Merge in Progress (Unfinished Merge)" \
            "A merge operation is currently paused in progress (${git_dir}/MERGE_HEAD exists), usually due to merge conflicts." \
            "1) Resolve any conflicted files, stage them ('git add <file>'), and complete the merge ('git commit'). 2) Abort the merge and return to pre-merge state ('git merge --abort')." \
            "Inspect conflicted files, resolve conflicts, and complete the merge—or abort if the merge was unintentional." \
            "Running 'git merge --abort' discards any conflict resolutions you have already made during this merge attempt."

        git_doctor_choose "Merge in progress action:" \
            "[Preferred] Inspect & resolve conflicts interactively" \
            "Complete merge now ('git commit --no-edit' if conflicts are already staged)" \
            "Abort merge ('git merge --abort')" \
            "Skip for now"
        case $? in
            0) git_doctor_resolve_conflicts_interactive ;;
            1)
                if git commit --no-edit; then
                    git_doctor_success "Merge committed."
                    ((GD_ISSUES_FIXED++)) || true
                fi
                ;;
            2)
                if git merge --abort; then
                    git_doctor_success "Merge aborted cleanly."
                    ((GD_ISSUES_FIXED++)) || true
                fi
                ;;
        esac
    fi

    if [[ -d "${git_dir}/rebase-merge" || -d "${git_dir}/rebase-apply" ]]; then
        git_doctor_report_issue \
            "Rebase in Progress (Paused Rebase)" \
            "A rebase operation is paused in progress. You cannot switch branches or push normally until it finishes or is aborted." \
            "1) Resolve conflicts, 'git add' files, and run 'git rebase --continue'. 2) Skip current commit with 'git rebase --skip'. 3) Cancel rebase with 'git rebase --abort'." \
            "Resolve conflicts and run 'git rebase --continue', or 'git rebase --abort' to safely restore the branch." \
            "Aborting a rebase discards all progress made during the current rebase session."

        git_doctor_choose "Rebase in progress action:" \
            "[Preferred] Inspect & resolve conflicts, then 'git rebase --continue'" \
            "Continue rebase ('git rebase --continue')" \
            "Abort rebase ('git rebase --abort')" \
            "Skip for now"
        case $? in
            0)
                git_doctor_resolve_conflicts_interactive
                git rebase --continue || true
                ;;
            1) git rebase --continue && ((GD_ISSUES_FIXED++)) || true ;;
            2) git rebase --abort && { git_doctor_success "Rebase aborted."; ((GD_ISSUES_FIXED++)) || true; } ;;
        esac
    fi

    # Check for unmerged/conflicted files in index
    local conflicted_files
    conflicted_files="$(git diff --name-only --diff-filter=U 2>/dev/null || true)"
    if [[ -n "${conflicted_files}" ]]; then
        git_doctor_report_issue \
            "Unresolved Merge Conflicts in Working Tree" \
            "The following files have unresolved conflict markers (<<<<<<<, =======, >>>>>>>):\n$(echo "${conflicted_files}" | sed 's/^/              - /')" \
            "1) Open each file and edit out conflict markers, then 'git add <file>'. 2) Keep current branch version ('git checkout --ours <file>'). 3) Keep incoming branch version ('git checkout --theirs <file>')." \
            "Inspect the conflict diff for each file and choose the correct resolution (manual edit, ours, or theirs), then stage the file." \
            " blindly choosing '--ours' or '--theirs' overwrites changes from the other side of the merge for that entire file."

        if git_doctor_confirm "Launch interactive conflict resolver for conflicted files?"; then
            git_doctor_resolve_conflicts_interactive
        fi
    else
        git_doctor_success "No unresolved merge conflicts in index."
    fi
}

# ------------------------------------------------------------------------------
# Interactive Conflict Resolver Helper
# ------------------------------------------------------------------------------
git_doctor_resolve_conflicts_interactive() {
    local conflicted_files
    conflicted_files="$(git diff --name-only --diff-filter=U 2>/dev/null || true)"
    if [[ -z "${conflicted_files}" ]]; then
        git_doctor_success "No conflicted files found to resolve."
        return 0
    fi

    local file
    while IFS= read -r file; do
        [[ -z "${file}" ]] && continue
        echo -e "\n${GD_BOLD}${GD_YELLOW}Resolving conflict in: ${file}${GD_RESET}"
        git_doctor_choose "Select action for '${file}':" \
            "Show conflict diff ('git diff ${file}')" \
            "Keep OUR version (current branch: 'git checkout --ours ${file} && git add ${file}')" \
            "Keep THEIR version (incoming branch: 'git checkout --theirs ${file} && git add ${file}')" \
            "Open in editor (${EDITOR:-nano/vi}) and stage after saving" \
            "Skip this file"
        local action=$?
        case ${action} in
            0)
                git diff "${file}"
                # Re-prompt for the same file after showing diff
                git_doctor_choose "Now choose resolution for '${file}':" \
                    "Keep OUR version ('--ours')" \
                    "Keep THEIR version ('--theirs')" \
                    "Open in editor (${EDITOR:-vi})" \
                    "Skip this file"
                case $? in
                    0) git checkout --ours "${file}" && git add "${file}" && git_doctor_success "Resolved '${file}' using OURS." && ((GD_ISSUES_FIXED++)) || true ;;
                    1) git checkout --theirs "${file}" && git add "${file}" && git_doctor_success "Resolved '${file}' using THEIRS." && ((GD_ISSUES_FIXED++)) || true ;;
                    2) "${EDITOR:-vi}" "${file}" && git add "${file}" && git_doctor_success "Edited and staged '${file}'." && ((GD_ISSUES_FIXED++)) || true ;;
                esac
                ;;
            1)
                git checkout --ours "${file}" && git add "${file}" && {
                    git_doctor_success "Resolved '${file}' using OUR version."
                    ((GD_ISSUES_FIXED++)) || true
                }
                ;;
            2)
                git checkout --theirs "${file}" && git add "${file}" && {
                    git_doctor_success "Resolved '${file}' using THEIR version."
                    ((GD_ISSUES_FIXED++)) || true
                }
                ;;
            3)
                "${EDITOR:-vi}" "${file}"
                if ! grep -qE '^(<<<<<<<|=======|>>>>>>>)' "${file}" 2>/dev/null; then
                    git add "${file}"
                    git_doctor_success "No conflict markers remain. Staged '${file}'."
                    ((GD_ISSUES_FIXED++)) || true
                else
                    git_doctor_warn "Conflict markers still detected in '${file}'. File not staged."
                fi
                ;;
            4)
                git_doctor_info "Skipped '${file}'."
                ;;
        esac
    done <<< "${conflicted_files}"
}

# ------------------------------------------------------------------------------
# Check 4: Working Tree Cleanliness (Uncommitted Changes Blocking Merge/Pull)
# ------------------------------------------------------------------------------
git_doctor_check_working_tree() {
    git_doctor_section "4. Working Tree & Uncommitted Changes"

    local status_porcelain
    status_porcelain="$(git status --porcelain 2>/dev/null || true)"
    if [[ -z "${status_porcelain}" ]]; then
        git_doctor_success "Working tree is clean."
        return 0
    fi

    local staged_count unstaged_count untracked_count
    staged_count="$(echo "${status_porcelain}" | grep -cE '^[MADRC]' || true)"
    unstaged_count="$(echo "${status_porcelain}" | grep -cE '^.[MD]' || true)"
    untracked_count="$(echo "${status_porcelain}" | grep -cE '^\?\?' || true)"

    if (( staged_count > 0 || unstaged_count > 0 )); then
        git_doctor_report_issue \
            "Uncommitted Local Changes (${staged_count} staged, ${unstaged_count} modified, ${untracked_count} untracked)" \
            "Your working tree has uncommitted modifications. Pulling, rebasing, switching branches, or merging may fail with 'error: Your local changes to the following files would be overwritten by merge'." \
            "1) Commit your changes ('git add -A && git commit -m \"...\"'). 2) Temporarily stash changes ('git stash push -u -m \"git-doctor-backup\"'). 3) Inspect the diff ('git diff')." \
            "Stash changes ('git stash push -u') if you need to pull/merge immediately, or commit them if the work is ready." \
            "Discarding changes ('git reset --hard' or 'git checkout -- .') permanently deletes uncommitted work."

        git_doctor_choose "How would you like to handle uncommitted changes?" \
            "View diff of uncommitted changes ('git status -s' & 'git diff')" \
            "[Preferred for Pull/Merge] Stash changes safely ('git stash push -u -m \"git-doctor-stash\"')" \
            "[Preferred for Push] Stage all and commit ('git add -A && git commit')" \
            "Leave changes as-is (Skip)"
        case $? in
            0)
                git status -s
                git --no-pager diff HEAD
                ;;
            1)
                if git stash push -u -m "git-doctor-stash-$(date +%Y%m%d_%H%M%S)"; then
                    git_doctor_success "Changes stashed safely. Restore anytime with 'git stash pop'."
                    ((GD_ISSUES_FIXED++)) || true
                fi
                ;;
            2)
                local msg
                read -r -p "Enter commit message: " msg
                if [[ -n "${msg}" ]]; then
                    git add -A && git commit -m "${msg}" && {
                        git_doctor_success "Changes committed."
                        ((GD_ISSUES_FIXED++)) || true
                    }
                fi
                ;;
            3)
                git_doctor_info "Kept working tree changes untouched."
                ;;
        esac
    else
        git_doctor_info "Working tree has ${untracked_count} untracked file(s), no modified tracked files."
    fi
}

# ------------------------------------------------------------------------------
# Check 5: Upstream Tracking, Branch Divergence & Push Issues
# ------------------------------------------------------------------------------
git_doctor_check_upstream_and_divergence() {
    git_doctor_section "5. Upstream Tracking, Push Status & Branch Divergence"

    local current_branch
    current_branch="$(git symbolic-ref --quiet --short HEAD 2>/dev/null || true)"
    [[ -z "${current_branch}" ]] && return 0

    local upstream
    upstream="$(git rev-parse --abbrev-ref --symbolic-full-name "@{u}" 2>/dev/null || true)"

    if [[ -z "${upstream}" ]]; then
        git_doctor_report_issue \
            "No Upstream Tracking Branch Configured for '${current_branch}'" \
            "Branch '${current_branch}' has no upstream tracking reference ('fatal: The current branch ${current_branch} has no upstream branch'). Standard 'git push' or 'git pull' will fail without specifying remote and branch." \
            "1) Push and set upstream: 'git push -u origin ${current_branch}'. 2) Link to existing remote branch: 'git branch --set-upstream-to=origin/${current_branch}'." \
            "Run 'git push -u origin ${current_branch}' to publish the branch and configure automatic upstream tracking." \
            "Ensure 'origin' is the remote where you intend to publish '${current_branch}'."

        if git_doctor_confirm "Push '${current_branch}' and set upstream to 'origin/${current_branch}' now?"; then
            if git push -u origin "${current_branch}"; then
                git_doctor_success "Upstream set and branch '${current_branch}' pushed to origin."
                ((GD_ISSUES_FIXED++)) || true
            fi
        fi
        return 0
    fi

    git_doctor_success "Tracking upstream branch: ${upstream}"

    # Compare ahead/behind counts with upstream
    local counts ahead behind
    counts="$(git rev-list --left-right --count "${upstream}...HEAD" 2>/dev/null || echo "0 0")"
    behind="$(echo "${counts}" | awk '{print $1}')"
    ahead="$(echo "${counts}" | awk '{print $2}')"

    if (( behind > 0 && ahead > 0 )); then
        git_doctor_report_issue \
            "Diverged Branch ('${current_branch}' is ${ahead} commit(s) ahead and ${behind} commit(s) behind '${upstream}')" \
            "Your local branch and '${upstream}' have diverged. A normal 'git push' will be rejected with '[rejected] (non-fast-forward) Updates were rejected because the remote contains work that you do not have locally'." \
            "1) Rebase local commits on top of remote: 'git pull --rebase'. 2) Merge remote into local: 'git pull --no-rebase'. 3) Force-with-lease ONLY if you intentionally rewrote history: 'git push --force-with-lease'." \
            "Run 'git pull --rebase' to replay your ${ahead} local commit(s) cleanly on top of '${upstream}', then push." \
            "Never use 'git push --force' on shared branches as it overwrites teammates' commits on '${upstream}'."

        git_doctor_choose "How would you like to synchronize diverged branch '${current_branch}'?" \
            "[Preferred] Rebase onto upstream ('git pull --rebase')" \
            "Merge upstream into local ('git pull --no-rebase')" \
            "View commit divergence log between '${upstream}' and 'HEAD'" \
            "Force push safely with lease ('git push --force-with-lease')" \
            "Skip for now"
        case $? in
            0)
                if git pull --rebase; then
                    git_doctor_success "Rebased cleanly onto ${upstream}."
                    ((GD_ISSUES_FIXED++)) || true
                else
                    git_doctor_warn "Rebase encountered conflicts. Use Git Doctor conflict resolution to finish."
                fi
                ;;
            1)
                if git pull --no-rebase; then
                    git_doctor_success "Merged ${upstream} into ${current_branch}."
                    ((GD_ISSUES_FIXED++)) || true
                fi
                ;;
            2)
                echo -e "\n${GD_BOLD}Commits in ${upstream} not in HEAD:${GD_RESET}"
                git --no-pager log --oneline "HEAD..${upstream}"
                echo -e "\n${GD_BOLD}Commits in HEAD not in ${upstream}:${GD_RESET}"
                git --no-pager log --oneline "${upstream}..HEAD"
                ;;
            3)
                if git_doctor_confirm "Are you sure you want to overwrite '${upstream}' using '--force-with-lease'?"; then
                    git push --force-with-lease && ((GD_ISSUES_FIXED++)) || true
                fi
                ;;
        esac
    elif (( behind > 0 )); then
        git_doctor_report_issue \
            "Branch Behind Remote ('${current_branch}' is ${behind} commit(s) behind '${upstream}')" \
            "Remote branch '${upstream}' has ${behind} new commit(s) that are not in your local branch." \
            "1) Fast-forward local branch: 'git pull --ff-only'. 2) Inspect incoming commits: 'git log HEAD..${upstream}'." \
            "Run 'git pull --ff-only' to safely fast-forward your local branch." \
            "Pulling without reviewing incoming changes may introduce unexpected updates to your local environment."

        if git_doctor_confirm "Fast-forward local branch with 'git pull --ff-only'?"; then
            git pull --ff-only && {
                git_doctor_success "Fast-forwarded '${current_branch}'."
                ((GD_ISSUES_FIXED++)) || true
            }
        fi
    elif (( ahead > 0 )); then
        git_doctor_info "Branch '${current_branch}' is ${ahead} commit(s) ahead of '${upstream}' (unpushed commits)."
        if git_doctor_confirm "Would you like to push your ${ahead} local commit(s) to '${upstream}' now?"; then
            git push && git_doctor_success "Pushed '${current_branch}' to '${upstream}'."
        fi
    else
        git_doctor_success "Branch '${current_branch}' is up-to-date with '${upstream}'."
    fi
}

# ------------------------------------------------------------------------------
# Check 6: GitHub PR & Merge Diagnostics (Including GraphQL Auto-Merge Issue)
# ------------------------------------------------------------------------------
git_doctor_check_github_pr() {
    git_doctor_section "6. Pull Request & Merge Diagnostics (GitHub CLI / PR Status)"

    if ! command -v gh >/dev/null 2>&1; then
        git_doctor_info "GitHub CLI ('gh') is not installed. Skipping live GitHub PR query (use --analyze-log to diagnose PR logs)."
        return 0
    fi

    local current_branch
    current_branch="$(git symbolic-ref --quiet --short HEAD 2>/dev/null || true)"
    [[ -z "${current_branch}" ]] && return 0

    local pr_json
    pr_json="$(gh pr view "${current_branch}" --json number,state,mergeStateStatus,mergeable,baseRefName,url,title 2>/dev/null || true)"
    if [[ -z "${pr_json}" ]]; then
        git_doctor_info "No active Pull Request found for branch '${current_branch}'."
        return 0
    fi

    local pr_num pr_state pr_mergeable pr_merge_status pr_base pr_url
    if command -v jq >/dev/null 2>&1; then
        pr_num="$(echo "${pr_json}" | jq -r '.number')"
        pr_state="$(echo "${pr_json}" | jq -r '.state')"
        pr_mergeable="$(echo "${pr_json}" | jq -r '.mergeable')"
        pr_merge_status="$(echo "${pr_json}" | jq -r '.mergeStateStatus')"
        pr_base="$(echo "${pr_json}" | jq -r '.baseRefName')"
        pr_url="$(echo "${pr_json}" | jq -r '.url')"
    else
        pr_num="$(echo "${pr_json}" | sed -n 's/.*"number":\([0-9]*\).*/\1/p')"
        pr_state="$(echo "${pr_json}" | sed -n 's/.*"state":"\([^"]*\)".*/\1/p')"
        pr_mergeable="$(echo "${pr_json}" | sed -n 's/.*"mergeable":"\([^"]*\)".*/\1/p')"
        pr_merge_status="$(echo "${pr_json}" | sed -n 's/.*"mergeStateStatus":"\([^"]*\)".*/\1/p')"
        pr_base="$(echo "${pr_json}" | sed -n 's/.*"baseRefName":"\([^"]*\)".*/\1/p')"
        pr_url="$(echo "${pr_json}" | sed -n 's/.*"url":"\([^"]*\)".*/\1/p')"
    fi

    git_doctor_info "Detected PR #${pr_num} (${pr_state}) -> base '${pr_base}' | Mergeable: ${pr_mergeable} | Status: ${pr_merge_status}"

    if [[ "${pr_state}" != "OPEN" ]]; then
        git_doctor_success "PR #${pr_num} is already ${pr_state}."
        return 0
    fi

    # Check if PR has conflicts with base branch
    if [[ "${pr_mergeable}" == "CONFLICTING" || "${pr_merge_status}" == "DIRTY" ]]; then
        git_doctor_report_issue \
            "Pull Request #${pr_num} Has Merge Conflicts with Base Branch '${pr_base}'" \
            "PR #${pr_num} cannot be merged on GitHub because '${current_branch}' conflicts with '${pr_base}'." \
            "1) Fetch and merge base branch locally ('git fetch origin ${pr_base} && git merge origin/${pr_base}'), resolve conflicts, and push. 2) Rebase onto base branch ('git fetch origin ${pr_base} && git rebase origin/${pr_base}') and force-with-lease push." \
            "Fetch 'origin/${pr_base}', merge it into '${current_branch}', resolve conflicts locally, and push the resolution." \
            "Rebasing a shared PR branch requires '--force-with-lease', which rewrites commit hashes for other reviewers."

        if git_doctor_confirm "Fetch 'origin/${pr_base}' and start merging it into '${current_branch}' now?"; then
            git fetch origin "${pr_base}" && git merge "origin/${pr_base}" || git_doctor_resolve_conflicts_interactive
        fi
    fi

    # Check if repository has Auto-Merge disabled while scripts use `gh pr merge --auto`
    local auto_merge_allowed
    auto_merge_allowed="$(gh api repos/{owner}/{repo} --jq '.allow_auto_merge' 2>/dev/null || echo "unknown")"
    if [[ "${auto_merge_allowed}" == "false" ]]; then
        git_doctor_handle_automerge_disabled "${pr_num}"
    fi
}

# ------------------------------------------------------------------------------
# Dedicated Handler for GraphQL: Auto merge is not allowed (enablePullRequestAutoMerge)
# ------------------------------------------------------------------------------
git_doctor_handle_automerge_disabled() {
    local pr_num="${1:-}"

    git_doctor_report_issue \
        "GitHub Auto-Merge Disabled for Repository (GraphQL: enablePullRequestAutoMerge)" \
        "Your merge command or automation script passed the '--auto' flag (e.g. 'gh pr merge --auto'), which calls GitHub's GraphQL mutation 'enablePullRequestAutoMerge'. However, the 'Allow auto-merge' setting is disabled on this GitHub repository, causing GitHub to reject the request with: 'GraphQL: Auto merge is not allowed for this repository (enablePullRequestAutoMerge)'." \
        "1) Merge the PR directly without the '--auto' flag: 'gh pr merge ${pr_num} --merge' (or '--squash' / '--rebase').\n            2) Enable Auto-Merge on the repository so '--auto' works: 'gh repo edit --enable-auto-merge' (or in GitHub UI: Settings -> General -> Pull Requests -> Allow auto-merge).\n            3) Update your merge script to check if auto-merge is supported or fall back to direct 'gh pr merge' when '--auto' fails." \
        "If all checks have passed and the PR is ready now, merge directly without '--auto' ('gh pr merge ${pr_num} --merge'). If you rely on CI checks finishing before merge, enable auto-merge on the repo via 'gh repo edit --enable-auto-merge'." \
        "- Merging directly without '--auto' will fail if required status checks or branch protection reviews are still pending (or if you use '--admin', it will bypass branch protections entirely).\n            - Enabling auto-merge at the repository level requires Admin permissions on the GitHub repository and affects all contributors."

    git_doctor_choose "How would you like to resolve the PR #${pr_num:-<current>} Auto-Merge failure?" \
        "[Preferred - Immediate Merge] Merge PR directly now without '--auto' ('gh pr merge ${pr_num} --merge')" \
        "[Preferred - Squash Merge] Squash & merge PR directly now without '--auto' ('gh pr merge ${pr_num} --squash')" \
        "[Preferred - Repo Fix] Enable Auto-Merge on this GitHub repository ('gh repo edit --enable-auto-merge') and retry '--auto'" \
        "Skip / Do nothing now"
    local choice=$?
    case ${choice} in
        0)
            if command -v gh >/dev/null 2>&1; then
                git_doctor_info "Running: gh pr merge ${pr_num} --merge"
                if gh pr merge ${pr_num:+"${pr_num}"} --merge; then
                    git_doctor_success "PR merged successfully!"
                    ((GD_ISSUES_FIXED++)) || true
                fi
            else
                git_doctor_warn "Run manually: gh pr merge ${pr_num} --merge"
            fi
            ;;
        1)
            if command -v gh >/dev/null 2>&1; then
                git_doctor_info "Running: gh pr merge ${pr_num} --squash"
                if gh pr merge ${pr_num:+"${pr_num}"} --squash; then
                    git_doctor_success "PR squash-merged successfully!"
                    ((GD_ISSUES_FIXED++)) || true
                fi
            else
                git_doctor_warn "Run manually: gh pr merge ${pr_num} --squash"
            fi
            ;;
        2)
            if command -v gh >/dev/null 2>&1; then
                git_doctor_info "Enabling auto-merge on repository via 'gh repo edit --enable-auto-merge'..."
                if gh repo edit --enable-auto-merge; then
                    git_doctor_success "Repository auto-merge enabled! Retrying 'gh pr merge ${pr_num} --auto --merge'..."
                    gh pr merge ${pr_num:+"${pr_num}"} --auto --merge && ((GD_ISSUES_FIXED++)) || true
                else
                    git_doctor_error "Failed to enable auto-merge (check if you have Admin permissions on the repo)."
                fi
            else
                git_doctor_warn "Run manually: gh repo edit --enable-auto-merge"
            fi
            ;;
        3)
            git_doctor_info "Skipped PR merge action."
            ;;
    esac
}

# ------------------------------------------------------------------------------
# Log / Error Output Analyzer (Self-Analyzing Mode for Error Logs)
# ------------------------------------------------------------------------------
git_doctor_analyze_log() {
    local log_content="$1"

    git_doctor_section "Log / Error Output Self-Analysis"

    local matched=0

    # Pattern 1: fatal: ref refs/remotes/origin/HEAD is not a symbolic ref
    if echo "${log_content}" | grep -qE "refs/remotes/origin/HEAD is not a symbolic ref|Base branch detected:[[:space:]]*$"; then
        matched=1
        local guessed_base
        guessed_base="$(git_doctor_detect_base_branch origin 2>/dev/null || echo "main")"

        git_doctor_report_issue \
            "Missing Remote HEAD Reference ('fatal: ref refs/remotes/origin/HEAD is not a symbolic ref')" \
            "Your script tried to detect the default base branch using 'git symbolic-ref refs/remotes/origin/HEAD', which failed because 'origin/HEAD' is not set locally. As a result, 'Base branch detected:' resolved to an empty string." \
            "1) Run 'git remote set-head origin --auto' to automatically fetch and link the default branch from origin.\n            2) Or set it explicitly: 'git remote set-head origin ${guessed_base}'.\n            3) In scripts, add a fallback when symbolic-ref fails (e.g., check 'gh repo view --json defaultBranchRef' or fallback to 'main'/'master')." \
            "Run 'git remote set-head origin --auto' (or 'git remote set-head origin ${guessed_base}') so local Git knows the remote's default branch." \
            "If 'Base branch detected' is empty in an automated script, commands like 'git diff origin/\${BASE}' or 'gh pr create --base \"\${BASE}\"' can compare against the wrong ref or fail unpredictably."

        if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            if git_doctor_confirm "Fix 'refs/remotes/origin/HEAD' in this repository now?"; then
                git remote set-head origin --auto 2>/dev/null || git remote set-head origin "${guessed_base}" 2>/dev/null && {
                    git_doctor_success "Fixed refs/remotes/origin/HEAD -> $(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null)"
                    ((GD_ISSUES_FIXED++)) || true
                }
            fi
        fi
    fi

    # Pattern 2: GraphQL: Auto merge is not allowed for this repository (enablePullRequestAutoMerge)
    if echo "${log_content}" | grep -qE "enablePullRequestAutoMerge|Auto merge is not allowed for this repository"; then
        matched=1
        local pr_num
        pr_num="$(echo "${log_content}" | sed -n 's/.*Existing PR: #\([0-9][0-9]*\).*/\1/p' | head -n1)"
        git_doctor_handle_automerge_disabled "${pr_num}"
    fi

    # Pattern 3: Non-fast-forward / rejected push
    if echo "${log_content}" | grep -qE "non-fast-forward|failed to push some refs|Updates were rejected because the remote contains work"; then
        matched=1
        git_doctor_report_issue \
            "Push Rejected (Non-Fast-Forward / Remote Has New Commits)" \
            "The remote branch has commits that you do not have locally, so Git blocked the push to prevent losing remote history." \
            "1) 'git pull --rebase' then 'git push'.\n            2) 'git pull --no-rebase' (merge commit) then 'git push'.\n            3) 'git push --force-with-lease' (only if you intentionally rewrote history on your own feature branch)." \
            "Run 'git pull --rebase' to replay your local changes on top of the latest remote branch, resolve any conflicts, and then push." \
            "Using '--force' or '--force-with-lease' on a shared branch (like main/rc) will overwrite commits pushed by others."
    fi

    # Pattern 4: Merge conflict detected in log
    if echo "${log_content}" | grep -qE "CONFLICT \(content\)|Automatic merge failed; fix conflicts"; then
        matched=1
        git_doctor_report_issue \
            "Automatic Merge Failed Due to Conflicts" \
            "Git could not automatically combine changes because both branches modified the same lines in one or more files." \
            "1) Run 'git status' to list conflicted files, edit conflict markers, 'git add <file>', and 'git commit'.\n            2) Run 'git merge --abort' to undo the merge attempt." \
            "Use Git Doctor's interactive conflict resolver to inspect diffs and choose ours/theirs/manual edits per file." \
            "Committing files that still contain '<<<<<<<' markers will break your build or code syntax."
    fi

    # Pattern 5: Local changes would be overwritten by merge/checkout
    if echo "${log_content}" | grep -qE "local changes to the following files would be overwritten|Please commit your changes or stash them"; then
        matched=1
        git_doctor_report_issue \
            "Uncommitted Local Changes Blocking Checkout/Merge/Pull" \
            "You have modified files in your working directory that conflict with incoming changes from the target branch." \
            "1) Stash changes temporarily: 'git stash push -u', perform the merge/pull, then restore with 'git stash pop'.\n            2) Commit your changes first: 'git add -A && git commit'." \
            "Run 'git stash push -u' before pulling/merging, then 'git stash pop' afterwards." \
            "Running 'git reset --hard' or 'git checkout -f' will permanently destroy your uncommitted local modifications."
    fi

    # Pattern 6: GH Protected branch / Required status checks failed
    if echo "${log_content}" | grep -qE "Protected branch rules|Required status check|review is required"; then
        matched=1
        git_doctor_report_issue \
            "GitHub Branch Protection Blocking Merge" \
            "The target branch has branch protection rules requiring passing CI status checks or approving PR reviews before merging." \
            "1) Wait for CI checks to pass and request a review (`gh pr status`).\n            2) Enable auto-merge on the repo and use `gh pr merge --auto`.\n            3) Use `gh pr merge --admin` ONLY in emergencies if you have admin rights." \
            "Check PR requirements with 'gh pr checks' and wait for required checks/reviews to complete." \
            "Bypassing protections with '--admin' can merge broken code into a protected release branch."
    fi

    if (( matched == 0 )); then
        git_doctor_info "No known failure signatures matched in the provided log. Running full live repository diagnostics..."
        git_doctor_run_all_checks
    fi
}

# ------------------------------------------------------------------------------
# Interactive Branch Comparison & Diff Explorer
# ------------------------------------------------------------------------------
git_doctor_compare_branches() {
    git_doctor_section "Branch Comparison & Diff Inspector"

    local current_branch base_branch
    current_branch="$(git symbolic-ref --quiet --short HEAD 2>/dev/null || echo "HEAD")"
    base_branch="${1:-$(git_doctor_detect_base_branch origin 2>/dev/null || echo "main")}"
    local target_branch="${2:-${current_branch}}"

    # Prefer origin/<base> if local base doesn't exist
    local base_ref="${base_branch}"
    if ! git rev-parse --verify --quiet "${base_ref}" >/dev/null 2>&1; then
        if git rev-parse --verify --quiet "origin/${base_branch}" >/dev/null 2>&1; then
            base_ref="origin/${base_branch}"
        fi
    fi

    if ! git rev-parse --verify --quiet "${base_ref}" >/dev/null 2>&1; then
        git_doctor_warn "Base reference '${base_branch}' not found locally. Prompting for branch selection:"
        git branch -a
        read -r -p "Enter base branch to compare against (e.g. origin/main, main): " base_ref
    fi

    echo -e "\n${GD_BOLD}Comparing Base [${GD_CYAN}${base_ref}${GD_RESET}${GD_BOLD}] <---> Target [${GD_GREEN}${target_branch}${GD_RESET}${GD_BOLD}]${GD_RESET}"
    echo -e "${GD_DIM}------------------------------------------------------------------------------${GD_RESET}"

    local counts behind ahead
    counts="$(git rev-list --left-right --count "${base_ref}...${target_branch}" 2>/dev/null || echo "0 0")"
    behind="$(echo "${counts}" | awk '{print $1}')"
    ahead="$(echo "${counts}" | awk '{print $2}')"

    echo -e "  • Commits in ${GD_GREEN}${target_branch}${GD_RESET} not in ${GD_CYAN}${base_ref}${GD_RESET} (Ahead):  ${GD_BOLD}${ahead}${GD_RESET}"
    echo -e "  • Commits in ${GD_CYAN}${base_ref}${GD_RESET} not in ${GD_GREEN}${target_branch}${GD_RESET} (Behind): ${GD_BOLD}${behind}${GD_RESET}"

    # Check if merging base_ref into target_branch would cause conflicts (dry-run merge-tree)
    if git merge-base "${base_ref}" "${target_branch}" >/dev/null 2>&1; then
        local merge_base
        merge_base="$(git merge-base "${base_ref}" "${target_branch}")"
        local merge_tree_out
        merge_tree_out="$(git merge-tree "${merge_base}" "${target_branch}" "${base_ref}" 2>/dev/null || true)"
        if echo "${merge_tree_out}" | grep -q "<<<<<<<"; then
            echo -e "  • Merge Simulation: ${GD_RED}${GD_BOLD}CONFLICTS DETECTED if merged now!${GD_RESET}"
        else
            echo -e "  • Merge Simulation: ${GD_GREEN}${GD_BOLD}Clean merge (no conflicts predicted)${GD_RESET}"
        fi
    fi

    while true; do
        git_doctor_choose "Branch Comparison & Diff Menu (${base_ref} vs ${target_branch}):" \
            "Show summary of changed files ('git diff --stat ${base_ref}...${target_branch}')" \
            "Show commit log difference ('git log --oneline --graph --left-right ${base_ref}...${target_branch}')" \
            "Show full code diff ('git diff ${base_ref}...${target_branch}')" \
            "Diff a specific file between '${base_ref}' and '${target_branch}'" \
            "Change compared branches" \
            "Return / Exit comparison"
        case $? in
            0)
                echo ""
                git --no-pager diff --stat "${base_ref}...${target_branch}"
                ;;
            1)
                echo ""
                git --no-pager log --oneline --graph --left-right --boundary "${base_ref}...${target_branch}"
                ;;
            2)
                echo ""
                git --no-pager diff "${base_ref}...${target_branch}"
                ;;
            3)
                git --no-pager diff --name-only "${base_ref}...${target_branch}"
                local diff_file
                read -r -p "Enter file path to diff: " diff_file
                if [[ -n "${diff_file}" ]]; then
                    git --no-pager diff "${base_ref}...${target_branch}" -- "${diff_file}"
                fi
                ;;
            4)
                git branch -a
                read -r -p "Enter new base branch [${base_ref}]: " input_base
                read -r -p "Enter new target branch [${target_branch}]: " input_target
                base_ref="${input_base:-${base_ref}}"
                target_branch="${input_target:-${target_branch}}"
                ;;
            5)
                break
                ;;
        esac
    done
}

# ------------------------------------------------------------------------------
# Run All Diagnostic Checks
# ------------------------------------------------------------------------------
git_doctor_run_all_checks() {
    GD_ISSUES_FOUND=0
    GD_ISSUES_FIXED=0

    git_doctor_check_repo_and_locks || return 1
    git_doctor_check_remote_head
    git_doctor_check_state_and_conflicts
    git_doctor_check_working_tree
    git_doctor_check_upstream_and_divergence
    git_doctor_check_github_pr

    git_doctor_section "Diagnostic Summary"
    if (( GD_ISSUES_FOUND == 0 )); then
        git_doctor_success "🎉 Healthy repository! No Git issues detected."
    else
        echo -e "  • Total Issues Detected: ${GD_BOLD}${GD_YELLOW}${GD_ISSUES_FOUND}${GD_RESET}"
        echo -e "  • Total Issues Fixed:    ${GD_BOLD}${GD_GREEN}${GD_ISSUES_FIXED}${GD_RESET}"
        if (( GD_ISSUES_FOUND > GD_ISSUES_FIXED )); then
            git_doctor_warn "$((GD_ISSUES_FOUND - GD_ISSUES_FIXED)) issue(s) remain unresolved or skipped."
        else
            git_doctor_success "All detected issues have been resolved!"
        fi
    fi
}

# ------------------------------------------------------------------------------
# Interactive Main Menu
# ------------------------------------------------------------------------------
git_doctor_interactive_menu() {
    git_doctor_banner
    while true; do
        git_doctor_choose "What would you like Git Doctor to do?" \
            "Run Full Self-Analysis & Interactive Fix (Recommended)" \
            "Paste / Analyze a Failed Git or PR Log Output" \
            "Compare Branches & Inspect Diffs" \
            "Resolve Merge Conflicts Interactively" \
            "Fix Missing 'origin/HEAD' Base Branch Detection" \
            "Fix GitHub PR Merge / Auto-Merge Error" \
            "Exit Git Doctor"
        case $? in
            0)
                git_doctor_run_all_checks
                ;;
            1)
                echo -e "\n${GD_CYAN}Paste your Git/PR log below (press Ctrl+D on a new line or type 'EOF' on a new line when done):${GD_RESET}"
                local pasted_log="" line=""
                while IFS= read -r line; do
                    [[ "${line}" == "EOF" ]] && break
                    pasted_log+="${line}"$'\n'
                done
                git_doctor_analyze_log "${pasted_log}"
                ;;
            2)
                git_doctor_compare_branches
                ;;
            3)
                git_doctor_resolve_conflicts_interactive
                ;;
            4)
                git_doctor_check_remote_head
                ;;
            5)
                local pr_id
                read -r -p "Enter PR number (or press Enter to auto-detect from current branch): " pr_id
                git_doctor_handle_automerge_disabled "${pr_id}"
                ;;
            6)
                git_doctor_info "Goodbye! Happy coding."
                break
                ;;
        esac
    done
}

# ------------------------------------------------------------------------------
# CLI Usage / Help
# ------------------------------------------------------------------------------
git_doctor_usage() {
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [OPTIONS]

Self-analyzing, interactive Git diagnostic, diff, and repair utility.

Options:
  -c, --check                  Run full repository diagnostics and interactive fixer
  -i, --interactive            Launch interactive Git Doctor main menu (default if no args)
  -l, --analyze-log <file|->   Analyze a Git/PR error log file (or '-' for stdin) and suggest fixes
  -d, --compare [base] [head]  Compare branches, simulate merges, and inspect diffs interactively
  -r, --resolve-conflicts      Launch interactive merge conflict resolver
  -y, --yes                    Auto-apply preferred safe fixes without prompting
  -h, --help                   Show this help message and exit

Examples:
  ./scripts/lib/git/git-doctor.sh
  ./scripts/lib/git/git-doctor.sh --check
  ./scripts/lib/git/git-doctor.sh --compare main rc
  ./scripts/lib/git/git-doctor.sh --analyze-log merge_error.log
  cat merge_error.log | ./scripts/lib/git/git-doctor.sh --analyze-log -
EOF
}

# ------------------------------------------------------------------------------
# Main Entrypoint Function (Callable when sourced or executed directly)
# ------------------------------------------------------------------------------
git_doctor_run() {
    if [[ $# -eq 0 ]]; then
        # If stdin is piped, analyze stdin log automatically
        if [[ ! -t 0 ]]; then
            local stdin_log
            stdin_log="$(cat)"
            git_doctor_banner
            git_doctor_analyze_log "${stdin_log}"
            return 0
        fi
        git_doctor_interactive_menu
        return 0
    fi

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -c|--check)
                git_doctor_banner
                git_doctor_run_all_checks
                shift
                ;;
            -i|--interactive)
                git_doctor_interactive_menu
                shift
                ;;
            -l|--analyze-log)
                shift
                if [[ -z "${1:-}" ]]; then
                    git_doctor_error "Missing argument for --analyze-log (provide a file path, '-' for stdin, or raw log text)."
                    return 1
                fi
                git_doctor_banner
                if [[ "$1" == "-" ]]; then
                    git_doctor_analyze_log "$(cat)"
                elif [[ -f "$1" ]]; then
                    git_doctor_analyze_log "$(cat "$1")"
                else
                    git_doctor_analyze_log "$1"
                fi
                shift
                ;;
            -d|--compare|--diff)
                shift
                local base_arg="${1:-}"
                local target_arg="${2:-}"
                [[ -n "${base_arg}" ]] && shift
                [[ -n "${target_arg}" ]] && shift
                git_doctor_banner
                git_doctor_compare_branches "${base_arg}" "${target_arg}"
                ;;
            -r|--resolve-conflicts)
                git_doctor_banner
                git_doctor_resolve_conflicts_interactive
                shift
                ;;
            -y|--yes)
                GD_AUTO_MODE=true
                shift
                ;;
            -h|--help)
                git_doctor_usage
                return 0
                ;;
            *)
                git_doctor_error "Unknown option: $1"
                git_doctor_usage
                return 1
                ;;
        esac
    done
}

# Execute if run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    git_doctor_run "$@"
fi
