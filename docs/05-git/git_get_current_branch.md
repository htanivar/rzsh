# `git_get_current_branch`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../05-git.md) › [Function Index](README.md) › **`git_get_current_branch`** › [Runnable Example](../../examples/05_git_example.sh) › [Tests](../../tests/05-git.test.sh)

- **Source:** [`functions/05-git.sh#L26-L28`](../../functions/05-git.sh#L26-L28)
- **Signature:** `git_get_current_branch`
- **Description:** Outputs the name of the current Git branch.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| — | None |

## Return / Exit Value

- {string} The active branch name.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local branch
  branch=$(git_get_current_branch)
```

---

See also the full runnable example script: [`examples/05_git_example.sh`](../../examples/05_git_example.sh).
