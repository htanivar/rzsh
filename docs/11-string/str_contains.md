# `str_contains`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../11-string.md) › [Function Index](README.md) › **`str_contains`** › [Runnable Example](../../examples/11_string_example.sh) › [Tests](../../tests/11-string.test.sh)

- **Source:** [`functions/11-string.sh#L25-L32`](../../functions/11-string.sh#L25-L32)
- **Signature:** `str_contains <str> <substr>`
- **Description:** Checks if a substring is contained within a string.

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
| `substr` (`string`) | The substring to search for. |

## Return / Exit Value

- {number} 0 if contained, 1 otherwise.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  if str_contains "hello world" "world"; then
    echo "Found"
  fi
```

---

See also the full runnable example script: [`examples/11_string_example.sh`](../../examples/11_string_example.sh).
