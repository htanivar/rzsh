# Git Operations Module Reference

**Navigation:** [README](../README.md) › [GLOSSARY](../GLOSSARY.md) › **05-git.md** › [Example](../examples/05_git_example.sh) › [Tests](../tests/05-git.test.sh)

- **Source File:** [`functions/05-git.sh`](../functions/05-git.sh)
- **Example Script:** [`examples/05_git_example.sh`](../examples/05_git_example.sh)
- **Description:** Git repository operations and commit meta metrics.

---

## Index

- [Detailed Usage Examples](#detailed-usage-examples)
  - [Integration Setup](#integration-setup)
  - [Copy-Paste Script Boilerplate](#copy-paste-script-boilerplate)
- [Module Variables (Keys)](#module-variables-keys)
- [Function Signatures & Descriptions](#function-signatures--descriptions)
  - **Repository & Status**
    - [`git_get_current_branch`](#git_get_current_branch)
    - [`git_is_clean`](#git_is_clean)
    - [`git_get_root`](#git_get_root)
    - [`git_status_message`](#git_status_message)
  - **Commit & Remote Sync**
    - [`git_commit`](#git_commit)
    - [`git_push` / `git_pull` / `git_safe_pull`](#git_push--git_pull--git_safe_pull)
  - **Branches & Refs**
    - [`git_branch_exists`](#git_branch_exists)
    - [`git_detect_default_branch`](#git_detect_default_branch)
    - [`git_resolve_ref`](#git_resolve_ref)
    - [`git_list_branches`](#git_list_branches)
    - [`git_pick_branch`](#git_pick_branch)
  - **Commits & Formatting**
    - [`git_get_commit_hash` / `git_get_commit_message`](#git_get_commit_hash--git_get_commit_message)
    - [`git_format_commit`](#git_format_commit)
  - **Comparison & Backport Reports**
    - [`git_get_missed_commits`](#git_get_missed_commits)
    - [`git_report_missed_commits`](#git_report_missed_commits)
    - [`git_compare_branches`](#git_compare_branches)

---

## Detailed Usage Examples

### Integration Setup
To use the Git Operations module, source the configuration script via `RZSH_DIR`, which automatically imports it:

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

#### Copy-Paste Script Boilerplate
Use this minimal header when creating a new standalone script:

```zsh
#!/usr/bin/env zsh
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

if [[ -z "${RZSH_DIR:-}" ]]; then
  printf '[WARN] RZSH_DIR is not set. Falling back to script parent.\n' >&2
  export RZSH_DIR="${0:A:h:h}"
fi

source "${RZSH_DIR}/config/config.sh"
init_config
```

---

## Module Variables (Keys)

| Variable Key | Description |
| :--- | :--- |
| `GIT_IGNORE_FOLDERS` | Comma-separated list of folder names excluded during `git_compare_branches`. |

---

## Function Signatures & Descriptions

### `git_get_current_branch`

* **Signature:** `git_get_current_branch`
* **Description:** Outputs the name of the active branch in the current directory.

#### Example Code:
```zsh
local branch=$(git_get_current_branch)
```

---
### `git_is_clean`

* **Signature:** `git_is_clean`
* **Description:** Returns 0 if there are no uncommitted modifications or untracked files.

#### Example Code:
```zsh
git_is_clean || echo "Repository is dirty"
```

---
### `git_get_root`

* **Signature:** `git_get_root`
* **Description:** Outputs the absolute root path of the current Git working tree.

#### Example Code:
```zsh
local git_root=$(git_get_root)
```

---
### `git_status_message`

* **Signature:** `git_status_message`
* **Description:** Outputs a brief summary of uncommitted changes (number of staged, modified, untracked files).

#### Example Code:
```zsh
git_status_message
```

---
### `git_commit`

* **Signature:** `git_commit <commit_message>`
* **Description:** Stages all changes (`git add -A`) and commits them with the given message. Returns `1` if the commit message is empty.

#### Example Code:
```zsh
if ! git_is_clean; then
  git_commit "feat: add user auth" || log_error "Commit failed"
fi
```

---
### `git_push / git_pull / git_safe_pull`

* **Signature:** `git_push` / `git_pull` / `git_safe_pull`
* **Description:** Pushes or pulls changes for the current branch on `origin`. `git_safe_pull` stashes any local uncommitted changes (`git stash -u`), pulls from `origin`, and pops the stash afterward.

#### Example Code:
```zsh
# Safely pull latest changes even with local edits
git_safe_pull || error_exit "Failed to pull latest changes"

# Standard pull / push for the current branch
git_pull
git_push
```

---
### `git_branch_exists`

* **Signature:** `git_branch_exists <branch_name>`
* **Description:** Checks if the specified branch name exists locally or on `origin`.

#### Example Code:
```zsh
git_branch_exists "main"
```

---
### `git_get_commit_hash / git_get_commit_message`

* **Signature:** `git_get_commit_hash` / `git_get_commit_message [commit_ref="HEAD"]`
* **Description:** Outputs the full SHA-1 commit hash of `HEAD`, or the subject line of the commit message for a commit reference.

#### Example Code:
```zsh
local head_sha=$(git_get_commit_hash)
local head_msg=$(git_get_commit_message "HEAD")
echo "${head_sha}: ${head_msg}"
```

---
### `git_format_commit`

* **Signature:** `git_format_commit [commit_hash="HEAD"]`
* **Description:** Formats a commit as `<short_hash> | <date> | <author> | <subject>`.

#### Example Code:
```zsh
local summary
summary=$(git_format_commit "HEAD")
echo "Latest commit: ${summary}"
```

---
### `git_detect_default_branch`

* **Signature:** `git_detect_default_branch`
* **Description:** Detects the repository's default branch by checking `origin/HEAD`, then `develop`, `main`, and `master` in order. Outputs the branch name or returns `1` if none are found.

#### Example Code:
```zsh
local default_branch
default_branch=$(git_detect_default_branch) || error_exit "No default branch found"
echo "Default branch: ${default_branch}"
```

---
### `git_resolve_ref`

* **Signature:** `git_resolve_ref <branch>`
* **Description:** Resolves a branch name to its local ref (`<branch>`) if present, otherwise to `origin/<branch>` if it exists on the remote (falls back to `<branch>`). Returns `1` if no branch name is provided.

#### Example Code:
```zsh
local ref
ref=$(git_resolve_ref "main")
git log -n 5 --oneline "${ref}"
```

---
### `git_list_branches`

* **Signature:** `git_list_branches [pattern]`
* **Description:** Lists unique local and `origin` branch names (one per line), optionally filtered by a glob pattern (e.g., `release/*`).

#### Example Code:
```zsh
# List all branches
git_list_branches

# List and iterate over release branches
local -a release_branches
release_branches=( ${(f)"$(git_list_branches 'release/*')"} )
for b in "${release_branches[@]}"; do
  echo "Release branch: ${b}"
done
```

---
### `git_pick_branch`

* **Signature:** `git_pick_branch <prompt> [pattern]`
* **Description:** Interactively prompts the user to select a branch (optionally filtered by `[pattern]`, falling back to all branches if none match, or `read_input` if no branches exist). Requires `functions/07-user-actions.sh` (loaded automatically by `init_config`).

#### Example Code:
```zsh
local target_branch
target_branch=$(git_pick_branch "Select a release branch" "release/*")
echo "Selected branch: ${target_branch}"
```

---
### `git_get_missed_commits`

* **Signature:** `git_get_missed_commits <target_branch> <source_branch>`
* **Description:** Outputs the SHAs of commits in `<source_branch>` that have not yet been backported/applied to `<target_branch>` (patch-id aware via `git cherry -v`).

#### Example Code:
```zsh
local -a missed_shas
missed_shas=( ${(f)"$(git_get_missed_commits "develop" "release/1.0.0")"} )
for sha in "${missed_shas[@]}"; do
  [[ -z "${sha}" ]] && continue
  echo "Missing: $(git_format_commit "${sha}")"
done
```

---
### `git_report_missed_commits`

* **Signature:** `git_report_missed_commits <target_branch> <release_branch> [output_file] [silent_mode=0]`
* **Description:** Highlights commits in `<release_branch>` that are missing from `<target_branch>`, prints a colorized summary to stdout (unless `silent_mode=1`), and optionally writes a Markdown report to `[output_file]`. Returns `1` if either branch does not exist.

#### Example Code:
```zsh
# Print to terminal and save a Markdown report
git_report_missed_commits "develop" "release/1.0.0" "${PROJECT_ROOT}/logs/backport_report.md"

# Silent mode (file output only)
git_report_missed_commits "develop" "release/1.0.0" "${PROJECT_ROOT}/logs/backport_report.md" 1
```

---
### `git_compare_branches`

* **Signature:** `git_compare_branches [options] [<branch_a>] [<branch_b>]`
* **Description:** Compares two git branches (honoring `GIT_IGNORE_FOLDERS`), outputs a structured summary, and writes a Markdown report (to `--output <file>` or `${PROJECT_ROOT}/evidence/branch_comparison_<timestamp>/comparison_report.md` by default).

#### Options:
* `-h, --help`: Show help message.
* `-o, --output <file>`: Write the Markdown report to a specific file.
* `-s, --silent`: Do not output details to stdout.

#### Example Code:
```zsh
# Compare two explicit branches and save report silently
git_compare_branches --silent --output "./report.md" main feature

# Compare default branch (main/master) against current branch
git_compare_branches
```

---
### `git_compare_three_branches`

* **Signature:** `git_compare_three_branches [options] <release_x> <release_prev> [<default_branch>]`
* **Description:** Compares two release branches (`<release_x>` and `<release_prev>`) against a default branch (`<default_branch>`, auto-detected via `git_detect_default_branch` if omitted) to find missing commits (`git_get_missed_commits`) and content differences (`git_compare_branches` + per-commit diffs) across all three links:
  1. `<release_x> -> <default_branch>`
  2. `<release_prev> -> <default_branch>`
  3. `<release_prev> -> <release_x>`
  Outputs a colorized terminal summary (unless `--silent`) and writes a unified Markdown report (to `--output <file>` or `${PROJECT_ROOT}/evidence/three_branch_comparison_<timestamp>/three_branch_report.md` by default).

#### Options:
* `-h, --help`: Show help message.
* `-o, --output <file>`: Write the Markdown report to a specific file.
* `-s, --silent`: Do not output details to stdout.

#### Example Code:
```zsh
# Compare release/2.2.0 and release/2.1.0 against develop
git_compare_three_branches --output "./three_branch_report.md" release/2.2.0 release/2.1.0 develop

# Auto-detect default branch and run silently
git_compare_three_branches --silent --output "./three_branch_report.md" release/2.2.0 release/2.1.0
```

---
### `git_compare_commits`

* **Signature:** `git_compare_commits [options] <ref1> [<ref2>]`
* **Description:** Compares two Git commits, tags, or branch refs (defaulting `<ref2>` to `HEAD` when omitted) and generates a Markdown report with commit metadata, commits ahead/behind, `--name-status` changed files, `--stat` summary, and optional unified patch diff.

#### Options:
* `-h, --help`: Show help message.
* `-o, --output <file>`: Write the Markdown comparison report to `<file>`.
* `-s, --silent`: Suppress stdout output (still writes to `-o` if specified).
* `--diff`: Include full unified patch diff in the report.

#### Example Code:
```zsh
# Compare HEAD~3 against HEAD with full patch diff
git_compare_commits --diff -o "./commit_report.md" HEAD~3 HEAD

# Compare a tag against current HEAD
git_compare_commits v1.0.0
```

---

