# `dir_is_empty`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../10-directory.md) › [Function Index](README.md) › **`dir_is_empty`** › [Runnable Example](../../examples/10_directory_example.sh) › [Tests](../../tests/10-directory.test.sh)

- **Source:** [`functions/10-directory.sh#L176-L192`](../../functions/10-directory.sh#L176-L192)
- **Signature:** `dir_is_empty <dir>`
- **Description:** Checks if a directory is empty.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `dir` (`string`) | Directory path. |

## Return / Exit Value

- {number} 0 if empty, 1 otherwise.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  if dir_is_empty "/tmp/empty_dir"; then
    echo "Is empty"
  fi
```

---

See also the full runnable example script: [`examples/10_directory_example.sh`](../../examples/10_directory_example.sh).
