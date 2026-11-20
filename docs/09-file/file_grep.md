# `file_grep`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../09-file.md) › [Function Index](README.md) › **`file_grep`** › [Runnable Example](../../examples/09_file_example.sh) › [Tests](../../tests/09-file.test.sh)

- **Source:** [`functions/09-file.sh#L416-L423`](../../functions/09-file.sh#L416-L423)
- **Signature:** `file_grep <file> <pattern>`
- **Description:** Searches for a pattern in a file.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `file` (`string`) | File path. |
| `pattern` (`string`) | Search pattern. |

## Return / Exit Value

- {number} 0 if pattern found, 1 otherwise.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  file_grep "log.txt" "ERROR"
```

---

See also the full runnable example script: [`examples/09_file_example.sh`](../../examples/09_file_example.sh).
