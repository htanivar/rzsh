# Interactive Prompts Module Reference

**Navigation:** [README](../README.md) › [GLOSSARY](../GLOSSARY.md) › **07-user-actions.md** › [Example](../examples/07_user_actions_example.sh) › [Tests](../tests/07-user-actions.test.sh)

- **Source File:** [`functions/07-user-actions.sh`](../functions/07-user-actions.sh)
- **Description:** User terminal prompts, passwords, select items, and validation loops.

---

## Detailed Usage Examples

### Integration Setup
To use the Interactive Prompts module, source the configuration script via `RZSH_DIR`, which automatically imports it:

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

---

## Function Signatures & Descriptions

### `read_input`

* **Signature:** `read_input <prompt_message> [default_value]`
* **Description:** Prompts the user for text input, returning the entered value or default.

#### Example Code:
```zsh
local name=$(read_input "Enter your name" "Guest")
```

---
### `read_password`

* **Signature:** `read_password <prompt_message>`
* **Description:** Prompts the user for input without echoing characters to the terminal.

#### Example Code:
```zsh
local pass=$(read_password "Enter API Key: ")
```

---
### `confirm`

* **Signature:** `confirm <prompt_message> [default_y_n]`
* **Description:** Prompts the user for a Yes/No choice. Returns 0 for Yes, 1 for No.

#### Example Code:
```zsh
confirm "Do you want to run updates?" "n" && deploy_stack
```

---
### `select_option`

* **Signature:** `select_option <prompt_message> <option1> <option2> ...`
* **Description:** Displays a numbered list of choices and returns the selected item.

#### Example Code:
```zsh
local env=$(select_option "Select environment" "development" "staging" "production")
```

---
### `wait_for_enter`

* **Signature:** `wait_for_enter [prompt_message]`
* **Description:** Suspends script execution until the user presses the Enter key.

#### Example Code:
```zsh
wait_for_enter "Press [Enter] to resume"
```

---
### `read_with_validation`

* **Signature:** `read_with_validation <prompt_message> <validation_function>`
* **Description:** Continually prompts the user for input until the value passes the validation function.

#### Example Code:
```zsh
local email=$(read_with_validation "Enter contact email" "validate_email")
```

---

---

## Per-Function Copy-Paste Reference

Browse dedicated per-function pages with all flags and copy-paste variations in [`docs/07-user-actions/`](07-user-actions/README.md), or run [`examples/07_user_actions_example.sh`](../examples/07_user_actions_example.sh).

| Function | Per-Function Docs & Flags | Runnable Example |
| :--- | :--- | :--- |
| `read_input` | [Docs & Examples](07-user-actions/read_input.md) | [`07_user_actions_example.sh`](../examples/07_user_actions_example.sh) |
| `read_password` | [Docs & Examples](07-user-actions/read_password.md) | [`07_user_actions_example.sh`](../examples/07_user_actions_example.sh) |
| `confirm` | [Docs & Examples](07-user-actions/confirm.md) | [`07_user_actions_example.sh`](../examples/07_user_actions_example.sh) |
| `select_option` | [Docs & Examples](07-user-actions/select_option.md) | [`07_user_actions_example.sh`](../examples/07_user_actions_example.sh) |
| `wait_for_enter` | [Docs & Examples](07-user-actions/wait_for_enter.md) | [`07_user_actions_example.sh`](../examples/07_user_actions_example.sh) |
| `read_with_validation` | [Docs & Examples](07-user-actions/read_with_validation.md) | [`07_user_actions_example.sh`](../examples/07_user_actions_example.sh) |