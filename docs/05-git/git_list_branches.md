# `git_list_branches`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../05-git.md) › [Function Index](README.md) › **`git_list_branches`** › [Runnable Example](../../examples/05_git_example.sh) › [Tests](../../tests/05-git.test.sh)

- **Source:** [`functions/05-git.sh#L645-L660`](../../functions/05-git.sh#L645-L660)
- **Signature:** `git_list_branches [pattern]`
- **Description:** Lists unique local and origin branch names, optionally filtered by a glob pattern.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `[pattern]` (`string`) | Optional glob pattern (e.g., "release/*"). |

## Return / Exit Value

- {string} Newline-separated list of branch names.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
git_list_branches [pattern]
```

---

See also the full runnable example script: [`examples/05_git_example.sh`](../../examples/05_git_example.sh).
