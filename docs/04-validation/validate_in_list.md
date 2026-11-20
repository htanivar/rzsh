# `validate_in_list`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../04-validation.md) › [Function Index](README.md) › **`validate_in_list`** › [Runnable Example](../../examples/04_validation_example.sh) › [Tests](../../tests/04-validation.test.sh)

- **Source:** [`functions/04-validation.sh#L49-L59`](../../functions/04-validation.sh#L49-L59)
- **Signature:** `validate_in_list <value> <list>`
- **Description:** Validates that a value exists in a space- or comma-separated list.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `value` (`string`) | The value to search for. |
| `list` (`string`) | The list of allowed values. |

## Return / Exit Value

- {number} 0 if found, 1 otherwise.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  validate_in_list "apple" "apple banana orange"
```

---

See also the full runnable example script: [`examples/04_validation_example.sh`](../../examples/04_validation_example.sh).
