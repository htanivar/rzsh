# Script Executory — Function Index

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../18-script-executory.md) › **18-script-executory/** › [Runnable Example](../../examples/18_script_executory_example.sh) › [Tests](../../tests/18-script-executory.test.sh)

- **Source File:** [`functions/18-script-executory.sh`](../../functions/18-script-executory.sh)
- **Runnable Example:** [`examples/18_script_executory_example.sh`](../../examples/18_script_executory_example.sh)

| Function | Signature | Description |
| :--- | :--- | :--- |
| [`validate_script_executable`](validate_script_executable.md) | `validate_script_executable <script_path>` | Resolves a script path and verifies it exists, is readable, and passes Zsh syntax check. |
| [`execute_script`](execute_script.md) | `execute_script <script_path> [args...]` | Executes a target script in a Zsh subprocess with optional arguments and logs timing/status. |
| [`execute_script_in_current_shell`](execute_script_in_current_shell.md) | `execute_script_in_current_shell <script_path> [args...]` | Sources a target script in the current shell so exported/global variables persist across steps. |
| [`execute_scripts_sequence`](execute_scripts_sequence.md) | `execute_scripts_sequence [--continue-on-error] [--source] [--dry-run] <scripts...>` | Executes multiple scripts sequentially in the specified order. |
| [`execute_scripts_from_file`](execute_scripts_from_file.md) | `execute_scripts_from_file <manifest_file> [flags...]` | Reads an ordered list of script paths from a manifest file (ignoring blank lines and # comments) and executes them sequentially. |
| [`execute_script_with_retry`](execute_script_with_retry.md) | `execute_script_with_retry <script_path> [max_retries=3] [delay_seconds=2] [args...]` | Executes a script and retries up to max_retries times if it returns a non-zero exit code. |
