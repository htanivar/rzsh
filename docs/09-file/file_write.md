# `file_write`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../09-file.md) › [Function Index](README.md) › **`file_write`** › [Runnable Example](../../examples/09_file_example.sh) › [Tests](../../tests/09-file.test.sh)

- **Source:** [`functions/09-file.sh#L102-L106`](../../functions/09-file.sh#L102-L106)
- **Signature:** `file_write <file> <content>`
- **Description:** Writes the specified content to a file, overwriting its previous contents.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `file` (`string`) | The target file path. |
| `content` (`string`) | The content to write. |

## Return / Exit Value

- {number} 0 on success.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  file_write "test.txt" "Hello World"
```

---

See also the full runnable example script: [`examples/09_file_example.sh`](../../examples/09_file_example.sh).
