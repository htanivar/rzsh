# `file_delete`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../09-file.md) › [Function Index](README.md) › **`file_delete`** › [Runnable Example](../../examples/09_file_example.sh) › [Tests](../../tests/09-file.test.sh)

- **Source:** [`functions/09-file.sh#L162-L183`](../../functions/09-file.sh#L162-L183)
- **Signature:** `file_delete <file> [option]`
- **Description:** Deletes a file. Requires confirmation unless --force or -f is passed.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `file` (`string`) | File path to delete. |
| `[option]` (`string`) | Pass '--force' or '-f' to skip interactive confirmation. |

## Return / Exit Value

- {number} 0 on success or if file doesn't exist, 1 on failure or if canceled.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  file_delete "temp.txt" "--force"
```

### 2. Interactive confirmation (default)

```zsh
file_delete "/tmp/old_report.txt"
```

### 3. Skip confirmation with --force or -f

```zsh
file_delete "/tmp/old_report.txt" "--force"
file_delete "/tmp/old_report.txt" "-f"
```

---

See also the full runnable example script: [`examples/09_file_example.sh`](../../examples/09_file_example.sh).
