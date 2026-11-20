# `str_random`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../11-string.md) › [Function Index](README.md) › **`str_random`** › [Runnable Example](../../examples/11_string_example.sh) › [Tests](../../tests/11-string.test.sh)

- **Source:** [`functions/11-string.sh#L469-L484`](../../functions/11-string.sh#L469-L484)
- **Signature:** `str_random [len=16]`
- **Description:** Generates a random alphanumeric string of the specified length.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `[len=16]` (`number`) | Output length. |

## Return / Exit Value

- {string} Random string.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local secret
  secret=$(str_random 32)
```

---

See also the full runnable example script: [`examples/11_string_example.sh`](../../examples/11_string_example.sh).
