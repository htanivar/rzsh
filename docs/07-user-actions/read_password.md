# `read_password`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../07-user-actions.md) › [Function Index](README.md) › **`read_password`** › [Runnable Example](../../examples/07_user_actions_example.sh) › [Tests](../../tests/07-user-actions.test.sh)

- **Source:** [`functions/07-user-actions.sh#L53-L61`](../../functions/07-user-actions.sh#L53-L61)
- **Signature:** `read_password <prompt>`
- **Description:** Prompts the user for a password or sensitive input silently (without echoing input).

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

## Return / Exit Value

- {string} The password entered.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local pass
  pass=$(read_password "Enter API Key")
```

---

See also the full runnable example script: [`examples/07_user_actions_example.sh`](../../examples/07_user_actions_example.sh).
