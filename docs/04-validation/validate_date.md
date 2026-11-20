# `validate_date`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../04-validation.md) › [Function Index](README.md) › **`validate_date`** › [Runnable Example](../../examples/04_validation_example.sh) › [Tests](../../tests/04-validation.test.sh)

- **Source:** [`functions/04-validation.sh#L165-L180`](../../functions/04-validation.sh#L165-L180)
- **Signature:** `validate_date <date_string>`
- **Description:** Validates that a date string is valid and parseable.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `date_string` (`string`) | The date string to validate. |

## Return / Exit Value

- {number} 0 if valid date, 1 otherwise.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  validate_date "2026-07-08"
```

---

See also the full runnable example script: [`examples/04_validation_example.sh`](../../examples/04_validation_example.sh).
