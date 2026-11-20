# `validate_file_exists`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../04-validation.md) › [Function Index](README.md) › **`validate_file_exists`** › [Runnable Example](../../examples/04_validation_example.sh) › [Tests](../../tests/04-validation.test.sh)

- **Source:** [`functions/04-validation.sh#L69-L75`](../../functions/04-validation.sh#L69-L75)
- **Signature:** `validate_file_exists <file_path>`
- **Description:** Validates that a file exists at the given path.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `file_path` (`string`) | The path to the file. |

## Return / Exit Value

- {number} 0 if file exists, 1 otherwise.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  validate_file_exists "/etc/hosts"
```

---

See also the full runnable example script: [`examples/04_validation_example.sh`](../../examples/04_validation_example.sh).
