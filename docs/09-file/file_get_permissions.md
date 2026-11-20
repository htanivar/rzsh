# `file_get_permissions`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../09-file.md) › [Function Index](README.md) › **`file_get_permissions`** › [Runnable Example](../../examples/09_file_example.sh) › [Tests](../../tests/09-file.test.sh)

- **Source:** [`functions/09-file.sh#L216-L222`](../../functions/09-file.sh#L216-L222)
- **Signature:** `file_get_permissions <file>`
- **Description:** Returns the permissions of a file in octal format (e.g. 644).

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

- {string} The octal permissions.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local perms
  perms=$(file_get_permissions "run.sh")
```

---

See also the full runnable example script: [`examples/09_file_example.sh`](../../examples/09_file_example.sh).
