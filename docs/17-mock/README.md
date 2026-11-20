# Mocking & Test Stubs — Function Index

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../17-mock.md) › **17-mock/** › [Runnable Example](../../examples/17_mock_example.sh) › [Tests](../../tests/17-mock.test.sh)

- **Source File:** [`functions/17-mock.sh`](../../functions/17-mock.sh)
- **Runnable Example:** [`examples/17_mock_example.sh`](../../examples/17_mock_example.sh)

| Function | Signature | Description |
| :--- | :--- | :--- |
| [`mock_string`](mock_string.md) | `mock_string [length=12] [prefix=""]` | Generates a random alphabetic dummy string, optionally with a prefix. |
| [`mock_alphanumeric`](mock_alphanumeric.md) | `mock_alphanumeric [length=16]` | Generates a random alphanumeric (A-Z, a-z, 0-9) dummy string. |
| [`mock_password`](mock_password.md) | `mock_password [length=16] [include_special=1]` | Generates a random password with uppercase, lowercase, digits, and optional special characters. |
| [`mock_int`](mock_int.md) | `mock_int [min=1] [max=1000]` | Generates a random integer within [min, max] inclusive. |
| [`mock_bool`](mock_bool.md) | `mock_bool` | Generates a random boolean string ('true' or 'false'). |
| [`mock_uuid`](mock_uuid.md) | `mock_uuid` | Generates a random RFC 4122 version 4 UUID. |
| [`mock_email`](mock_email.md) | `mock_email [domain="example.com"]` | Generates a random dummy email address. |
| [`mock_phone`](mock_phone.md) | `mock_phone` | Generates a random US-style dummy phone number (+1-555-XXX-XXXX). |
| [`mock_date`](mock_date.md) | `mock_date [format="%Y-%m-%d"]` | Prints a formatted timestamp/date string (defaults to YYYY-MM-DD). |
| [`mock_jwt`](mock_jwt.md) | `mock_jwt [sub="mock-user"] [role="admin"]` | Generates a dummy 3-segment JWT token (header.payload.signature). Uses jwt_create if available, otherwise builds a valid base64url JWT. |
| [`mock_vault_token`](mock_vault_token.md) | `mock_vault_token [prefix="hvs."] [length=24]` | Generates a dummy HashiCorp Vault token (e.g., hvs.<alphanumeric>). |
| [`mock_array`](mock_array.md) | `mock_array [count=5] [array_name=MOCK_ARRAY] [item_type="string"]` | Populates a Zsh array variable with N dummy items of a given type. |
| [`mock_nested_array`](mock_nested_array.md) | `mock_nested_array [rows=3] [cols=3] [item_type="string"]` | Generates a JSON 2D nested array with the specified rows, columns, and element type. |
| [`mock_json`](mock_json.md) | `mock_json [depth=1] [keys_count=3]` | Generates a dummy JSON object with optional nested objects and nested arrays. |
| [`mock_json_user`](mock_json_user.md) | `mock_json_user` | Generates a realistic dummy user JSON payload including nested metadata, roles array, and tokens. |
| [`mock_command`](mock_command.md) | `mock_command <cmd_name> [stdout_output=""] [exit_code=0]` | Mocks a shell command or Zsh function with a static stdout response and exit code, tracking call counts and arguments. |
| [`mock_http_response`](mock_http_response.md) | `mock_http_response [body='{"ok":true}'] [status_code=200]` | Convenience helper that mocks curl to return a specified body and HTTP status code for 06-http.sh calls. |
| [`mock_get_call_count`](mock_get_call_count.md) | `mock_get_call_count <cmd_name>` | Prints the number of times a mocked command/function has been invoked. |
| [`mock_get_last_args`](mock_get_last_args.md) | `mock_get_last_args <cmd_name>` | Prints the argument string passed during the most recent call to a mocked command. |
| [`mock_was_called`](mock_was_called.md) | `mock_was_called <cmd_name> [expected_count]` | Checks whether a mocked command was called (at least once, or an exact expected count). |
| [`mock_restore`](mock_restore.md) | `mock_restore <cmd_name>` | Removes a mock for a command/function, restoring any previously saved Zsh function definition. |
| [`mock_restore_all`](mock_restore_all.md) | `mock_restore_all` | Restores all currently mocked commands/functions and clears all mock state. |
