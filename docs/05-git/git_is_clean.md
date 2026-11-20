# `git_is_clean`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../05-git.md) › [Function Index](README.md) › **`git_is_clean`** › [Runnable Example](../../examples/05_git_example.sh) › [Tests](../../tests/05-git.test.sh)

- **Source:** [`functions/05-git.sh#L40-L42`](../../functions/05-git.sh#L40-L42)
- **Signature:** `git_is_clean`
- **Description:** Checks if the working tree has no uncommitted changes (both tracked and untracked).

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

- {number} 0 if clean, 1 if dirty.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  if git_is_clean; then
    echo "Working tree clean"
  fi
```

---

See also the full runnable example script: [`examples/05_git_example.sh`](../../examples/05_git_example.sh).
