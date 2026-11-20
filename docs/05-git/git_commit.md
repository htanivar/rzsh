# `git_commit`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../05-git.md) › [Function Index](README.md) › **`git_commit`** › [Runnable Example](../../examples/05_git_example.sh) › [Tests](../../tests/05-git.test.sh)

- **Source:** [`functions/05-git.sh#L77-L83`](../../functions/05-git.sh#L77-L83)
- **Signature:** `git_commit <message>`
- **Description:** Stages all changes and commits them with the given message.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `message` (`string`) | Commit message. |

## Return / Exit Value

- {number} 0 on success, or non-zero on failure.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  git_commit "fix: update configurations"
```

---

See also the full runnable example script: [`examples/05_git_example.sh`](../../examples/05_git_example.sh).
