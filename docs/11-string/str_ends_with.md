# `str_ends_with`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../11-string.md) › [Function Index](README.md) › **`str_ends_with`** › [Runnable Example](../../examples/11_string_example.sh) › [Tests](../../tests/11-string.test.sh)

- **Source:** [`functions/11-string.sh#L65-L72`](../../functions/11-string.sh#L65-L72)
- **Signature:** `str_ends_with <str> <suffix>`
- **Description:** Checks if a string ends with a specified suffix.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `str` (`string`) | The main string. |
| `suffix` (`string`) | The suffix. |

## Return / Exit Value

- {number} 0 if matches, 1 otherwise.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  if str_ends_with "file.txt" ".txt"; then
    echo "Matches"
  fi
```

---

See also the full runnable example script: [`examples/11_string_example.sh`](../../examples/11_string_example.sh).
