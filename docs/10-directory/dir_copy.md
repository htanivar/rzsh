# `dir_copy`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../10-directory.md) › [Function Index](README.md) › **`dir_copy`** › [Runnable Example](../../examples/10_directory_example.sh) › [Tests](../../tests/10-directory.test.sh)

- **Source:** [`functions/10-directory.sh#L90-L94`](../../functions/10-directory.sh#L90-L94)
- **Signature:** `dir_copy <source> <dest>`
- **Description:** Recursively copies a directory to a destination.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `source` (`string`) | Source directory. |
| `dest` (`string`) | Destination directory. |

## Return / Exit Value

- {number} 0 on success.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  dir_copy "/tmp/src" "/tmp/dest"
```

---

See also the full runnable example script: [`examples/10_directory_example.sh`](../../examples/10_directory_example.sh).
