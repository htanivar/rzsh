# `register_temp_file`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../02-errors.md) › [Function Index](README.md) › **`register_temp_file`** › [Runnable Example](../../examples/02_errors_example.sh) › [Tests](../../tests/02-errors.test.sh)

- **Source:** [`functions/02-errors.sh#L61-L70`](../../functions/02-errors.sh#L61-L70)
- **Signature:** `register_temp_file <file_path>`
- **Description:** Registers a file or directory path for automatic cleanup.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `file_path` (`string`) | Path of the file/directory to register. |

## Return / Exit Value

- {number} 0 on success.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  register_temp_file "/tmp/scratch.txt"
```

---

See also the full runnable example script: [`examples/02_errors_example.sh`](../../examples/02_errors_example.sh).
