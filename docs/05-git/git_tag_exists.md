# `git_tag_exists`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../05-git.md) › [Function Index](README.md) › **`git_tag_exists`** › [Runnable Example](../../examples/05_git_example.sh) › [Tests](../../tests/05-git.test.sh)

- **Source:** [`functions/05-git.sh#L1211-L1215`](../../functions/05-git.sh#L1211-L1215)
- **Signature:** `git_tag_exists <tag>`
- **Description:** Checks if a Git tag exists in the repository.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `tag` (`string`) | The tag name to verify. |

## Return / Exit Value

- {number} 0 if exists, 1 otherwise.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
if git_tag_exists "v1.0.0"; then
  echo "Tag v1.0.0 exists"
fi
```

---

See also the full runnable example script: [`examples/05_git_example.sh`](../../examples/05_git_example.sh).
