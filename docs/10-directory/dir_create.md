# `dir_create`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../10-directory.md) › [Function Index](README.md) › **`dir_create`** › [Runnable Example](../../examples/10_directory_example.sh) › [Tests](../../tests/10-directory.test.sh)

- **Source:** [`functions/10-directory.sh#L44-L47`](../../functions/10-directory.sh#L44-L47)
- **Signature:** `dir_create <dir>`
- **Description:** Creates a directory, including any necessary parent directories.

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

- {number} 0 on success.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  dir_create "/tmp/my_app/temp"
```

---

See also the full runnable example script: [`examples/10_directory_example.sh`](../../examples/10_directory_example.sh).
