# Git Operations Module Reference

- **Source File:** [`functions/05-git.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/05-git.sh)
- **Description:** Git repository operations and commit meta metrics.

---

## Detailed Usage Examples

### Integration Setup
To use the Git Operations module, you only need to source the configuration script, which automatically imports it:

```zsh
source ./config/config.sh
init_config
```

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
* **Description:** Stages all changes and commits them, returning the commit hash.

#### Example Code:
```zsh
git_commit "feat: add user auth"
```

---
### `git_branch_exists`

* **Signature:** `git_branch_exists <branch_name>`
* **Description:** Checks if the specified branch name exists in local or remote tracking.

#### Example Code:
```zsh
git_branch_exists "main"
```

---
### `git_get_commit_hash`

* **Signature:** `git_get_commit_hash [ref]`
* **Description:** Outputs the full 40-character SHA-1 commit hash of the specified ref (default: HEAD).

#### Example Code:
```zsh
local head_sha=$(git_get_commit_hash)
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

