# Logging Utility — Function Index

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../01-logs.md) › **01-logs/** › [Runnable Example](../../examples/01_logs_example.sh) › [Tests](../../tests/01-logs.test.sh)

- **Source File:** [`functions/01-logs.sh`](../../functions/01-logs.sh)
- **Runnable Example:** [`examples/01_logs_example.sh`](../../examples/01_logs_example.sh)

| Function | Signature | Description |
| :--- | :--- | :--- |
| [`init_logging`](init_logging.md) | `init_logging` | Initializes logging. Creates log directory and file with timestamp, and performs basic rotation (keeping last 5 logs). |
| [`log`](log.md) | `log <level> <message>` | Core log function formatting and writing output to console (stderr) and file. |
| [`log_info`](log_info.md) | `log_info <message>` | Logs an informational message. |
| [`log_error`](log_error.md) | `log_error <message>` | Logs an error message. |
| [`log_warn`](log_warn.md) | `log_warn <message>` | Logs a warning message. |
| [`log_debug`](log_debug.md) | `log_debug <message>` | Logs a debug message. |
| [`log_steps`](log_steps.md) | `log_steps <step_name>` | Logs progress tracking steps with an incrementing counter. |
| [`log_command`](log_command.md) | `log_command <command>` | Executes a command, logging both its execution start/end and redirecting its output to the log file. |
| [`log_section`](log_section.md) | `log_section <title>` | Logs a section header with border lines. |
