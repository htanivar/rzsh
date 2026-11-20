# `git_get_commit_message`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../05-git.md) › [Function Index](README.md) › **`git_get_commit_message`** › [Runnable Example](../../examples/05_git_example.sh) › [Tests](../../tests/05-git.test.sh)

- **Source:** [`functions/05-git.sh#L184-L187`](../../functions/05-git.sh#L184-L187)
- **Signature:** `git_get_commit_message [hash=HEAD]`
- **Description:** Returns the subject line of the commit message for the specified commit hash.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `[hash=HEAD]` (`string`) | The commit hash. |

## Return / Exit Value

- {string} The commit subject message.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local msg
  msg=$(git_get_commit_message "f3c8b90")
```

---

See also the full runnable example script: [`examples/05_git_example.sh`](../../examples/05_git_example.sh).
