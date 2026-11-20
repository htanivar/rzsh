# Interactive User Prompts — Function Index

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../07-user-actions.md) › **07-user-actions/** › [Runnable Example](../../examples/07_user_actions_example.sh) › [Tests](../../tests/07-user-actions.test.sh)

- **Source File:** [`functions/07-user-actions.sh`](../../functions/07-user-actions.sh)
- **Runnable Example:** [`examples/07_user_actions_example.sh`](../../examples/07_user_actions_example.sh)

| Function | Signature | Description |
| :--- | :--- | :--- |
| [`read_input`](read_input.md) | `read_input <prompt> [default]` | Prompts the user for input. If the user presses enter without typing anything, returns the default value. |
| [`read_password`](read_password.md) | `read_password <prompt>` | Prompts the user for a password or sensitive input silently (without echoing input). |
| [`confirm`](confirm.md) | `confirm <prompt> [default=n]` | Prompts the user for confirmation (yes/no). |
| [`select_option`](select_option.md) | `select_option <prompt> <options>` | Displays a list of options and prompts the user to select one. |
| [`wait_for_enter`](wait_for_enter.md) | `wait_for_enter [prompt="Press Enter to continue..."]` | Pauses script execution and waits for the user to press Enter. |
| [`read_with_validation`](read_with_validation.md) | `read_with_validation <prompt> <validation_func>` | Repeatedly prompts the user for input until it successfully validates against a validation function. |
