# `config_get_var`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../15-variables.md) › [Function Index](README.md) › **`config_get_var`** › [Runnable Example](../../examples/15_variables_example.sh) › [Tests](../../tests/17-variables.test.sh)

- **Source:** [`functions/15-variables.sh#L32-L40`](../../functions/15-variables.sh#L32-L40)
- **Signature:** `config_get_var <var_name> [default_value]`
- **Description:** Retrieves the value of a global configuration variable, returning a default value if the variable is unset or empty.

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
| `[default_value]` (`string`) | Optional fallback value. |

## Return / Exit Value

- {string} The configuration value or the fallback default.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local level
  level=$(config_get_var LOG_LEVEL "INFO")
```

---

See also the full runnable example script: [`examples/15_variables_example.sh`](../../examples/15_variables_example.sh).
