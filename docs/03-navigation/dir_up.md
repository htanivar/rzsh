# `dir_up`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../03-navigation.md) › [Function Index](README.md) › **`dir_up`** › [Runnable Example](../../examples/03_navigation_example.sh) › [Tests](../../tests/03-navigation.test.sh)

- **Source:** [`functions/03-navigation.sh#L36-L44`](../../functions/03-navigation.sh#L36-L44)
- **Signature:** `dir_up [n=1]`
- **Description:** Returns the path resulting from moving up 'n' directories from the current directory.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `[n=1]` (`number`) | The number of directories to move up. |

## Return / Exit Value

- {string} The resolved directory path.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local parent
  parent=$(dir_up 2)
```

---

See also the full runnable example script: [`examples/03_navigation_example.sh`](../../examples/03_navigation_example.sh).
