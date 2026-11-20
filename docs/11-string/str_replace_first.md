# `str_replace_first`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../11-string.md) › [Function Index](README.md) › **`str_replace_first`** › [Runnable Example](../../examples/11_string_example.sh) › [Tests](../../tests/11-string.test.sh)

- **Source:** [`functions/11-string.sh#L103-L108`](../../functions/11-string.sh#L103-L108)
- **Signature:** `str_replace_first <str> <search> <replace>`
- **Description:** Replaces only the first occurrence of a search term with a replacement term.

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
  res=$(str_replace_first "hello world" "l" "x")
```

---

See also the full runnable example script: [`examples/11_string_example.sh`](../../examples/11_string_example.sh).
