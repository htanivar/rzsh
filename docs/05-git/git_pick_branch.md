# `git_pick_branch`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../05-git.md) › [Function Index](README.md) › **`git_pick_branch`** › [Runnable Example](../../examples/05_git_example.sh) › [Tests](../../tests/05-git.test.sh)

- **Source:** [`functions/05-git.sh#L709-L723`](../../functions/05-git.sh#L709-L723)
- **Signature:** `git_pick_branch <prompt> [pattern]`
- **Description:** Prompts the user to select a branch (optionally filtered by pattern, falling back to all branches).

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `prompt` (`string`) | Prompt message. |
| `[pattern]` (`string`) | Optional glob pattern (e.g., "release/*"). |

## Return / Exit Value

- {string} Selected branch name.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
git_pick_branch <prompt> [pattern]
```

---

See also the full runnable example script: [`examples/05_git_example.sh`](../../examples/05_git_example.sh).
