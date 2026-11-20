# `str_slugify`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../11-string.md) › [Function Index](README.md) › **`str_slugify`** › [Runnable Example](../../examples/11_string_example.sh) › [Tests](../../tests/11-string.test.sh)

- **Source:** [`functions/11-string.sh#L449-L458`](../../functions/11-string.sh#L449-L458)
- **Signature:** `str_slugify <str>`
- **Description:** Converts a string to a lowercase URL-safe slug representation.

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

- {string} Slug string.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  str_slugify "Hello, World! 2026"
```

---

See also the full runnable example script: [`examples/11_string_example.sh`](../../examples/11_string_example.sh).
