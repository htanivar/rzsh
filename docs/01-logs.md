# Logging Utility Module Reference

- **Source File:** [`functions/01-logs.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/01-logs.sh)
- **Description:** Formatted colored logging output and file logging.

---

## Detailed Usage Examples

### Integration Setup
To use the Logging Utility module, source the configuration script via `RZSH_DIR`, which automatically imports it:

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

---

## Module Variables (Keys)

| Variable Key | Description |
| :--- | :--- |
| `LOG_DIR` | Directory where log files are written (configured by `init_config`). |
| `LOG_LEVEL` | Minimum severity level to output (`DEBUG`, `INFO`, `WARN`, `ERROR`). |
| `SCRIPT_NAME` | Script basename used as prefix for the log filename. |
| `TIMESTAMP_FORMAT` | Timestamp format used on each log line. |
| `CURRENT_LOG_FILE` | Full path to the active log file set by `init_logging`. |
| `LOG_STEPS_COUNT` | Step counter incremented by `log_steps`. |

---

## Function Signatures & Descriptions

### `init_logging`

* **Signature:** `init_logging`
* **Description:** Ensures `LOG_DIR` exists, initializes `CURRENT_LOG_FILE`, and rotates older log files (keeping the 5 most recent).

#### Example Code:
```zsh
init_logging
```

---
### `log`

* **Signature:** `log <level> <message>`
* **Description:** Core logging function that formats a message with a timestamp and severity level (`INFO`, `WARN`, `ERROR`, `DEBUG`), prints it to the terminal, and appends it to `CURRENT_LOG_FILE`.

#### Example Code:
```zsh
log "INFO" "Custom log entry"
```

---
### `log_info / log_warn / log_error / log_debug`

* **Signature:** `log_info <message> / log_warn <message> / log_error <message> / log_debug <message>`
* **Description:** Outputs a color-coded log message to stdout and appends it to the log file prefixed with a timestamp.

#### Example Code:
```zsh
log_info "Server started on port 8080"
log_warn "Disk space is low"
log_error "Connection timeout reached" 
```

---
### `log_steps`

* **Signature:** `log_steps <step_name>`
* **Description:** Logs progress tracking steps with an automatically incrementing counter.

#### Example Code:
```zsh
log_steps "Initializing workspace"
```

---
### `log_command`

* **Signature:** `log_command <command_string>`
* **Description:** Executes a shell command, logs its stdout and stderr dynamically, and returns the exit status of the command.

#### Example Code:
```zsh
log_command "npm install"
```

---
### `log_section`

* **Signature:** `log_section <section_title>`
* **Description:** Prints a highly visible, styled section divider in the logs.

#### Example Code:
```zsh
log_section "DEPLOYMENT STAGE"
```

---
