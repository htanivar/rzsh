# `file_backup_and_restore`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../09-file.md) › [Function Index](README.md) › **`file_backup_and_restore`** › [Runnable Example](../../examples/09_file_example.sh) › [Tests](../../tests/09-file.test.sh)

- **Source:** [`functions/09-file.sh#L326-L343`](../../functions/09-file.sh#L326-L343)
- **Signature:** `file_backup_and_restore <action> <file> [backup_path]`
- **Description:** High-level wrapper to backup or restore files.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `action` (`string`) | 'backup' or 'restore'. |
| `file` (`string`) | Target file path. |
| `[backup_path]` (`string`) | Specific backup path (required for restore). |

## Return / Exit Value

- {string|number} Backup file path on backup success, or 0 on restore success.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  file_backup_and_restore "backup" "settings.conf"
```

---

See also the full runnable example script: [`examples/09_file_example.sh`](../../examples/09_file_example.sh).
