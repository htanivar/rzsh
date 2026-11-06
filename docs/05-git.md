# Git Operations Module Reference

- **Source File:** [`functions/05-git.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/05-git.sh)
- **Description:** Git repository operations and commit meta metrics.

---

## Detailed Usage Examples

### Integration Setup
To use the Git Operations module, source the configuration script via `RZSH_DIR`, which automatically imports it:

```zsh
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
* **Description:** Stages all tracked modifications (`git add -u`) and commits them with the given message.

#### Example Code:
```zsh
git_commit "feat: add user auth"
```

---
### `git_push / git_pull / git_safe_pull`

* **Signature:** `git_push [remote] [branch]` / `git_pull [remote] [branch]` / `git_safe_pull [remote] [branch]`
* **Description:** Pushes or pulls changes from a remote branch. `git_safe_pull` ensures the working tree is clean before pulling with `--ff-only`.

#### Example Code:
```zsh
git_safe_pull "origin" "main"
git_push "origin" "main"
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

* **Signature:** `git_get_commit_hash [short=0]` / `git_get_commit_message [commit_ref="HEAD"]`
* **Description:** Outputs the SHA-1 commit hash (full or short) or the commit message for a commit reference.

#### Example Code:
```zsh
local head_sha=$(git_get_commit_hash)
local head_msg=$(git_get_commit_message "HEAD")
```

---
### `git_compare_branches`

* **Signature:** `git_compare_branches [options] [<branch_a>] [<branch_b>]`
* **Description:** Compares two git branches, outputs a structured summary, and optionally writes a Markdown report.

#### Options:
* `-h, --help`: Show help message.
* `-o, --output <file>`: Write the Markdown report to a specific file.
* `-s, --silent`: Do not output details to stdout.

#### Example Code:
```zsh
git_compare_branches --silent --output "./report.md" main feature
```

---

