# Mocking & Test Stubs Module Reference

**Navigation:** [README](../README.md) › [GLOSSARY](../GLOSSARY.md) › **17-mock.md** › [Example](../examples/17_mock_example.sh) › [Tests](../tests/17-mock.test.sh)

- **Source File:** [`functions/17-mock.sh`](../functions/17-mock.sh)
- **Example Script:** [`examples/17_mock_example.sh`](../examples/17_mock_example.sh)
- **Description:** Lightweight command and function mocking for offline testing and dry-run scripts, including call-count assertions, argument inspection, HTTP response stubbing, and clean restoration.

---

## Integration Setup

To use the Mocking module, source the configuration script via `RZSH_DIR`, which automatically imports all functions:

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

---

## Function Signatures & Descriptions

### `mock_command`

* **Signature:** `mock_command <cmd_name> [stdout_output=""] [exit_code=0]`
* **Description:** Overrides a shell command or Zsh function with a stub that prints `stdout_output`, returns `exit_code`, and records call counts and arguments. If `cmd_name` was an existing Zsh function, its original body is saved for `mock_restore`.

#### Example Code:
```zsh
mock_command "git" "main" 0
branch=$(git rev-parse --abbrev-ref HEAD)
mock_restore "git"
```

---
### `mock_http_response`

* **Signature:** `mock_http_response [body='{"ok":true}'] [status_code=200]`
* **Description:** Convenience wrapper that mocks `curl` to return a formatted HTTP body and trailing status code compatible with [`06-http.sh`](06-http.md) functions (`http_get`, `http_post`, etc.).

#### Example Code:
```zsh
mock_http_response '{"status":"healthy"}' 200
res=$(http_get "https://api.example.com/health")
mock_restore "curl"
```

---
### `mock_get_call_count / mock_get_last_args / mock_was_called`

* **Signature:** `mock_get_call_count <cmd_name>` / `mock_get_last_args <cmd_name>` / `mock_was_called <cmd_name> [expected_count]`
* **Description:** Inspects how many times a mocked command was invoked, retrieves the arguments from its last call, or asserts an exact/non-zero call count.

#### Example Code:
```zsh
count=$(mock_get_call_count "curl")
args=$(mock_get_last_args "curl")
mock_was_called "curl" 1
```

---
### `mock_restore / mock_restore_all`

* **Signature:** `mock_restore <cmd_name>` / `mock_restore_all`
* **Description:** Removes a mock (or all active mocks), restores any previously saved Zsh function definitions, and clears recorded call state.

#### Example Code:
```zsh
mock_restore "curl"
mock_restore_all
```
