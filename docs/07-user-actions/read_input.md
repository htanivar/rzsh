# `read_input`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../07-user-actions.md) › [Function Index](README.md) › **`read_input`** › [Runnable Example](../../examples/07_user_actions_example.sh) › [Tests](../../tests/07-user-actions.test.sh)

- **Source:** [`functions/07-user-actions.sh#L24-L42`](../../functions/07-user-actions.sh#L24-L42)
- **Signature:** `read_input <prompt> [default]`
- **Description:** Prompts the user for input. If the user presses enter without typing anything, returns the default value.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `prompt` (`string`) | The prompt message. |
| `[default]` (`string`) | Default value if input is empty. |

## Return / Exit Value

- {string} The input value or default.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local name
  name=$(read_input "Enter your name" "Guest")
```

---

See also the full runnable example script: [`examples/07_user_actions_example.sh`](../../examples/07_user_actions_example.sh).
