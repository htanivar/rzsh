# `str_join`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../11-string.md) › [Function Index](README.md) › **`str_join`** › [Runnable Example](../../examples/11_string_example.sh) › [Tests](../../tests/11-string.test.sh)

- **Source:** [`functions/11-string.sh#L189-L196`](../../functions/11-string.sh#L189-L196)
- **Signature:** `str_join <delimiter> <args>`
- **Description:** Joins an array of strings or multiple arguments with the specified delimiter.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `delimiter` (`string`) | The joining string. |
| `args` (`string[]`) | The values to join. |

## Return / Exit Value

- {string} The joined string.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local res
  res=$(str_join "-" "a" "b" "c")
```

---

See also the full runnable example script: [`examples/11_string_example.sh`](../../examples/11_string_example.sh).
