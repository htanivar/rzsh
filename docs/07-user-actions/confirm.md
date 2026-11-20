# `confirm`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../07-user-actions.md) › [Function Index](README.md) › **`confirm`** › [Runnable Example](../../examples/07_user_actions_example.sh) › [Tests](../../tests/07-user-actions.test.sh)

- **Source:** [`functions/07-user-actions.sh#L74-L97`](../../functions/07-user-actions.sh#L74-L97)
- **Signature:** `confirm <prompt> [default=n]`
- **Description:** Prompts the user for confirmation (yes/no).

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
| `[default=n]` (`string`) | Default option 'y' (yes) or 'n' (no). |

## Return / Exit Value

- {number} 0 if confirmed (yes), 1 otherwise (no).

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  if confirm "Do you want to deploy?"; then
    deploy
  fi
```

---

See also the full runnable example script: [`examples/07_user_actions_example.sh`](../../examples/07_user_actions_example.sh).
