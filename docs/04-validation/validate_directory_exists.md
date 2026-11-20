# `validate_directory_exists`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../04-validation.md) › [Function Index](README.md) › **`validate_directory_exists`** › [Runnable Example](../../examples/04_validation_example.sh) › [Tests](../../tests/04-validation.test.sh)

- **Source:** [`functions/04-validation.sh#L85-L91`](../../functions/04-validation.sh#L85-L91)
- **Signature:** `validate_directory_exists <dir_path>`
- **Description:** Validates that a directory exists at the given path.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `dir_path` (`string`) | The path to the directory. |

## Return / Exit Value

- {number} 0 if directory exists, 1 otherwise.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  validate_directory_exists "/var/log"
```

---

See also the full runnable example script: [`examples/04_validation_example.sh`](../../examples/04_validation_example.sh).
