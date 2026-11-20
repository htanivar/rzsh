# Input & Format Validation Module Reference

**Navigation:** [README](../README.md) › [GLOSSARY](../GLOSSARY.md) › **04-validation.md** › [Example](../examples/04_validation_example.sh) › [Tests](../tests/04-validation.test.sh)

- **Source File:** [`functions/04-validation.sh`](../functions/04-validation.sh)
- **Description:** Format checkers for data structures, numbers, urls, dates, and JWTs.

---

## Detailed Usage Examples

### Integration Setup
To use the Input & Format Validation module, source the configuration script via `RZSH_DIR`, which automatically imports it:

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

### How Verification Works (Positive & Negative Checks)
Every `validate_*` function follows standard shell exit-code conventions:
- **Returns `0`** when the check passes (valid).
- **Returns `1`** when the check fails (invalid).

You can verify inputs using standard Zsh conditionals:
```zsh
# 1. Branch on success or failure (if / else)
if validate_in_list "${role}" "admin,user,guest"; then
  echo "Access granted for role: ${role}"
else
  echo "Invalid role '${role}'. Allowed: admin, user, guest" >&2
fi

# 2. Fail fast on invalid input (||)
validate_in_list "${role}" "admin,user,guest" || return 1

# 3. Negative check (!): act only when validation fails
if ! validate_in_list "${role}" "admin,user,guest"; then
  log_error "Unsupported role: ${role}"
fi
```

---

## Function Signatures & Descriptions

### `validate_required`

* **Signature:** `validate_required <value> [message]`
* **Description:** Checks if a string argument is non-empty. If empty, logs `[message]` (defaults to `"Value is required"`) via `log_error` (or stderr) and returns `1`.

#### Example Code:
```zsh
# Positive: non-empty value passes
username="alice"
if validate_required "${username}" "Username is required"; then
  echo "Username set to: ${username}"
fi

# Negative: empty value logs an error and returns 1
username=""
validate_required "${username}" "Username is required" || echo "Caught missing username (exit code: $?)"
```

---
### `validate_in_list`

* **Signature:** `validate_in_list <value> <comma_or_space_separated_list>`
* **Description:** Verifies if the specified value is part of a list of allowed options (supports comma-separated or space-separated lists). Returns `0` if found, `1` otherwise.

#### Example Code:
```zsh
# Positive: value is in the allowed list
role="admin"
if validate_in_list "${role}" "admin,user,guest"; then
  echo "Valid role: ${role}"
fi

# Negative: value is NOT in the allowed list
role="moderator"
if ! validate_in_list "${role}" "admin,user,guest"; then
  echo "Invalid role '${role}': must be one of admin, user, guest" >&2
fi

# Space-separated list with fallback
env="qa"
validate_in_list "${env}" "dev staging prod" || echo "Unknown environment '${env}', defaulting to 'dev'"
```

---
### `validate_file_exists / validate_directory_exists`

* **Signature:** `validate_file_exists <path> / validate_directory_exists <path>`
* **Description:** Returns `0` if the path points to an existing file/directory, `1` otherwise.

#### Example Code:
```zsh
# Positive: existing file and directory
validate_file_exists "/etc/hosts" && echo "Hosts file found"
validate_directory_exists "/tmp" && echo "/tmp directory exists"

# Negative: missing file or directory
if ! validate_file_exists "/tmp/missing_config.env"; then
  echo "Config file not found; creating default..." >&2
fi

if ! validate_directory_exists "/nonexistent/output_dir"; then
  echo "Output directory does not exist" >&2
fi
```

---
### `validate_is_number`

* **Signature:** `validate_is_number <value>`
* **Description:** Checks if the value is a valid number (positive/negative integer or decimal).

#### Example Code:
```zsh
# Positive: integers, negatives, and decimals pass
validate_is_number "42" && echo "Valid integer"
validate_is_number "-12.5" && echo "Valid negative decimal"

# Negative: non-numeric text fails
age="twenty"
if ! validate_is_number "${age}"; then
  echo "Invalid age '${age}': expected a number" >&2
fi
```

---
### `validate_email`

* **Signature:** `validate_email <value>`
* **Description:** Checks if the value matches a standard email format.

#### Example Code:
```zsh
# Positive
validate_email "test@domain.com" && echo "Valid email"

# Negative
email="not-an-email"
if ! validate_email "${email}"; then
  echo "Rejected malformed email: ${email}" >&2
fi
```

---
### `validate_url`

* **Signature:** `validate_url <value>`
* **Description:** Checks if the value is a valid HTTP/HTTPS URL.

#### Example Code:
```zsh
# Positive
validate_url "https://github.com" && echo "Valid URL"

# Negative (missing http:// or https:// scheme)
url="github.com"
if ! validate_url "${url}"; then
  echo "Invalid URL '${url}': must start with http:// or https://" >&2
fi
```

---
### `validate_command_exists`

* **Signature:** `validate_command_exists <command_name>`
* **Description:** Returns `0` if the command exists in the shell `PATH`, `1` otherwise.

#### Example Code:
```zsh
# Positive
validate_command_exists "ls" && echo "'ls' is available"

# Negative: guard against missing dependencies
if ! validate_command_exists "nonexistent_cli_tool"; then
  echo "Required tool 'nonexistent_cli_tool' is not installed" >&2
fi
```

---
### `validate_date`

* **Signature:** `validate_date <value>`
* **Description:** Returns `0` if the value is a valid date (`YYYY-MM-DD`) parseable by system date commands, `1` otherwise.

#### Example Code:
```zsh
# Positive
validate_date "2026-07-08" && echo "Valid date"

# Negative
date_input="invalid-date"
if ! validate_date "${date_input}"; then
  echo "Invalid date '${date_input}': expected YYYY-MM-DD" >&2
fi
```

---
### `validate_jwt`

* **Signature:** `validate_jwt <value>`
* **Description:** Performs Zsh native glob validation on a JWT string structure (expects `header.payload.signature`).

#### Example Code:
```zsh
# Positive
validate_jwt "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjMifQ.signature123" && echo "Valid JWT structure"

# Negative
jwt_token="missing_segments"
if ! validate_jwt "${jwt_token}"; then
  echo "Invalid JWT structure: expected header.payload.signature" >&2
fi
```

---
### `validate_json`

* **Signature:** `validate_json <value>`
* **Description:** Checks if a string is a valid JSON document (using `jq` when available, or basic brace/bracket matching as fallback).

#### Example Code:
```zsh
# Positive
validate_json '{"status":"ok"}' && echo "Valid JSON"

# Negative
payload='{"status": broken}'
if ! validate_json "${payload}"; then
  echo "Invalid JSON payload" >&2
fi
```

---

---

## Per-Function Copy-Paste Reference

Browse dedicated per-function pages with all flags and copy-paste variations in [`docs/04-validation/`](04-validation/README.md), or run [`examples/04_validation_example.sh`](../examples/04_validation_example.sh).

| Function | Per-Function Docs & Flags | Runnable Example |
| :--- | :--- | :--- |
| `validate_required` | [Docs & Examples](04-validation/validate_required.md) | [`04_validation_example.sh`](../examples/04_validation_example.sh) |
| `validate_in_list` | [Docs & Examples](04-validation/validate_in_list.md) | [`04_validation_example.sh`](../examples/04_validation_example.sh) |
| `validate_file_exists` | [Docs & Examples](04-validation/validate_file_exists.md) | [`04_validation_example.sh`](../examples/04_validation_example.sh) |
| `validate_directory_exists` | [Docs & Examples](04-validation/validate_directory_exists.md) | [`04_validation_example.sh`](../examples/04_validation_example.sh) |
| `validate_is_number` | [Docs & Examples](04-validation/validate_is_number.md) | [`04_validation_example.sh`](../examples/04_validation_example.sh) |
| `validate_email` | [Docs & Examples](04-validation/validate_email.md) | [`04_validation_example.sh`](../examples/04_validation_example.sh) |
| `validate_url` | [Docs & Examples](04-validation/validate_url.md) | [`04_validation_example.sh`](../examples/04_validation_example.sh) |
| `validate_command_exists` | [Docs & Examples](04-validation/validate_command_exists.md) | [`04_validation_example.sh`](../examples/04_validation_example.sh) |
| `validate_date` | [Docs & Examples](04-validation/validate_date.md) | [`04_validation_example.sh`](../examples/04_validation_example.sh) |
| `validate_jwt` | [Docs & Examples](04-validation/validate_jwt.md) | [`04_validation_example.sh`](../examples/04_validation_example.sh) |
| `validate_json` | [Docs & Examples](04-validation/validate_json.md) | [`04_validation_example.sh`](../examples/04_validation_example.sh) |