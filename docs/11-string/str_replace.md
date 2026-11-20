# `str_replace`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../11-string.md) › [Function Index](README.md) › **`str_replace`** › [Runnable Example](../../examples/11_string_example.sh) › [Tests](../../tests/11-string.test.sh)

- **Source:** [`functions/11-string.sh#L85-L90`](../../functions/11-string.sh#L85-L90)
- **Signature:** `str_replace <str> <search> <replace>`
- **Description:** Replaces all occurrences of a search term with a replacement term in a string.

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
| `search` (`string`) | The term to search for. |
| `replace` (`string`) | The replacement term. |

## Return / Exit Value

- {string} The modified string.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local res
  res=$(str_replace "hello world" "l" "x")
```

---

See also the full runnable example script: [`examples/11_string_example.sh`](../../examples/11_string_example.sh).
