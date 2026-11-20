# `str_unescape`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../11-string.md) › [Function Index](README.md) › **`str_unescape`** › [Runnable Example](../../examples/11_string_example.sh) › [Tests](../../tests/11-string.test.sh)

- **Source:** [`functions/11-string.sh#L436-L439`](../../functions/11-string.sh#L436-L439)
- **Signature:** `str_unescape <str>`
- **Description:** Unescapes a shell-escaped string.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `str` (`string`) | Escaped string. |

## Return / Exit Value

- {string} Unescaped string.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  str_unescape "hello\\ \\'world\\'"
```

---

See also the full runnable example script: [`examples/11_string_example.sh`](../../examples/11_string_example.sh).
