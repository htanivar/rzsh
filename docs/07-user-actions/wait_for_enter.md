# `wait_for_enter`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../07-user-actions.md) › [Function Index](README.md) › **`wait_for_enter`** › [Runnable Example](../../examples/07_user_actions_example.sh) › [Tests](../../tests/07-user-actions.test.sh)

- **Source:** [`functions/07-user-actions.sh#L143-L147`](../../functions/07-user-actions.sh#L143-L147)
- **Signature:** `wait_for_enter [prompt="Press Enter to continue..."]`
- **Description:** Pauses script execution and waits for the user to press Enter.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `[prompt="Press` (`string`) | Enter to continue..."] - Prompt message. |

## Return / Exit Value

- {void}

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  wait_for_enter "Confirm everything is okay and press Enter..."
```

---

See also the full runnable example script: [`examples/07_user_actions_example.sh`](../../examples/07_user_actions_example.sh).
