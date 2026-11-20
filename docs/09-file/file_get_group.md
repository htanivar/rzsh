# `file_get_group`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../09-file.md) › [Function Index](README.md) › **`file_get_group`** › [Runnable Example](../../examples/09_file_example.sh) › [Tests](../../tests/09-file.test.sh)

- **Source:** [`functions/09-file.sh#L265-L271`](../../functions/09-file.sh#L265-L271)
- **Signature:** `file_get_group <file>`
- **Description:** Prints the group name of a file.

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

- {string} Group name.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local grp
  grp=$(file_get_group "config.json")
```

---

See also the full runnable example script: [`examples/09_file_example.sh`](../../examples/09_file_example.sh).
