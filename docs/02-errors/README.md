# Error Handling — Function Index

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../02-errors.md) › **02-errors/** › [Runnable Example](../../examples/02_errors_example.sh) › [Tests](../../tests/02-errors.test.sh)

- **Source File:** [`functions/02-errors.sh`](../../functions/02-errors.sh)
- **Runnable Example:** [`examples/02_errors_example.sh`](../../examples/02_errors_example.sh)

| Function | Signature | Description |
| :--- | :--- | :--- |
| [`error_exit`](error_exit.md) | `error_exit <message> [exit_code=1]` | Logs a fatal error message, prints the current call stack trace, cleans up registered temporary files, and exits the script. |
| [`register_temp_file`](register_temp_file.md) | `register_temp_file <file_path>` | Registers a file or directory path for automatic cleanup. |
| [`cleanup_temp_files`](cleanup_temp_files.md) | `cleanup_temp_files` | Cleans up (deletes) all registered temporary files from disk. |
