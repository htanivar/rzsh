# `git_safe_pull`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../05-git.md) › [Function Index](README.md) › **`git_safe_pull`** › [Runnable Example](../../examples/05_git_example.sh) › [Tests](../../tests/05-git.test.sh)

- **Source:** [`functions/05-git.sh#L127-L142`](../../functions/05-git.sh#L127-L142)
- **Signature:** `git_safe_pull`
- **Description:** Safely pulls changes by stashing local changes, pulling, and then popping the stash.

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

- {number} Exit code of the pull command.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  git_safe_pull
```

---

See also the full runnable example script: [`examples/05_git_example.sh`](../../examples/05_git_example.sh).
