# Script Executory Module Reference

**Navigation:** [README](../README.md) › [GLOSSARY](../GLOSSARY.md) › **18-script-executory.md** › [Example](../examples/18_script_executory_example.sh) › [Tests](../tests/18-script-executory.test.sh)

- **Source File:** [`functions/18-script-executory.sh`](../functions/18-script-executory.sh)
- **Description:** Validate and execute existing scripts sequentially (e.g., `login.sh` → `verify.sh` → `update.sh`), share state across sourced scripts, run manifest pipelines, or retry flaky scripts.

---

## Detailed Usage Examples

### Integration Setup
To use the Script Executory module, source the configuration script via `RZSH_DIR`, which automatically imports it:

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
init_logging
```

---

## Function Signatures & Descriptions

### `validate_script_executable`

* **Signature:** `validate_script_executable <script_path>`
* **Description:** Resolves a script path (directly, under `${RZSH_DIR}/scripts/`, or under `${PROJECT_ROOT}/`), verifies it exists and is readable, and runs `zsh -n` syntax validation for `.sh`/`.zsh` files.

#### Example Code:
```zsh
if validate_script_executable "./login.sh"; then
  echo "login.sh is ready to run"
fi
```

---
### `execute_script`

* **Signature:** `execute_script <script_path> [args...]`
* **Description:** Executes a target script in a Zsh subprocess with optional arguments, logging execution duration and exit status.

#### Example Code:
```zsh
execute_script "./login.sh" "--env" "prod" || error_exit "Login failed" 1
```

---
### `execute_script_in_current_shell`

* **Signature:** `execute_script_in_current_shell <script_path> [args...]`
* **Description:** Sources a target script in the current shell so exported or global variables (e.g., auth tokens) set by one script are available to subsequent scripts.

#### Example Code:
```zsh
execute_script_in_current_shell "./login.sh"
execute_script_in_current_shell "./verify.sh"
```

---
### `execute_scripts_sequence`

* **Signature:** `execute_scripts_sequence [--continue-on-error] [--source] [--dry-run] <script1> <script2> ...`
* **Description:** Executes multiple scripts in the specified order. Stops on the first failure by default (`fail-fast`), or runs all scripts when `--continue-on-error` is passed. Populates `SCRIPT_EXEC_SUMMARY` with per-script results.

#### Example Code:
```zsh
# Fail-fast sequential execution
execute_scripts_sequence "./login.sh" "./verify.sh" "./update.sh"

# Dry-run validation without executing
execute_scripts_sequence --dry-run "./login.sh" "./verify.sh" "./update.sh"

# Continue even if a step fails, sharing variables across steps
execute_scripts_sequence --continue-on-error --source "./login.sh" "./verify.sh" "./update.sh"
```

---
### `execute_scripts_from_file`

* **Signature:** `execute_scripts_from_file <manifest_file> [flags...]`
* **Description:** Reads an ordered list of script paths from a manifest file (ignoring blank lines and `#` comments) and executes them via `execute_scripts_sequence`.

#### Example Code:
```zsh
# pipeline.txt contains:
#   ./login.sh
#   ./verify.sh
#   ./update.sh
execute_scripts_from_file "./pipeline.txt"
```

---
### `execute_script_with_retry`

* **Signature:** `execute_script_with_retry <script_path> [max_retries=3] [delay_seconds=2] [args...]`
* **Description:** Executes a script and retries up to `max_retries` times with `delay_seconds` between attempts if it exits non-zero.

#### Example Code:
```zsh
execute_script_with_retry "./login.sh" 3 1 "--env" "staging"
```
