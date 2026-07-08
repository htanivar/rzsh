# Input & Format Validation Module Reference

- **Source File:** [`functions/04-validation.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/04-validation.sh)
- **Description:** Format checkers for data structures, numbers, urls, dates, and JWTs.

---

## Detailed Usage Examples

### Integration Setup
To use the Input & Format Validation module, ensure the global configurations are initialized, then source the script file:

```zsh
source ./config/config.sh
init_config

source ./functions/04-validation.sh
```

---

## Function Signatures & Descriptions

### `validate_required`

* **Signature:** `validate_required <value>`
* **Description:** Checks if a string argument is non-empty and contains non-whitespace characters.

#### Example Code:
```zsh
validate_required "${username}" || error_exit "Username is required"
```

---
### `validate_in_list`

* **Signature:** `validate_in_list <value> <comma_separated_list>`
* **Description:** Verifies if the specified value is part of a list of allowed options.

#### Example Code:
```zsh
validate_in_list "${role}" "admin,user,guest"
```

---
### `validate_file_exists / validate_directory_exists`

* **Signature:** `validate_file_exists <path> / validate_directory_exists <path>`
* **Description:** Returns 0 if the path points to an existing file/directory, 1 otherwise.

#### Example Code:
```zsh
validate_file_exists "/etc/hosts"
```

---
### `validate_is_number`

* **Signature:** `validate_is_number <value>`
* **Description:** Checks if the value is a valid integer (including negatives).

#### Example Code:
```zsh
validate_is_number "${age}"
```

---
### `validate_email`

* **Signature:** `validate_email <value>`
* **Description:** Checks if the value matches a standard email format.

#### Example Code:
```zsh
validate_email "test@domain.com"
```

---
### `validate_url`

* **Signature:** `validate_url <value>`
* **Description:** Checks if the value is a valid HTTP/HTTPS URL.

#### Example Code:
```zsh
validate_url "https://github.com"
```

---
### `validate_command_exists`

* **Signature:** `validate_command_exists <command_name>`
* **Description:** Returns 0 if the command exists in the shell path.

#### Example Code:
```zsh
validate_command_exists "curl"
```

---
### `validate_date`

* **Signature:** `validate_date <value>`
* **Description:** Returns 0 if the value is a valid date (YYYY-MM-DD) parseable by system date commands.

#### Example Code:
```zsh
validate_date "2026-07-08"
```

---
### `validate_jwt`

* **Signature:** `validate_jwt <value>`
* **Description:** Performs Zsh native glob validation on a JWT string structure (expects header.payload.signature).

#### Example Code:
```zsh
validate_jwt "${jwt_token}"
```

---
### `validate_json`

* **Signature:** `validate_json <value>`
* **Description:** Checks if a string is a valid JSON document (using jq when available).

#### Example Code:
```zsh
validate_json '{"status":"ok"}'
```

---
