# `validate_script_executable`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../18-script-executory.md) › [Function Index](README.md) › **`validate_script_executable`** › [Runnable Example](../../examples/18_script_executory_example.sh) › [Tests](../../tests/18-script-executory.test.sh)

- **Source:** [`functions/18-script-executory.sh#L49-L75`](../../functions/18-script-executory.sh#L49-L75)
- **Signature:** `validate_script_executable <script_path>`
- **Description:** Resolves a script path and verifies it exists, is readable, and passes Zsh syntax check.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `script_path` (`string`) | Path or relative name of the script to validate. |

## Return / Exit Value

- {number} 0 if valid, 1 otherwise.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  validate_script_executable "scripts/login.sh"
```

---

See also the full runnable example script: [`examples/18_script_executory_example.sh`](../../examples/18_script_executory_example.sh).
