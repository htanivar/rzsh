# `git_get_root`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../05-git.md) › [Function Index](README.md) › **`git_get_root`** › [Runnable Example](../../examples/05_git_example.sh) › [Tests](../../tests/05-git.test.sh)

- **Source:** [`functions/05-git.sh#L53-L55`](../../functions/05-git.sh#L53-L55)
- **Signature:** `git_get_root`
- **Description:** Returns the absolute path of the root directory of the current Git repository.

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

- {string} The absolute path of Git root.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local git_root
  git_root=$(git_get_root)
```

---

See also the full runnable example script: [`examples/05_git_example.sh`](../../examples/05_git_example.sh).
