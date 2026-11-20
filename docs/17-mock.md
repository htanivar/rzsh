# Mocking & Test Data Module Reference

**Navigation:** [README](../README.md) › [GLOSSARY](../GLOSSARY.md) › **17-mock.md** › [Example](../examples/17_mock_example.sh) › [Tests](../tests/17-mock.test.sh)

- **Source File:** [`functions/17-mock.sh`](../functions/17-mock.sh)
- **Example Script:** [`examples/17_mock_example.sh`](../examples/17_mock_example.sh)
- **Description:** Comprehensive dummy data generators (strings, alphanumeric, passwords, integers, booleans, UUIDs, emails, phones, dates, JWTs, Vault tokens, arrays, nested 2D arrays, and nested JSON payloads) plus command/HTTP mocking utilities.

---

## Integration Setup

To use the Mocking & Test Data module, source the configuration script via `RZSH_DIR`, which automatically imports all functions:

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

---

## Dummy Data Generators

### `mock_string / mock_alphanumeric / mock_password`

* **Signature:** `mock_string [length=12] [prefix=""]` / `mock_alphanumeric [length=16]` / `mock_password [length=16] [include_special=1]`
* **Description:** Generates random alphabetic strings, alphanumeric IDs, or strong passwords (with guaranteed character-class diversity).

```zsh
local name=$(mock_string 8 "user_")
local code=$(mock_alphanumeric 16)
local pass=$(mock_password 16 1)
```

---
### `mock_int / mock_bool / mock_uuid / mock_email / mock_phone / mock_date`

* **Signature:** `mock_int [min=1] [max=1000]` / `mock_bool` / `mock_uuid` / `mock_email [domain="example.com"]` / `mock_phone` / `mock_date [format="%Y-%m-%d"]`
* **Description:** Generates random integers, booleans (`true`/`false`), RFC 4122 v4 UUIDs, emails, US-style phone numbers, and UTC timestamps.

```zsh
local port=$(mock_int 8000 9000)
local id=$(mock_uuid)
local mail=$(mock_email "acme.test")
```

---
### `mock_jwt / mock_vault_token`

* **Signature:** `mock_jwt [sub="mock-user"] [role="admin"]` / `mock_vault_token [prefix="hvs."] [length=24]`
* **Description:** Generates a 3-segment base64url JWT token (`header.payload.signature`) or a HashiCorp Vault-style token (`hvs.<random>`).

```zsh
local jwt=$(mock_jwt "alice" "developer")
local vtok=$(mock_vault_token)
```

---
### `mock_array / mock_nested_array`

* **Signature:** `mock_array [count=5] [array_name=MOCK_ARRAY] [item_type="string"]` / `mock_nested_array [rows=3] [cols=3] [item_type="string"]`
* **Description:** `mock_array` populates a Zsh array variable with `count` dummy items (`string`, `alphanumeric`, `int`, `bool`, `email`, `uuid`, `token`, `password`). `mock_nested_array` outputs a JSON 2D nested array.

```zsh
local -a emails
mock_array 3 "emails" "email"
local matrix=$(mock_nested_array 2 3 "int")
```

---
### `mock_json / mock_json_user`

* **Signature:** `mock_json [depth=1] [keys_count=3]` / `mock_json_user`
* **Description:** Generates a dummy JSON object (with nested objects and nested arrays when `depth > 1`), or a realistic dummy user payload with nested `meta`, `roles`, and `token`.

```zsh
local nested=$(mock_json 2 3)
local user_payload=$(mock_json_user)
```

---

## Command & HTTP Stubbing

### `mock_command / mock_http_response`

* **Signature:** `mock_command <cmd_name> [stdout_output=""] [exit_code=0]` / `mock_http_response [body='{"ok":true}'] [status_code=200]`
* **Description:** Overrides a shell command or Zsh function with a stub that prints `stdout_output` and returns `exit_code`, or stubs `curl` for `06-http.sh`.

```zsh
mock_command "git" "main" 0
mock_http_response '{"status":"healthy"}' 200
```

---
### `mock_get_call_count / mock_get_last_args / mock_was_called`

* **Signature:** `mock_get_call_count <cmd_name>` / `mock_get_last_args <cmd_name>` / `mock_was_called <cmd_name> [expected_count]`
* **Description:** Inspects invocation counts (including calls made inside `$(...)` subshells) and last-call arguments.

---
### `mock_restore / mock_restore_all`

* **Signature:** `mock_restore <cmd_name>` / `mock_restore_all`
* **Description:** Removes mocks, restores any previously saved Zsh function definitions, and clears mock state.

---

## Per-Function Copy-Paste Reference

Browse dedicated per-function pages with all flags and copy-paste variations in [`docs/17-mock/`](17-mock/README.md), or run [`examples/17_mock_example.sh`](../examples/17_mock_example.sh).

| Function | Per-Function Docs & Flags | Runnable Example |
| :--- | :--- | :--- |
| `mock_string` | [Docs & Examples](17-mock/mock_string.md) | [`17_mock_example.sh`](../examples/17_mock_example.sh) |
| `mock_alphanumeric` | [Docs & Examples](17-mock/mock_alphanumeric.md) | [`17_mock_example.sh`](../examples/17_mock_example.sh) |
| `mock_password` | [Docs & Examples](17-mock/mock_password.md) | [`17_mock_example.sh`](../examples/17_mock_example.sh) |
| `mock_int` | [Docs & Examples](17-mock/mock_int.md) | [`17_mock_example.sh`](../examples/17_mock_example.sh) |
| `mock_bool` | [Docs & Examples](17-mock/mock_bool.md) | [`17_mock_example.sh`](../examples/17_mock_example.sh) |
| `mock_uuid` | [Docs & Examples](17-mock/mock_uuid.md) | [`17_mock_example.sh`](../examples/17_mock_example.sh) |
| `mock_email` | [Docs & Examples](17-mock/mock_email.md) | [`17_mock_example.sh`](../examples/17_mock_example.sh) |
| `mock_phone` | [Docs & Examples](17-mock/mock_phone.md) | [`17_mock_example.sh`](../examples/17_mock_example.sh) |
| `mock_date` | [Docs & Examples](17-mock/mock_date.md) | [`17_mock_example.sh`](../examples/17_mock_example.sh) |
| `mock_jwt` | [Docs & Examples](17-mock/mock_jwt.md) | [`17_mock_example.sh`](../examples/17_mock_example.sh) |
| `mock_vault_token` | [Docs & Examples](17-mock/mock_vault_token.md) | [`17_mock_example.sh`](../examples/17_mock_example.sh) |
| `mock_array` | [Docs & Examples](17-mock/mock_array.md) | [`17_mock_example.sh`](../examples/17_mock_example.sh) |
| `mock_nested_array` | [Docs & Examples](17-mock/mock_nested_array.md) | [`17_mock_example.sh`](../examples/17_mock_example.sh) |
| `mock_json` | [Docs & Examples](17-mock/mock_json.md) | [`17_mock_example.sh`](../examples/17_mock_example.sh) |
| `mock_json_user` | [Docs & Examples](17-mock/mock_json_user.md) | [`17_mock_example.sh`](../examples/17_mock_example.sh) |
| `mock_command` | [Docs & Examples](17-mock/mock_command.md) | [`17_mock_example.sh`](../examples/17_mock_example.sh) |
| `mock_http_response` | [Docs & Examples](17-mock/mock_http_response.md) | [`17_mock_example.sh`](../examples/17_mock_example.sh) |
| `mock_get_call_count` | [Docs & Examples](17-mock/mock_get_call_count.md) | [`17_mock_example.sh`](../examples/17_mock_example.sh) |
| `mock_get_last_args` | [Docs & Examples](17-mock/mock_get_last_args.md) | [`17_mock_example.sh`](../examples/17_mock_example.sh) |
| `mock_was_called` | [Docs & Examples](17-mock/mock_was_called.md) | [`17_mock_example.sh`](../examples/17_mock_example.sh) |
| `mock_restore` | [Docs & Examples](17-mock/mock_restore.md) | [`17_mock_example.sh`](../examples/17_mock_example.sh) |
| `mock_restore_all` | [Docs & Examples](17-mock/mock_restore_all.md) | [`17_mock_example.sh`](../examples/17_mock_example.sh) |