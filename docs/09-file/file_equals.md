# `file_equals`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../09-file.md) › [Function Index](README.md) › **`file_equals`** › [Runnable Example](../../examples/09_file_example.sh) › [Tests](../../tests/09-file.test.sh)

- **Source:** [`functions/09-file.sh#L436-L443`](../../functions/09-file.sh#L436-L443)
- **Signature:** `file_equals <file1> <file2>`
- **Description:** Checks whether two files have identical byte-for-byte contents.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `file1` (`string`) | First file path. |
| `file2` (`string`) | Second file path. |

## Return / Exit Value

- {number} 0 if identical, 1 if different, 2 if either file does not exist.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  if file_equals "a.txt" "b.txt"; then
    echo "Files are identical"
  fi
```

---

See also the full runnable example script: [`examples/09_file_example.sh`](../../examples/09_file_example.sh).
