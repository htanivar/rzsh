# `validate_command_exists`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../04-validation.md) › [Function Index](README.md) › **`validate_command_exists`** › [Runnable Example](../../examples/04_validation_example.sh) › [Tests](../../tests/04-validation.test.sh)

- **Source:** [`functions/04-validation.sh#L149-L155`](../../functions/04-validation.sh#L149-L155)
- **Signature:** `validate_command_exists <command>`
- **Description:** Validates that an external command/executable is available in the current PATH.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `command` (`string`) | The command to check. |

## Return / Exit Value

- {number} 0 if command exists, 1 otherwise.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  validate_command_exists "curl"
```

---

See also the full runnable example script: [`examples/04_validation_example.sh`](../../examples/04_validation_example.sh).
