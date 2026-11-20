# `validate_is_number`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../04-validation.md) › [Function Index](README.md) › **`validate_is_number`** › [Runnable Example](../../examples/04_validation_example.sh) › [Tests](../../tests/04-validation.test.sh)

- **Source:** [`functions/04-validation.sh#L101-L107`](../../functions/04-validation.sh#L101-L107)
- **Signature:** `validate_is_number <value>`
- **Description:** Validates that a value is a number (integer or decimal, positive or negative).

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `value` (`string`) | The value to check. |

## Return / Exit Value

- {number} 0 if a valid number, 1 otherwise.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  validate_is_number "-123.45"
```

---

See also the full runnable example script: [`examples/04_validation_example.sh`](../../examples/04_validation_example.sh).
