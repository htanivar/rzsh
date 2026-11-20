# `validate_json`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../04-validation.md) › [Function Index](README.md) › **`validate_json`** › [Runnable Example](../../examples/04_validation_example.sh) › [Tests](../../tests/04-validation.test.sh)

- **Source:** [`functions/04-validation.sh#L207-L221`](../../functions/04-validation.sh#L207-L221)
- **Signature:** `validate_json <json_string>`
- **Description:** Validates that a string is a valid JSON document (using jq if available).

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `json_string` (`string`) | The JSON string to validate. |

## Return / Exit Value

- {number} 0 if valid JSON, 1 otherwise.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  validate_json '{"name": "test"}'
```

---

See also the full runnable example script: [`examples/04_validation_example.sh`](../../examples/04_validation_example.sh).
