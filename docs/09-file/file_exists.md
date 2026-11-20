# `file_exists`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../09-file.md) › [Function Index](README.md) › **`file_exists`** › [Runnable Example](../../examples/09_file_example.sh) › [Tests](../../tests/09-file.test.sh)

- **Source:** [`functions/09-file.sh#L28-L34`](../../functions/09-file.sh#L28-L34)
- **Signature:** `file_exists <file>`
- **Description:** Checks if a path exists and points to a regular file.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `file` (`string`) | The file path to check. |

## Return / Exit Value

- {number} 0 if file exists, 1 otherwise.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  if file_exists "/etc/passwd"; then
    echo "Exists"
  fi
```

---

See also the full runnable example script: [`examples/09_file_example.sh`](../../examples/09_file_example.sh).
