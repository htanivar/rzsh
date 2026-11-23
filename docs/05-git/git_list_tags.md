# `git_list_tags`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../05-git.md) › [Function Index](README.md) › **`git_list_tags`** › [Runnable Example](../../examples/05_git_example.sh) › [Tests](../../tests/05-git.test.sh)

- **Source:** [`functions/05-git.sh#L1223-L1230`](../../functions/05-git.sh#L1223-L1230)
- **Signature:** `git_list_tags [pattern]`
- **Description:** Lists Git tags sorted by creator date (newest first), optionally filtered by a glob pattern.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `[pattern]` (`string`) | Optional glob pattern (e.g., `"v1.*"`). |

## Return / Exit Value

- {string} Newline-separated list of tag names.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
git_list_tags
git_list_tags "v1.*"
```

---

See also the full runnable example script: [`examples/05_git_example.sh`](../../examples/05_git_example.sh).
