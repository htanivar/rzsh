# `file_get_size`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../09-file.md) › [Function Index](README.md) › **`file_get_size`** › [Runnable Example](../../examples/09_file_example.sh) › [Tests](../../tests/09-file.test.sh)

- **Source:** [`functions/09-file.sh#L194-L205`](../../functions/09-file.sh#L194-L205)
- **Signature:** `file_get_size <file>`
- **Description:** Prints the size of a file in bytes.

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

## Return / Exit Value

- {number} 0 on success, 1 on failure.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local sz
  sz=$(file_get_size "data.bin")
```

---

See also the full runnable example script: [`examples/09_file_example.sh`](../../examples/09_file_example.sh).
