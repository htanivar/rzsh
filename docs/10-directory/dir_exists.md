# `dir_exists`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../10-directory.md) › [Function Index](README.md) › **`dir_exists`** › [Runnable Example](../../examples/10_directory_example.sh) › [Tests](../../tests/10-directory.test.sh)

- **Source:** [`functions/10-directory.sh#L28-L34`](../../functions/10-directory.sh#L28-L34)
- **Signature:** `dir_exists <dir>`
- **Description:** Checks if a path exists and is a directory.

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

- {number} 0 if directory exists, 1 otherwise.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  if dir_exists "/var/log"; then
    echo "Directory exists"
  fi
```

---

See also the full runnable example script: [`examples/10_directory_example.sh`](../../examples/10_directory_example.sh).
