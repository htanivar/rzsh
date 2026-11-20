# `str_pad_left`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../11-string.md) › [Function Index](README.md) › **`str_pad_left`** › [Runnable Example](../../examples/11_string_example.sh) › [Tests](../../tests/11-string.test.sh)

- **Source:** [`functions/11-string.sh#L371-L386`](../../functions/11-string.sh#L371-L386)
- **Signature:** `str_pad_left <str> <len> [pad=" "]`
- **Description:** Pads the left side of a string to a certain length with a padding string.

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
| `len` (`number`) | Total padded length. |
| `[pad="` (`string`) | "] - Padding character. |

## Return / Exit Value

- {string} Padded string.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  str_pad_left "42" 5 "0"
```

---

See also the full runnable example script: [`examples/11_string_example.sh`](../../examples/11_string_example.sh).
