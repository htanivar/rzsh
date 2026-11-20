# `str_substring`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../11-string.md) › [Function Index](README.md) › **`str_substring`** › [Runnable Example](../../examples/11_string_example.sh) › [Tests](../../tests/11-string.test.sh)

- **Source:** [`functions/11-string.sh#L354-L359`](../../functions/11-string.sh#L354-L359)
- **Signature:** `str_substring <str> <offset> <length>`
- **Description:** Returns a portion of a string starting at 0-based offset with specified length.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `str` (`string`) | String. |
| `offset` (`number`) | Start offset (0-based). |
| `length` (`number`) | Substring length. |

## Return / Exit Value

- {string} The substring.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  str_substring "hello" 1 3
```

---

See also the full runnable example script: [`examples/11_string_example.sh`](../../examples/11_string_example.sh).
