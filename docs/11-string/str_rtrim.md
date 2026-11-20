# `str_rtrim`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../11-string.md) › [Function Index](README.md) › **`str_rtrim`** › [Runnable Example](../../examples/11_string_example.sh) › [Tests](../../tests/11-string.test.sh)

- **Source:** [`functions/11-string.sh#L151-L155`](../../functions/11-string.sh#L151-L155)
- **Signature:** `str_rtrim <str>`
- **Description:** Trims trailing whitespace from a string.

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
  res=$(str_rtrim "hello   ")
```

---

See also the full runnable example script: [`examples/11_string_example.sh`](../../examples/11_string_example.sh).
