# `is_inside_git_repo`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../03-navigation.md) › [Function Index](README.md) › **`is_inside_git_repo`** › [Runnable Example](../../examples/03_navigation_example.sh) › [Tests](../../tests/03-navigation.test.sh)

- **Source:** [`functions/03-navigation.sh#L108-L113`](../../functions/03-navigation.sh#L108-L113)
- **Signature:** `is_inside_git_repo`
- **Description:** Checks if the current directory is inside a Git repository.

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

- {number} 0 if inside a Git repository, 1 otherwise.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  if is_inside_git_repo; then
    echo "Inside Git"
  fi
```

---

See also the full runnable example script: [`examples/03_navigation_example.sh`](../../examples/03_navigation_example.sh).
