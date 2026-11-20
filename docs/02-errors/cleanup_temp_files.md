# `cleanup_temp_files`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../02-errors.md) › [Function Index](README.md) › **`cleanup_temp_files`** › [Runnable Example](../../examples/02_errors_example.sh) › [Tests](../../tests/02-errors.test.sh)

- **Source:** [`functions/02-errors.sh#L79-L96`](../../functions/02-errors.sh#L79-L96)
- **Signature:** `cleanup_temp_files`
- **Description:** Cleans up (deletes) all registered temporary files from disk.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Return / Exit Value

- {number} 0 on success.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  cleanup_temp_files
```

---

See also the full runnable example script: [`examples/02_errors_example.sh`](../../examples/02_errors_example.sh).
