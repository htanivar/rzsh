# `str_trim`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../11-string.md) › [Function Index](README.md) › **`str_trim`** › [Runnable Example](../../examples/11_string_example.sh) › [Tests](../../tests/11-string.test.sh)

- **Source:** [`functions/11-string.sh#L119-L125`](../../functions/11-string.sh#L119-L125)
- **Signature:** `str_trim <str>`
- **Description:** Trims leading and trailing whitespace from a string.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `str` (`string`) | The string to trim. |

## Return / Exit Value

- {string} The trimmed string.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local res
  res=$(str_trim "   hello   ")
```

---

See also the full runnable example script: [`examples/11_string_example.sh`](../../examples/11_string_example.sh).
