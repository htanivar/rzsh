# `ensure_directory_exists`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../03-navigation.md) › [Function Index](README.md) › **`ensure_directory_exists`** › [Runnable Example](../../examples/03_navigation_example.sh) › [Tests](../../tests/03-navigation.test.sh)

- **Source:** [`functions/03-navigation.sh#L137-L143`](../../functions/03-navigation.sh#L137-L143)
- **Signature:** `ensure_directory_exists <path>`
- **Description:** Creates the specified directory and any parent directories if they do not exist.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `path` (`string`) | The directory path to ensure exists. |

## Return / Exit Value

- {number} 0 on success, or 1 on failure.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  ensure_directory_exists "/tmp/my_app/logs"
```

---

See also the full runnable example script: [`examples/03_navigation_example.sh`](../../examples/03_navigation_example.sh).
