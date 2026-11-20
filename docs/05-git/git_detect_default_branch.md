# `git_detect_default_branch`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../05-git.md) › [Function Index](README.md) › **`git_detect_default_branch`** › [Runnable Example](../../examples/05_git_example.sh) › [Tests](../../tests/05-git.test.sh)

- **Source:** [`functions/05-git.sh#L597-L617`](../../functions/05-git.sh#L597-L617)
- **Signature:** `git_detect_default_branch`
- **Description:** Detects the repository's default branch (origin/HEAD, develop, main, or master).

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

- {string} Outputs the detected default branch name, or returns 1 if none found.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local default_branch
  default_branch=$(git_detect_default_branch)
```

---

See also the full runnable example script: [`examples/05_git_example.sh`](../../examples/05_git_example.sh).
