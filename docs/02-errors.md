# Error Handling Module Reference

- **Source File:** [`functions/02-errors.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/02-errors.sh)
- **Description:** Stack traces, termination signaling, and cleanup routines.

---

## Detailed Usage Examples

### Integration Setup
To use the Error Handling module, ensure the global configurations are initialized, then source the script file:

```zsh
source ./config/config.sh
init_config

source ./functions/02-errors.sh
```

---

## Function Signatures & Descriptions

### `error_exit`

* **Signature:** `error_exit <error_message> [exit_code]`
* **Description:** Logs a fatal error message, extracts and displays a complete function stack trace, deletes all registered temporary files, and exits the shell execution.

#### Example Code:
```zsh
error_exit "Critical configuration file missing" 1
```

---
### `register_temp_file`

* **Signature:** `register_temp_file <file_path>`
* **Description:** Registers a file or folder path to the global TEMP_FILES array. Upon script termination or failure, all registered files are purged.

#### Example Code:
```zsh
local tmp=$(mktemp)
register_temp_file "${tmp}" 
```

---
### `cleanup_temp_files`

* **Signature:** `cleanup_temp_files`
* **Description:** Purges all files registered via register_temp_file from the disk.

#### Example Code:
```zsh
cleanup_temp_files
```

---
