# `git_get_commit_hash`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../05-git.md) › [Function Index](README.md) › **`git_get_commit_hash`** › [Runnable Example](../../examples/05_git_example.sh) › [Tests](../../tests/05-git.test.sh)

- **Source:** [`functions/05-git.sh#L171-L173`](../../functions/05-git.sh#L171-L173)
- **Signature:** `git_get_commit_hash`
- **Description:** Returns the full SHA-1 hash of the current HEAD commit.

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

- {string} The commit hash.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local commit
  commit=$(git_get_commit_hash)
```

---

See also the full runnable example script: [`examples/05_git_example.sh`](../../examples/05_git_example.sh).
