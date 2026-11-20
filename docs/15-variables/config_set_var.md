# `config_set_var`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../15-variables.md) › [Function Index](README.md) › **`config_set_var`** › [Runnable Example](../../examples/15_variables_example.sh) › [Tests](../../tests/17-variables.test.sh)

- **Source:** [`functions/15-variables.sh#L51-L59`](../../functions/15-variables.sh#L51-L59)
- **Signature:** `config_set_var <var_name> <value>`
- **Description:** Sets the value of a global configuration variable dynamically.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `var_name` (`string`) | The name of the configuration variable. |
| `value` (`string`) | The value to assign to the variable. |

## Return / Exit Value

- {number} 0 on success, or non-zero on failure.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  config_set_var LOG_LEVEL "DEBUG"
```

---

See also the full runnable example script: [`examples/15_variables_example.sh`](../../examples/15_variables_example.sh).
