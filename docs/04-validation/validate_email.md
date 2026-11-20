# `validate_email`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../04-validation.md) › [Function Index](README.md) › **`validate_email`** › [Runnable Example](../../examples/04_validation_example.sh) › [Tests](../../tests/04-validation.test.sh)

- **Source:** [`functions/04-validation.sh#L117-L123`](../../functions/04-validation.sh#L117-L123)
- **Signature:** `validate_email <email>`
- **Description:** Validates that a string matches a basic email regex pattern.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `email` (`string`) | The email to validate. |

## Return / Exit Value

- {number} 0 if valid, 1 otherwise.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  validate_email "test@example.com"
```

---

See also the full runnable example script: [`examples/04_validation_example.sh`](../../examples/04_validation_example.sh).
