# `validate_jwt`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../04-validation.md) › [Function Index](README.md) › **`validate_jwt`** › [Runnable Example](../../examples/04_validation_example.sh) › [Tests](../../tests/04-validation.test.sh)

- **Source:** [`functions/04-validation.sh#L190-L197`](../../functions/04-validation.sh#L190-L197)
- **Signature:** `validate_jwt <token>`
- **Description:** Validates that a token has the correct structural format of a JWT (header.payload.signature).

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `token` (`string`) | The JWT token to validate. |

## Return / Exit Value

- {number} 0 if structurally valid, 1 otherwise.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  validate_jwt "abc.def.ghi"
```

---

See also the full runnable example script: [`examples/04_validation_example.sh`](../../examples/04_validation_example.sh).
