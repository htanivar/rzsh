# `git_branch_exists`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../05-git.md) › [Function Index](README.md) › **`git_branch_exists`** › [Runnable Example](../../examples/05_git_example.sh) › [Tests](../../tests/05-git.test.sh)

- **Source:** [`functions/05-git.sh#L154-L160`](../../functions/05-git.sh#L154-L160)
- **Signature:** `git_branch_exists <branch>`
- **Description:** Checks if a branch exists locally or on the remote origin.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `branch` (`string`) | The branch name to verify. |

## Return / Exit Value

- {number} 0 if exists, 1 otherwise.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  if git_branch_exists "main"; then
    echo "Main branch exists"
  fi
```

---

See also the full runnable example script: [`examples/05_git_example.sh`](../../examples/05_git_example.sh).
