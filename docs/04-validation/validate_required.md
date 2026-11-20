# `validate_required`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../04-validation.md) › [Function Index](README.md) › **`validate_required`** › [Runnable Example](../../examples/04_validation_example.sh) › [Tests](../../tests/04-validation.test.sh)

- **Source:** [`functions/04-validation.sh#L26-L38`](../../functions/04-validation.sh#L26-L38)
- **Signature:** `validate_required <var> [message="Value is required"]`
- **Description:** Validates that a variable value is not empty.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `var` (`string`) | The value to check. |
| `[message="Value` (`string`) | is required"] - Custom error message. |

## Return / Exit Value

- {number} 0 if valid, 1 otherwise.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  validate_required "${my_var}" "my_var must be set"
```

---

See also the full runnable example script: [`examples/04_validation_example.sh`](../../examples/04_validation_example.sh).
