# `str_ltrim`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../11-string.md) › [Function Index](README.md) › **`str_ltrim`** › [Runnable Example](../../examples/11_string_example.sh) › [Tests](../../tests/11-string.test.sh)

- **Source:** [`functions/11-string.sh#L136-L140`](../../functions/11-string.sh#L136-L140)
- **Signature:** `str_ltrim <str>`
- **Description:** Trims leading whitespace from a string.

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
  res=$(str_ltrim "   hello")
```

---

See also the full runnable example script: [`examples/11_string_example.sh`](../../examples/11_string_example.sh).
