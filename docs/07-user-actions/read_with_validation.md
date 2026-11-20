# `read_with_validation`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../07-user-actions.md) › [Function Index](README.md) › **`read_with_validation`** › [Runnable Example](../../examples/07_user_actions_example.sh) › [Tests](../../tests/07-user-actions.test.sh)

- **Source:** [`functions/07-user-actions.sh#L159-L175`](../../functions/07-user-actions.sh#L159-L175)
- **Signature:** `read_with_validation <prompt> <validation_func>`
- **Description:** Repeatedly prompts the user for input until it successfully validates against a validation function.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `prompt` (`string`) | Prompt message. |
| `validation_func` (`string`) | The name of the Zsh validation function to run against input. |

## Return / Exit Value

- {string} The validated user input.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local num
  num=$(read_with_validation "Enter a number" "validate_is_number")
```

---

See also the full runnable example script: [`examples/07_user_actions_example.sh`](../../examples/07_user_actions_example.sh).
