# Logging Utility Module Reference

- **Source File:** [`functions/01-logs.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/01-logs.sh)
- **Description:** Formatted colored logging output and file logging.

---

## Detailed Usage Examples

### Integration Setup
To use the Logging Utility module, you only need to source the configuration script, which automatically imports it:

```zsh
source ./config/config.sh
init_config
```

---

## Function Signatures & Descriptions

### `init_logging`

* **Signature:** `init_logging`
* **Description:** Ensures the log directory exists and prepares log files.

#### Example Code:
```zsh
init_logging
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
