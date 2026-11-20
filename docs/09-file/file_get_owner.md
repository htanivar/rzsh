# `file_get_owner`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../09-file.md) › [Function Index](README.md) › **`file_get_owner`** › [Runnable Example](../../examples/09_file_example.sh) › [Tests](../../tests/09-file.test.sh)

- **Source:** [`functions/09-file.sh#L248-L254`](../../functions/09-file.sh#L248-L254)
- **Signature:** `file_get_owner <file>`
- **Description:** Prints the username of the owner of a file.

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

- {string} Owner username.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local owner
  owner=$(file_get_owner "config.json")
```

---

See also the full runnable example script: [`examples/09_file_example.sh`](../../examples/09_file_example.sh).
