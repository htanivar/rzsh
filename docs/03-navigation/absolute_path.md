# `absolute_path`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../03-navigation.md) › [Function Index](README.md) › **`absolute_path`** › [Runnable Example](../../examples/03_navigation_example.sh) › [Tests](../../tests/03-navigation.test.sh)

- **Source:** [`functions/03-navigation.sh#L55-L58`](../../functions/03-navigation.sh#L55-L58)
- **Signature:** `absolute_path <relative_path>`
- **Description:** Converts a relative path into an absolute path using Zsh modifiers.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `relative_path` (`string`) | The relative path to resolve. |

## Return / Exit Value

- {string} The absolute path.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local abs
  abs=$(absolute_path "./config")
```

---

See also the full runnable example script: [`examples/03_navigation_example.sh`](../../examples/03_navigation_example.sh).
