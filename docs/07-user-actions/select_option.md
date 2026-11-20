# `select_option`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../07-user-actions.md) › [Function Index](README.md) › **`select_option`** › [Runnable Example](../../examples/07_user_actions_example.sh) › [Tests](../../tests/07-user-actions.test.sh)

- **Source:** [`functions/07-user-actions.sh#L109-L133`](../../functions/07-user-actions.sh#L109-L133)
- **Signature:** `select_option <prompt> <options>`
- **Description:** Displays a list of options and prompts the user to select one.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `prompt` (`string`) | Prompt explanation. |
| `options` (`string`) | Space-separated list of options. |

## Return / Exit Value

- {string} The selected option string.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local env
  env=$(select_option "Select environment" "development staging production")
```

---

See also the full runnable example script: [`examples/07_user_actions_example.sh`](../../examples/07_user_actions_example.sh).
