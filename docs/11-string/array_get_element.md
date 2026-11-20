# `array_get_element`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../11-string.md) › [Function Index](README.md) › **`array_get_element`** › [Runnable Example](../../examples/11_string_example.sh) › [Tests](../../tests/11-string.test.sh)

- **Source:** [`functions/11-string.sh#L243-L273`](../../functions/11-string.sh#L243-L273)
- **Signature:** `array_get_element <array_name> <index>`
- **Description:** Retrieves a specific element from a Zsh array by 1-based index, negative index (e.g. -1), or keyword ('first', 'last').

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `array_name` (`string`) | Name of the array variable. |
| `index` (`string\|number`) | 1-based index, negative index (-1 = last), or 'first' / 'last'. |

## Return / Exit Value

- {string} The element at the requested position (exits 1 if out of bounds or invalid).

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  str_to_array "apple,banana,cherry" "," "FRUITS"
  last_fruit=$(array_get_element "FRUITS" "last")
```

---

See also the full runnable example script: [`examples/11_string_example.sh`](../../examples/11_string_example.sh).
