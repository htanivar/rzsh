# `config_unset_var`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../15-variables.md) › [Function Index](README.md) › **`config_unset_var`** › [Runnable Example](../../examples/15_variables_example.sh) › [Tests](../../tests/17-variables.test.sh)

- **Source:** [`functions/15-variables.sh#L69-L76`](../../functions/15-variables.sh#L69-L76)
- **Signature:** `config_unset_var <var_name>`
- **Description:** Unsets/removes a global configuration variable.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `var_name` (`string`) | The name of the configuration variable to unset. |

## Return / Exit Value

- {number} 0 on success, or non-zero on failure.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  config_unset_var LOG_LEVEL
```

---

See also the full runnable example script: [`examples/15_variables_example.sh`](../../examples/15_variables_example.sh).
