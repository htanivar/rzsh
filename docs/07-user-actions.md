# Interactive Prompts Module Reference

- **Source File:** [`functions/07-user-actions.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/07-user-actions.sh)
- **Description:** User terminal prompts, passwords, select items, and validation loops.

---

## Detailed Usage Examples

### Integration Setup
To use the Interactive Prompts module, ensure the global configurations are initialized, then source the script file:

```zsh
source ./config/config.sh
init_config

source ./functions/07-user-actions.sh
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
confirm "Deploy to production?" "n" && deploy_stack
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
