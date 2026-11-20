# `git_resolve_ref`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../05-git.md) › [Function Index](README.md) › **`git_resolve_ref`** › [Runnable Example](../../examples/05_git_example.sh) › [Tests](../../tests/05-git.test.sh)

- **Source:** [`functions/05-git.sh#L625-L637`](../../functions/05-git.sh#L625-L637)
- **Signature:** `git_resolve_ref <branch>`
- **Description:** Resolves a branch name to a local ref or origin remote ref.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `branch` (`string`) | Branch name to resolve. |

## Return / Exit Value

- {string} Resolved ref name.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
git_resolve_ref <branch>
```

---

See also the full runnable example script: [`examples/05_git_example.sh`](../../examples/05_git_example.sh).
