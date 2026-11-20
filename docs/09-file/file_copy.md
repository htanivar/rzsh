# `file_copy`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../09-file.md) › [Function Index](README.md) › **`file_copy`** › [Runnable Example](../../examples/09_file_example.sh) › [Tests](../../tests/09-file.test.sh)

- **Source:** [`functions/09-file.sh#L132-L136`](../../functions/09-file.sh#L132-L136)
- **Signature:** `file_copy <source> <dest>`
- **Description:** Copies a file from source to destination.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `source` (`string`) | Source file path. |
| `dest` (`string`) | Destination file path. |

## Return / Exit Value

- {number} 0 on success.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  file_copy "old.txt" "ask.txt"
```

---

See also the full runnable example script: [`examples/09_file_example.sh`](../../examples/09_file_example.sh).
