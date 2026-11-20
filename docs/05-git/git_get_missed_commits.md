# `git_get_missed_commits`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../05-git.md) › [Function Index](README.md) › **`git_get_missed_commits`** › [Runnable Example](../../examples/05_git_example.sh) › [Tests](../../tests/05-git.test.sh)

- **Source:** [`functions/05-git.sh#L669-L689`](../../functions/05-git.sh#L669-L689)
- **Signature:** `git_get_missed_commits <target_branch> <source_branch>`
- **Description:** Outputs SHAs of commits in source_branch that have not been backported to target_branch.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `target_branch` (`string`) | Target/default branch (e.g., develop). |
| `source_branch` (`string`) | Source/release branch (e.g., release/1.0.0). |

## Return / Exit Value

- {string} Newline-separated list of missed commit SHAs.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
git_get_missed_commits <target_branch> <source_branch>
```

---

See also the full runnable example script: [`examples/05_git_example.sh`](../../examples/05_git_example.sh).
