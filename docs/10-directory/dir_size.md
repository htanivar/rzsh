# `dir_size`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../10-directory.md) › [Function Index](README.md) › **`dir_size`** › [Runnable Example](../../examples/10_directory_example.sh) › [Tests](../../tests/10-directory.test.sh)

- **Source:** [`functions/10-directory.sh#L146-L164`](../../functions/10-directory.sh#L146-L164)
- **Signature:** `dir_size <dir>`
- **Description:** Calculates the total size of all files in a directory in bytes.

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

- {number} Directory size in bytes.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local sz
  sz=$(dir_size "/var/log")
```

---

See also the full runnable example script: [`examples/10_directory_example.sh`](../../examples/10_directory_example.sh).
