# `str_escape`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../11-string.md) › [Function Index](README.md) › **`str_escape`** › [Runnable Example](../../examples/11_string_example.sh) › [Tests](../../tests/11-string.test.sh)

- **Source:** [`functions/11-string.sh#L423-L426`](../../functions/11-string.sh#L423-L426)
- **Signature:** `str_escape <str>`
- **Description:** Shell-escapes a string using Zsh quoting mechanics.

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

## Return / Exit Value

- {string} Escaped string.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  str_escape "hello 'world'"
```

---

See also the full runnable example script: [`examples/11_string_example.sh`](../../examples/11_string_example.sh).
