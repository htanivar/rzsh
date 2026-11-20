# `file_read`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../09-file.md) › [Function Index](README.md) › **`file_read`** › [Runnable Example](../../examples/09_file_example.sh) › [Tests](../../tests/09-file.test.sh)

- **Source:** [`functions/09-file.sh#L45-L51`](../../functions/09-file.sh#L45-L51)
- **Signature:** `file_read <file>`
- **Description:** Reads and prints the entire contents of a file to stdout.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `file` (`string`) | The file to read. |

## Return / Exit Value

- {number} 0 on success, or non-zero on failure.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local content
  content=$(file_read "data.txt")
```

---

See also the full runnable example script: [`examples/09_file_example.sh`](../../examples/09_file_example.sh).
