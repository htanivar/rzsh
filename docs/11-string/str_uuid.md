# `str_uuid`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../11-string.md) › [Function Index](README.md) › **`str_uuid`** › [Runnable Example](../../examples/11_string_example.sh) › [Tests](../../tests/11-string.test.sh)

- **Source:** [`functions/11-string.sh#L495-L522`](../../functions/11-string.sh#L495-L522)
- **Signature:** `str_uuid`
- **Description:** Generates a standard UUID version 4 (all lowercase).

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| — | None |

## Return / Exit Value

- {string} UUID.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local id
  id=$(str_uuid)
```

---

See also the full runnable example script: [`examples/11_string_example.sh`](../../examples/11_string_example.sh).
