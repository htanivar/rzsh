# Input & Format Validation — Function Index

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../04-validation.md) › **04-validation/** › [Runnable Example](../../examples/04_validation_example.sh) › [Tests](../../tests/04-validation.test.sh)

- **Source File:** [`functions/04-validation.sh`](../../functions/04-validation.sh)
- **Runnable Example:** [`examples/04_validation_example.sh`](../../examples/04_validation_example.sh)

| Function | Signature | Description |
| :--- | :--- | :--- |
| [`validate_required`](validate_required.md) | `validate_required <var> [message="Value is required"]` | Validates that a variable value is not empty. |
| [`validate_in_list`](validate_in_list.md) | `validate_in_list <value> <list>` | Validates that a value exists in a space- or comma-separated list. |
| [`validate_file_exists`](validate_file_exists.md) | `validate_file_exists <file_path>` | Validates that a file exists at the given path. |
| [`validate_directory_exists`](validate_directory_exists.md) | `validate_directory_exists <dir_path>` | Validates that a directory exists at the given path. |
| [`validate_is_number`](validate_is_number.md) | `validate_is_number <value>` | Validates that a value is a number (integer or decimal, positive or negative). |
| [`validate_email`](validate_email.md) | `validate_email <email>` | Validates that a string matches a basic email regex pattern. |
| [`validate_url`](validate_url.md) | `validate_url <url>` | Validates that a string is a valid HTTP/HTTPS URL. |
| [`validate_command_exists`](validate_command_exists.md) | `validate_command_exists <command>` | Validates that an external command/executable is available in the current PATH. |
| [`validate_date`](validate_date.md) | `validate_date <date_string>` | Validates that a date string is valid and parseable. |
| [`validate_jwt`](validate_jwt.md) | `validate_jwt <token>` | Validates that a token has the correct structural format of a JWT (header.payload.signature). |
| [`validate_json`](validate_json.md) | `validate_json <json_string>` | Validates that a string is a valid JSON document (using jq if available). |
