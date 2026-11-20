# `git_report_missed_commits`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../05-git.md) › [Function Index](README.md) › **`git_report_missed_commits`** › [Runnable Example](../../examples/05_git_example.sh) › [Tests](../../tests/05-git.test.sh)

- **Source:** [`functions/05-git.sh#L734-L787`](../../functions/05-git.sh#L734-L787)
- **Signature:** `git_report_missed_commits <target_branch> <release_branch> [output_file] [silent_mode=0]`
- **Description:** Prints (and optionally writes to Markdown) commits in release_branch missing from target_branch.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `target_branch` (`string`) | Target/default branch. |
| `release_branch` (`string`) | Release branch to check. |
| `[output_file]` (`string`) | Optional Markdown report path. |
| `[silent_mode=0]` (`number`) | 1 to suppress stdout. |

## Return / Exit Value

- {number} 0 on success, 1 on invalid branch.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
git_report_missed_commits <target_branch> <release_branch> [output_file] [silent_mode=0]
```

---

See also the full runnable example script: [`examples/05_git_example.sh`](../../examples/05_git_example.sh).
