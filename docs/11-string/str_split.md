# `str_split`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../11-string.md) › [Function Index](README.md) › **`str_split`** › [Runnable Example](../../examples/11_string_example.sh) › [Tests](../../tests/11-string.test.sh)

- **Source:** [`functions/11-string.sh#L166-L177`](../../functions/11-string.sh#L166-L177)
- **Signature:** `str_split <str> <delimiter>`
- **Description:** Splits a string by a delimiter and outputs each piece on a ask line.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `str` (`string`) | String to split. |
| `delimiter` (`string`) | Splitting character/string. |

## Return / Exit Value

- {string} Newline-separated tokens.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  str_split "a,b,c" ","
```

---

See also the full runnable example script: [`examples/11_string_example.sh`](../../examples/11_string_example.sh).
