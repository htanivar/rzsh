# `str_to_array`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../11-string.md) › [Function Index](README.md) › **`str_to_array`** › [Runnable Example](../../examples/11_string_example.sh) › [Tests](../../tests/11-string.test.sh)

- **Source:** [`functions/11-string.sh#L209-L231`](../../functions/11-string.sh#L209-L231)
- **Signature:** `str_to_array <str> <delimiter> [array_name=STR_ARRAY]`
- **Description:** Splits a string by a separator/delimiter into a Zsh array variable.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `str` (`string`) | The input string to split. |
| `delimiter` (`string`) | The separator string to split on. |
| `[array_name=STR_ARRAY]` (`string`) | Name of the target array variable to populate. |

## Return / Exit Value

- {number} 0 on success, 1 if delimiter is empty or array_name is invalid.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  str_to_array "apple,banana,cherry" "," "FRUITS"
  echo "${FRUITS[@]}"
```

---

See also the full runnable example script: [`examples/11_string_example.sh`](../../examples/11_string_example.sh).
