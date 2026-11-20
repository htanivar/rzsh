# `git_format_commit`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../05-git.md) › [Function Index](README.md) › **`git_format_commit`** › [Runnable Example](../../examples/05_git_example.sh) › [Tests](../../tests/05-git.test.sh)

- **Source:** [`functions/05-git.sh#L697-L700`](../../functions/05-git.sh#L697-L700)
- **Signature:** `git_format_commit [commit_hash=HEAD]`
- **Description:** Formats a commit as "<short_hash> | <date> | <author> | <subject>".

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `[commit_hash=HEAD]` (`string`) | Commit hash. |

## Return / Exit Value

- {string} Formatted commit summary line.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
git_format_commit [commit_hash=HEAD]
```

---

See also the full runnable example script: [`examples/05_git_example.sh`](../../examples/05_git_example.sh).
