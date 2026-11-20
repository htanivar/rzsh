# `file_backup`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../09-file.md) › [Function Index](README.md) › **`file_backup`** › [Runnable Example](../../examples/09_file_example.sh) › [Tests](../../tests/09-file.test.sh)

- **Source:** [`functions/09-file.sh#L282-L292`](../../functions/09-file.sh#L282-L292)
- **Signature:** `file_backup <file>`
- **Description:** Creates a backup copy of a file with a timestamp suffix.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `file` (`string`) | The file path to backup. |

## Return / Exit Value

- {string} The created backup file path.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local backup_path
  backup_path=$(file_backup "database.db")
```

---

See also the full runnable example script: [`examples/09_file_example.sh`](../../examples/09_file_example.sh).
