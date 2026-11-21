# RZSH Framework Glossary

**Navigation:** [README](README.md) › [CHEATSHEET](CHEATSHEET.md) › **GLOSSARY** › Select a module below for **Docs**, **Examples**, and **Tests**

Quick-reference catalog of every **environment/global variable** set by the `rzsh` framework and every **function** available across all modules. New to Zsh? Start with the [**`CHEATSHEET.md`**](CHEATSHEET.md) for beginner copy-paste recipes (1D/2D arrays, conversions, loops, and common tasks).

> **Tip:** Set `export RZSH_DIR="/path/to/rzsh"` in your `~/.zshrc`, then add two lines at the top of any script to unlock every variable and function listed below:
> ```zsh
> source "${RZSH_DIR}/config/config.sh"
> init_config
> ```

---

## Index

- [1. Variables Set by the Framework](#1-variables-set-by-the-framework)
  - [Core Configuration Variables](#core-configuration-variables-configconfigsh)
  - [Module Runtime State Variables](#module-runtime-state-variables)
- [2. Functions Available in the Framework](#2-functions-available-in-the-framework)
  - [00. Global Configuration](#00-global-configuration-configconfigsh--docs--example)
  - [01. Logging Utility](#01-logging-utility-functions01-logssh--docs--example--tests)
  - [02. Error Handling](#02-error-handling-functions02-errorssh--docs--example--tests)
  - [03. Navigation & Paths](#03-navigation--paths-functions03-navigationsh--docs--example--tests)
  - [04. Input & Format Validation](#04-input--format-validation-functions04-validationsh--docs--example--tests)
  - [05. Git Operations](#05-git-operations-functions05-gitsh--docs--example--tests)
  - [06. HTTP Client Wrapper](#06-http-client-wrapper-functions06-httpsh--docs--example--tests)
  - [07. Interactive User Prompts](#07-interactive-user-prompts-functions07-user-actionssh--docs--example--tests)
  - [08. Date & Time Utilities](#08-date--time-utilities-functions08-datetimesh--docs--example--tests)
  - [09. File Operations](#09-file-operations-functions09-filesh--docs--example--tests)
  - [10. Directory Management](#10-directory-management-functions10-directorysh--docs--example--tests)
  - [11. String Manipulation](#11-string-manipulation-functions11-stringsh--docs--example--tests)
  - [12. SSH & SCP Client](#12-ssh--scp-client-functions12-sshsh--docs--example--tests)
  - [13. JSON Web Tokens (JWT)](#13-json-web-tokens-jwt-functions13-jwtsh--docs--example--tests)
  - [14. JSON Parsing & JQ](#14-json-parsing--jq-functions14-jqsh--docs--example--tests)
  - [15. Dynamic Variables & Repo Registry](#15-dynamic-variables--repo-registry-functions15-variablessh--docs--example--tests)
  - [16. Data Masking & Redaction](#16-data-masking--redaction-functions16-masksh--docs--example--tests)
  - [17. Mocking & Test Stubs](#17-mocking--test-stubs-functions17-mocksh--docs--example--tests)
  - [18. Script Executory](#18-script-executory-functions18-script-executorysh--docs--example--tests)
  - [19. Secrets & Token Cache](#19-secrets--token-cache-functions19-cachesh--docs--example--tests)
  - [99. Evidence Collector](#99-evidence-collector-functions99-evidencessh--docs--example--tests)

---

## 1. Variables Set by the Framework

The table below lists all variable keys initialized or managed by the framework (values are omitted for security and clarity).

### Core Configuration Variables ([`config/config.sh`](config/config.sh))

| Variable Key | Type | Exported by `init_config` | Description |
| :--- | :--- | :---: | :--- |
| `RZSH_DIR` | String (Path) | Yes | Root installation directory of the `rzsh` framework. Used to source `${RZSH_DIR}/config/config.sh` from any script. |
| `PROJECT_ROOT` | String (Path) | Yes | Root directory of the active project (defaults to `RZSH_DIR` if not pre-set). |
| `LOG_LEVEL` | String | Yes | Active logging verbosity threshold (`DEBUG`, `INFO`, `WARN`, `ERROR`). |
| `LOG_DIR` | String (Path) | Yes | Directory where rotating script log files are stored. |
| `SCRIPT_NAME` | String | Yes | Basename of the currently running script, used when naming log files. |
| `TIMESTAMP_FORMAT` | String | Yes | Date/time format string used for log entries and timestamps. |
| `DATE_FORMAT` | String | Yes | Calendar date format string used by date helper functions. |
| `JWT_SECRET` | String (Secret) | Yes | Default HMAC-SHA256 secret key used by JWT signing and verification functions. |
| `EVIDENCE_DIR` | String (Path) | Yes | Base directory where audit and execution evidence folders are generated. |
| `SECRETS_DIR` | String (Path) | Yes | Base directory (`.secrets.d` by default) where cached secrets and tokens are stored by [`19-cache.sh`](functions/19-cache.sh). |
| `RAVI_DIR` | String (Path) | Yes | Optional custom workspace directory variable for user scripts. |
| `GIT_IGNORE_FOLDERS` | String (CSV) | Yes | Comma-separated list of folder names excluded during Git branch comparisons. |
| `HTTP_CONTENT_TYPE` | String | Yes | Default `Content-Type` HTTP header value (defaults to `application/json`). |
| `HTTP_ACCEPT` | String | Yes | Default `Accept` HTTP header value (defaults to `application/json`). |
| `HTTP_AUTH_TOKEN` | String (Secret) | Yes | Optional Bearer token used to populate `Authorization: Bearer <token>` in `HTTP_DEFAULT_HEADERS`. |
| `HTTP_VAULT_TOKEN` | String (Secret) | Yes | Optional HashiCorp Vault token used to populate `X-Vault-Token` in `HTTP_DEFAULT_HEADERS`. |
| `HTTP_VAULT_REQUEST` | String | Yes | Optional flag (e.g., `true`) used to populate `X-Vault-Request` in `HTTP_DEFAULT_HEADERS`. |
| `HTTP_DEFAULT_HEADERS` | String (Newline-separated) | Yes | Newline-separated `"Key: Value"` default HTTP headers merged into requests by `http_build_headers`. |
| `REPO_NAMES` | Array (`typeset -g -a`) | Global | List of registered repository identifiers managed by [`15-variables.sh`](functions/15-variables.sh). |
| `REPO_LOCATIONS` | Associative Array (`typeset -g -A`) | Global | Key-value map of repository names to their local filesystem paths. |

### Module Runtime State Variables

| Variable Key | Module | Type | Description |
| :--- | :--- | :--- | :--- |
| `CURRENT_LOG_FILE` | [`functions/01-logs.sh`](functions/01-logs.sh) | String (Path) | Full file path of the active log file created by `init_logging`. |
| `LOG_STEPS_COUNT` | [`functions/01-logs.sh`](functions/01-logs.sh) | Integer | Sequential counter incremented each time `log_steps` is called. |
| `TEMP_FILES` | [`functions/02-errors.sh`](functions/02-errors.sh) | Array (`typeset -g -a`) | List of temporary files/directories registered via `register_temp_file` for automatic cleanup. |
| `CURRENT_EVIDENCE_DIR` | [`functions/99-evidences.sh`](functions/99-evidences.sh) | String (Path) | Path to the active timestamped evidence session directory created by `init_evidence`. |

---

## 2. Functions Available in the Framework

### 00. Global Configuration ([`config/config.sh`](config/config.sh) | [Docs](docs/00-config.md) | [Example](examples/00_config_example.sh))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| [`init_config`](docs/00-config/init_config.md) | `init_config` | Initializes and exports all global framework variables with safe defaults and loads all modules. |

[↑ Back to Index](#index)

### 01. Logging Utility ([`functions/01-logs.sh`](functions/01-logs.sh) | [Docs](docs/01-logs.md) | [Example](examples/01_logs_example.sh) | [Tests](tests/01-logs.test.sh))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| [`init_logging`](docs/01-logs/init_logging.md) | `init_logging` | Creates the log directory, initializes the timestamped log file, and rotates old logs (keeps last 5). |
| [`log`](docs/01-logs/log.md) | `log <level> <message>` | Core logger that writes formatted, color-coded messages to console and `CURRENT_LOG_FILE`. |
| [`log_info`](docs/01-logs/log_info.md) | `log_info <message>` | Logs an informational (`INFO`) message in green. |
| [`log_warn`](docs/01-logs/log_warn.md) | `log_warn <message>` | Logs a warning (`WARN`) message in yellow. |
| [`log_error`](docs/01-logs/log_error.md) | `log_error <message>` | Logs an error (`ERROR`) message in red to `stderr` and the log file. |
| [`log_debug`](docs/01-logs/log_debug.md) | `log_debug <message>` | Logs a debug (`DEBUG`) message in blue when `LOG_LEVEL=DEBUG`. |
| [`log_steps`](docs/01-logs/log_steps.md) | `log_steps <message>` | Increments `LOG_STEPS_COUNT` and logs a numbered step (`Step N: <message>`). |
| [`log_command`](docs/01-logs/log_command.md) | `log_command <command_string>` | Executes a shell command, logs its output and exit code, and returns the exit status. |
| [`log_section`](docs/01-logs/log_section.md) | `log_section <title>` | Prints a prominent banner header in the terminal and log file to separate workflow stages. |

[↑ Back to Index](#index)

### 02. Error Handling ([`functions/02-errors.sh`](functions/02-errors.sh) | [Docs](docs/02-errors.md) | [Example](examples/02_errors_example.sh) | [Tests](tests/02-errors.test.sh))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| [`error_exit`](docs/02-errors/error_exit.md) | `error_exit <message> [exit_code=1]` | Logs a fatal error with stack trace, cleans up registered temporary files, and exits the script. |
| [`register_temp_file`](docs/02-errors/register_temp_file.md) | `register_temp_file <file_path>` | Registers a temporary file or folder in `TEMP_FILES` for automatic removal on cleanup/exit. |
| [`cleanup_temp_files`](docs/02-errors/cleanup_temp_files.md) | `cleanup_temp_files` | Deletes all files/directories registered in `TEMP_FILES` and clears the list. |

[↑ Back to Index](#index)

### 03. Navigation & Paths ([`functions/03-navigation.sh`](functions/03-navigation.sh) | [Docs](docs/03-navigation.md) | [Example](examples/03_navigation_example.sh) | [Tests](tests/03-navigation.test.sh))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| [`current_directory`](docs/03-navigation/current_directory.md) | `current_directory` | Prints the absolute path of the current working directory. |
| [`get_current_directory`](docs/03-navigation/get_current_directory.md) | `get_current_directory` | Alias for `current_directory`; prints the resolved current working directory. |
| [`dir_up`](docs/03-navigation/dir_up.md) | `dir_up [levels=1]` | Prints the path N parent directories up from the current directory. |
| [`absolute_path`](docs/03-navigation/absolute_path.md) | `absolute_path [target_path="."]` | Resolves any relative path or symlink into a canonical absolute path. |
| [`get_absolute_path`](docs/03-navigation/get_absolute_path.md) | `get_absolute_path [target_path="."]` | Alias for `absolute_path`; resolves a path to its canonical absolute form. |
| [`to_project_root`](docs/03-navigation/to_project_root.md) | `to_project_root` | Changes the current working directory (`cd`) to `PROJECT_ROOT`. |
| [`get_project_root`](docs/03-navigation/get_project_root.md) | `get_project_root` | Prints the `PROJECT_ROOT` path, or detects the enclosing Git repository root. |
| [`is_inside_git_repo`](docs/03-navigation/is_inside_git_repo.md) | `is_inside_git_repo` | Returns `0` if the current working directory is inside a Git working tree. |
| [`normalize_path`](docs/03-navigation/normalize_path.md) | `normalize_path <path>` | Normalizes path segments (`..`, `.`, duplicate slashes) without requiring the path to exist. |
| [`ensure_directory_exists`](docs/03-navigation/ensure_directory_exists.md) | `ensure_directory_exists <dir_path>` | Creates a directory and any missing parent directories if it does not already exist. |
| [`change_directory`](docs/03-navigation/change_directory.md) | `change_directory <dir_path>` | Safely changes into a target directory, returning `1` if the directory is missing or invalid. |

[↑ Back to Index](#index)

### 04. Input & Format Validation ([`functions/04-validation.sh`](functions/04-validation.sh) | [Docs](docs/04-validation.md) | [Example](examples/04_validation_example.sh) | [Tests](tests/04-validation.test.sh))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| [`validate_required`](docs/04-validation/validate_required.md) | `validate_required <value> [error_msg]` | Checks that a value is non-empty; logs an error and returns `1` if empty. |
| [`validate_in_list`](docs/04-validation/validate_in_list.md) | `validate_in_list <value> <list>` | Checks whether a value exists in a comma- or space-separated list of allowed values. |
| [`validate_file_exists`](docs/04-validation/validate_file_exists.md) | `validate_file_exists <file_path>` | Returns `0` if the path exists and is a regular file. |
| [`validate_directory_exists`](docs/04-validation/validate_directory_exists.md) | `validate_directory_exists <dir_path>` | Returns `0` if the path exists and is a directory. |
| [`validate_is_number`](docs/04-validation/validate_is_number.md) | `validate_is_number <value>` | Returns `0` if the value is a valid integer or decimal number (positive or negative). |
| [`validate_email`](docs/04-validation/validate_email.md) | `validate_email <email>` | Validates that a string matches standard email address syntax. |
| [`validate_url`](docs/04-validation/validate_url.md) | `validate_url <url>` | Validates that a string is a well-formed `http://` or `https://` URL. |
| [`validate_command_exists`](docs/04-validation/validate_command_exists.md) | `validate_command_exists <cmd_name>` | Returns `0` if a CLI binary or shell command is available in `PATH`. |
| [`validate_date`](docs/04-validation/validate_date.md) | `validate_date <date_str>` | Validates that a string is a real calendar date in `YYYY-MM-DD` format. |
| [`validate_jwt`](docs/04-validation/validate_jwt.md) | `validate_jwt <token>` | Validates that a string has a 3-part base64url JWT structure (`header.payload.signature`). |
| [`validate_json`](docs/04-validation/validate_json.md) | `validate_json <json_string>` | Returns `0` if the input string is valid JSON (parsed via `jq`). |

[↑ Back to Index](#index)

### 05. Git Operations ([`functions/05-git.sh`](functions/05-git.sh) | [Docs](docs/05-git.md) | [Example](examples/05_git_example.sh) | [Tests](tests/05-git.test.sh))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| [`git_get_current_branch`](docs/05-git/git_get_current_branch.md) | `git_get_current_branch` | Prints the current active Git branch name. |
| [`git_is_clean`](docs/05-git/git_is_clean.md) | `git_is_clean` | Returns `0` if the working tree has no modified, staged, or untracked files. |
| [`git_get_root`](docs/05-git/git_get_root.md) | `git_get_root` | Prints the top-level root directory of the current Git repository. |
| [`git_status_message`](docs/05-git/git_status_message.md) | `git_status_message` | Prints a human-readable summary of the repository status (`Clean` or count of changed files). |
| [`git_commit`](docs/05-git/git_commit.md) | `git_commit <message>` | Stages all tracked modifications (`git add -u`) and creates a commit with the given message. |
| [`git_push`](docs/05-git/git_push.md) | `git_push [remote="origin"] [branch]` | Pushes the specified (or current) branch to the remote repository. |
| [`git_pull`](docs/05-git/git_pull.md) | `git_pull [remote="origin"] [branch]` | Pulls latest changes from the remote branch. |
| [`git_safe_pull`](docs/05-git/git_safe_pull.md) | `git_safe_pull [remote="origin"] [branch]` | Verifies the working copy is clean before pulling with `--ff-only`. |
| [`git_branch_exists`](docs/05-git/git_branch_exists.md) | `git_branch_exists <branch_name>` | Returns `0` if the branch exists locally or on `origin`. |
| [`git_get_commit_hash`](docs/05-git/git_get_commit_hash.md) | `git_get_commit_hash [short=0]` | Prints the full (or short if `1`) SHA hash of `HEAD`. |
| [`git_get_commit_message`](docs/05-git/git_get_commit_message.md) | `git_get_commit_message [commit="HEAD"]` | Prints the commit message of the specified commit ref. |
| [`git_compare_branches`](docs/05-git/git_compare_branches.md) | `git_compare_branches [options] <base> <target>` | Compares two branches (honoring `GIT_IGNORE_FOLDERS`) and generates a detailed Markdown diff report. |
| [`git_compare_three_branches`](docs/05-git/git_compare_three_branches.md) | `git_compare_three_branches [options] <release_x> <release_prev> [default]` | Compares two release branches and default branch for missing commits and content diffs across all 3 links. |
| [`git_compare_commits`](docs/05-git/git_compare_commits.md) | `git_compare_commits [options] <ref1> [<ref2>]` | Compares two Git commits, tags, or refs (default `<ref2>` to `HEAD`) and generates a Markdown diff report. |
| [`git_detect_default_branch`](docs/05-git/git_detect_default_branch.md) | `git_detect_default_branch` | Detects the repository's default branch (`origin/HEAD`, `develop`, `main`, or `master`). |
| [`git_resolve_ref`](docs/05-git/git_resolve_ref.md) | `git_resolve_ref <branch>` | Resolves a branch name to its local ref or `origin/<branch>` remote ref. |
| [`git_list_branches`](docs/05-git/git_list_branches.md) | `git_list_branches [pattern]` | Lists unique local and `origin` branch names, optionally filtered by a glob pattern (e.g., `release/*`). |
| [`git_get_missed_commits`](docs/05-git/git_get_missed_commits.md) | `git_get_missed_commits <target> <source>` | Outputs SHAs of commits in `<source>` not backported to `<target>` (patch-id aware via `git cherry`). |
| [`git_format_commit`](docs/05-git/git_format_commit.md) | `git_format_commit [commit="HEAD"]` | Formats a commit as `<short_hash> \| <date> \| <author> \| <subject>`. |
| [`git_pick_branch`](docs/05-git/git_pick_branch.md) | `git_pick_branch <prompt> [pattern]` | Prompts the user to select a branch matching `[pattern]` (falling back to all branches). |
| [`git_report_missed_commits`](docs/05-git/git_report_missed_commits.md) | `git_report_missed_commits <target> <release> [output_file] [silent]` | Highlights release commits missing from `<target>` and optionally writes a Markdown report. |
| [`git_tag_exists`](docs/05-git/git_tag_exists.md) | `git_tag_exists <tag>` | Returns `0` if the specified Git tag exists in the repository. |
| [`git_list_tags`](docs/05-git/git_list_tags.md) | `git_list_tags [pattern]` | Lists Git tags sorted by creator date (newest first), optionally filtered by a glob pattern. |
| [`git_compare_tags`](docs/05-git/git_compare_tags.md) | `git_compare_tags [options] [<tag_a>] [<tag_b>]` | Compares two Git tags (or auto-detects the latest two) and generates a colorized Markdown report. |
| [`git_compare_releases`](docs/05-git/git_compare_releases.md) | `git_compare_releases [options] [<release_a>] [<release_b>]` | Compares two release branches or tags to pinpoint scope creep, commit gaps, and file diffs. |
| [`git_compare_content`](docs/05-git/git_compare_content.md) | `git_compare_content [options] <source_ref> [<target_ref>]` | Compares file or directory content between two Git refs, optionally scoped by `-p/--path`. |
| [`git_compare_working_tree`](docs/05-git/git_compare_working_tree.md) | `git_compare_working_tree [options] [<base_ref>]` | Compares the working tree or `--staged` index against `HEAD` (or `<base_ref>`) in a Markdown report. |
| [`git_compare`](docs/05-git/git_compare.md) | `git_compare --type <type> [options] [<source>] [<target>]` | Unified Git comparison dispatcher for `branch`, `commit`, `tag`, `release`, `content`, `worktree`, and `three-way`. |

[↑ Back to Index](#index)

### 06. HTTP Client Wrapper ([`functions/06-http.sh`](functions/06-http.sh) | [Docs](docs/06-http.md) | [Example](examples/06_http_example.sh) | [Tests](tests/06-http.test.sh))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| [`http_get`](docs/06-http/http_get.md) | `http_get <url> [headers]` | Performs an HTTP `GET` request and returns the response body with the HTTP status code on the last line. |
| [`http_post`](docs/06-http/http_post.md) | `http_post <url> [data_or_json_file] [headers]` | Performs an HTTP `POST` request; accepts a `.json` file path, `@file.json`, or raw JSON string. |
| [`http_put`](docs/06-http/http_put.md) | `http_put <url> [data_or_json_file] [headers]` | Performs an HTTP `PUT` request; accepts a `.json` file path, `@file.json`, or raw JSON string. |
| [`http_patch`](docs/06-http/http_patch.md) | `http_patch <url> [data_or_json_file] [headers]` | Performs an HTTP `PATCH` request; accepts a `.json` file path, `@file.json`, or raw JSON string. |
| [`http_delete`](docs/06-http/http_delete.md) | `http_delete <url> [headers]` | Performs an HTTP `DELETE` request and appends the HTTP status code on the final line. |
| [`check_status_code`](docs/06-http/check_status_code.md) | `check_status_code <http_response>` | Extracts the 3-digit HTTP status code from the response returned by `http_*` functions. |
| [`http_get_body`](docs/06-http/http_get_body.md) | `http_get_body <http_response>` | Strips the trailing HTTP status code line and prints only the response payload body. |
| [`is_json_response`](docs/06-http/is_json_response.md) | `is_json_response <http_response>` | Returns `0` if the HTTP response body is valid JSON. |
| [`extract_json_field`](docs/06-http/extract_json_field.md) | `extract_json_field <http_response> <jq_field>` | Extracts a specific field (e.g., `.data.id`) from an HTTP response body using `jq`. |
| [`download_file`](docs/06-http/download_file.md) | `download_file <url> <output_path>` | Downloads a remote URL directly to a local file path, following redirects. |
| [`http_get_with_retry`](docs/06-http/http_get_with_retry.md) | `http_get_with_retry <url> [retries=3] [delay=2] [headers]` | Retries an HTTP `GET` request until a `2xx` status code is returned or retries are exhausted. |
| [`http_build_headers`](docs/06-http/http_build_headers.md) | `http_build_headers [headers...]` | Builds a newline-separated header string merging `HTTP_DEFAULT_HEADERS` with optional override headers. |
| [`http_set_default_header`](docs/06-http/http_set_default_header.md) | `http_set_default_header <name> <value>` | Sets or updates a default HTTP header in `HTTP_DEFAULT_HEADERS` (empty value unsets). |
| [`http_get_default_header`](docs/06-http/http_get_default_header.md) | `http_get_default_header <name>` | Retrieves a default HTTP header value from `HTTP_DEFAULT_HEADERS` (case-insensitive). |
| [`http_unset_default_header`](docs/06-http/http_unset_default_header.md) | `http_unset_default_header <name>` | Removes a default HTTP header from `HTTP_DEFAULT_HEADERS` (case-insensitive). |
| [`http_clear_default_headers`](docs/06-http/http_clear_default_headers.md) | `http_clear_default_headers` | Clears all entries from `HTTP_DEFAULT_HEADERS`. |

[↑ Back to Index](#index)

### 07. Interactive User Prompts ([`functions/07-user-actions.sh`](functions/07-user-actions.sh) | [Docs](docs/07-user-actions.md) | [Example](examples/07_user_actions_example.sh) | [Tests](tests/07-user-actions.test.sh))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| [`read_input`](docs/07-user-actions/read_input.md) | `read_input <prompt> [default_value]` | Prompts the user for text input and returns the typed value (or `default_value` if blank). |
| [`read_password`](docs/07-user-actions/read_password.md) | `read_password [prompt="Password"]` | Prompts the user for sensitive input with terminal character echoing disabled. |
| [`confirm`](docs/07-user-actions/confirm.md) | `confirm <prompt> [default="N"]` | Asks a Yes/No question (`[y/N]` or `[Y/n]`) and returns `0` for Yes or `1` for No. |
| [`select_option`](docs/07-user-actions/select_option.md) | `select_option <prompt> <opt1> [opt2 ...]` | Displays a numbered interactive menu and prints the selected option value. |
| [`wait_for_enter`](docs/07-user-actions/wait_for_enter.md) | `wait_for_enter [message]` | Pauses script execution until the user presses the Enter key. |
| [`read_with_validation`](docs/07-user-actions/read_with_validation.md) | `read_with_validation <prompt> <validator_fn> [err_msg]` | Repeatedly prompts the user until the input passes the specified validation function. |

[↑ Back to Index](#index)

### 08. Date & Time Utilities ([`functions/08-datetime.sh`](functions/08-datetime.sh) | [Docs](docs/08-datetime.md) | [Example](examples/08_datetime_example.sh) | [Tests](tests/08-datetime.test.sh))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| [`timestamp`](docs/08-datetime/timestamp.md) | `timestamp` | Prints the current Unix epoch time in seconds. |
| [`date_now`](docs/08-datetime/date_now.md) | `date_now [format]` | Prints the current local date/time formatted with `DATE_FORMAT` (or custom `strftime` format). |
| [`parse_date`](docs/08-datetime/parse_date.md) | `parse_date <date_str> [format]` | Converts a date/time string into Unix epoch seconds. |
| [`date_add`](docs/08-datetime/date_add.md) | `date_add <date_str> <duration> [out_format]` | Adds a duration (e.g., `2d`, `5h`, `30m`, `10s`) to a date and prints the resulting timestamp. |
| [`date_subtract`](docs/08-datetime/date_subtract.md) | `date_subtract <date_str> <duration> [out_format]` | Subtracts a duration (e.g., `1d`, `2h`) from a date and prints the resulting timestamp. |
| [`date_diff`](docs/08-datetime/date_diff.md) | `date_diff <date1> <date2>` | Calculates the absolute difference in seconds between two dates. |
| [`date_format`](docs/08-datetime/date_format.md) | `date_format <date_str> <target_format>` | Reformats a date string into a new `strftime` format. |
| [`timezone_convert`](docs/08-datetime/timezone_convert.md) | `timezone_convert <date_str> <from_tz> <to_tz> [format]` | Converts a timestamp from one timezone (e.g., `UTC`) to another (e.g., `America/New_York`). |
| [`is_valid_date`](docs/08-datetime/is_valid_date.md) | `is_valid_date <date_str> [format]` | Returns `0` if the date string can be parsed as a valid calendar date. |
| [`date_range`](docs/08-datetime/date_range.md) | `date_range <start_date> <end_date>` | Prints every `YYYY-MM-DD` date inclusively between `start_date` and `end_date`. |
| [`format_duration`](docs/08-datetime/format_duration.md) | `format_duration <seconds>` | Formats a duration in seconds into a human-readable string (e.g., `1d 2h 3m 4s`). |

[↑ Back to Index](#index)

### 09. File Operations ([`functions/09-file.sh`](functions/09-file.sh) | [Docs](docs/09-file.md) | [Example](examples/09_file_example.sh) | [Tests](tests/09-file.test.sh))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| [`file_exists`](docs/09-file/file_exists.md) | `file_exists <file_path>` | Returns `0` if the path exists and is a regular file. |
| [`file_read`](docs/09-file/file_read.md) | `file_read <file_path>` | Outputs the contents of a file to `stdout`. |
| [`file_read_to_array`](docs/09-file/file_read_to_array.md) | `file_read_to_array <file_path> [array_name=FILE_LINES] [skip_empty=0]` | Reads a file line-by-line into a Zsh array variable for iteration/looping. |
| [`file_write`](docs/09-file/file_write.md) | `file_write <file_path> <content>` | Writes content to a file (creating parent directories if needed). |
| [`file_append`](docs/09-file/file_append.md) | `file_append <file_path> <content>` | Appends content to the end of a file. |
| [`file_copy`](docs/09-file/file_copy.md) | `file_copy <src> <dest> [interactive=0]` | Copies a file to a destination path (with optional overwrite confirmation). |
| [`file_move`](docs/09-file/file_move.md) | `file_move <src> <dest> [interactive=0]` | Moves or renames a file (with optional overwrite confirmation). |
| [`file_delete`](docs/09-file/file_delete.md) | `file_delete <file_path> [interactive=0]` | Deletes a file (with optional confirmation prompt). |
| [`file_get_size`](docs/09-file/file_get_size.md) | `file_get_size <file_path>` | Prints the file size in bytes. |
| [`file_get_permissions`](docs/09-file/file_get_permissions.md) | `file_get_permissions <file_path>` | Prints the octal permission mode (e.g., `755` or `644`) of a file. |
| [`file_set_permissions`](docs/09-file/file_set_permissions.md) | `file_set_permissions <file_path> <mode>` | Applies octal permissions (`chmod`) to a file. |
| [`file_get_owner`](docs/09-file/file_get_owner.md) | `file_get_owner <file_path>` | Prints the username of the file owner. |
| [`file_get_group`](docs/09-file/file_get_group.md) | `file_get_group <file_path>` | Prints the group name of the file. |
| [`file_backup`](docs/09-file/file_backup.md) | `file_backup <file_path>` | Creates a timestamped `.bak` copy of a file and prints the backup path. |
| [`file_restore`](docs/09-file/file_restore.md) | `file_restore <backup_path> [target_path]` | Restores a file from its `.bak` backup file. |
| [`file_backup_and_restore`](docs/09-file/file_backup_and_restore.md) | `file_backup_and_restore <action> <file_path>` | Convenience wrapper to either `backup` or `restore` a file. |
| [`file_hash`](docs/09-file/file_hash.md) | `file_hash <file_path> [algo="sha256"]` | Computes the cryptographic checksum (`sha256`, `md5`, `sha1`) of a file. |
| [`file_head`](docs/09-file/file_head.md) | `file_head <file_path> [lines=10]` | Prints the first N lines of a file. |
| [`file_tail`](docs/09-file/file_tail.md) | `file_tail <file_path> [lines=10]` | Prints the last N lines of a file. |
| [`file_grep`](docs/09-file/file_grep.md) | `file_grep <file_path> <pattern>` | Searches a file for lines matching a regex pattern. |
| [`file_equals`](docs/09-file/file_equals.md) | `file_equals <file1> <file2>` | Checks whether two files have identical byte-for-byte contents. |
| [`file_compare`](docs/09-file/file_compare.md) | `file_compare [options] <file1> <file2>` | Compares two files (size, line count, SHA-256, unified diff) and outputs a Markdown report. |

[↑ Back to Index](#index)

### 10. Directory Management ([`functions/10-directory.sh`](functions/10-directory.sh) | [Docs](docs/10-directory.md) | [Example](examples/10_directory_example.sh) | [Tests](tests/10-directory.test.sh))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| [`dir_exists`](docs/10-directory/dir_exists.md) | `dir_exists <dir_path>` | Returns `0` if the path exists and is a directory. |
| [`dir_create`](docs/10-directory/dir_create.md) | `dir_create <dir_path> [mode]` | Recursively creates a directory (`mkdir -p`) and optionally sets permissions. |
| [`dir_delete`](docs/10-directory/dir_delete.md) | `dir_delete <dir_path> [interactive=0]` | Recursively deletes a directory (with safety checks against deleting `/`). |
| [`dir_copy`](docs/10-directory/dir_copy.md) | `dir_copy <src_dir> <dest_dir>` | Recursively copies a directory tree to a destination. |
| [`dir_move`](docs/10-directory/dir_move.md) | `dir_move <src_dir> <dest_dir>` | Moves or renames a directory. |
| [`dir_list`](docs/10-directory/dir_list.md) | `dir_list <dir_path> [glob_pattern="*"]` | Lists files/entries inside a directory matching the glob pattern. |
| [`dir_size`](docs/10-directory/dir_size.md) | `dir_size <dir_path>` | Prints the human-readable total disk usage of a directory. |
| [`dir_is_empty`](docs/10-directory/dir_is_empty.md) | `dir_is_empty <dir_path>` | Returns `0` if the directory contains no files or subdirectories (including hidden ones). |
| [`dir_clean`](docs/10-directory/dir_clean.md) | `dir_clean <dir_path> [days_old=0]` | Removes all contents inside a directory (or files older than `days_old`) without deleting the folder itself. |
| [`dir_tree`](docs/10-directory/dir_tree.md) | `dir_tree <dir_path> [max_depth=3]` | Prints an indented visual tree structure of a directory. |
| [`dir_sync`](docs/10-directory/dir_sync.md) | `dir_sync <src_dir> <dest_dir>` | Synchronizes contents from source to destination directory using `rsync` or `cp -a`. |
| [`dir_watch`](docs/10-directory/dir_watch.md) | `dir_watch <dir_path> <callback_cmd> [interval=2] [max_loops=0]` | Polls a directory for file changes and triggers a callback command when modifications occur. |
| [`dir_compare`](docs/10-directory/dir_compare.md) | `dir_compare [options] <dir1> <dir2>` | Recursively compares two directories and generates a Markdown report of added, removed, modified, and identical files. |

[↑ Back to Index](#index)

### 11. String Manipulation ([`functions/11-string.sh`](functions/11-string.sh) | [Docs](docs/11-string.md) | [Example](examples/11_string_example.sh) | [Tests](tests/11-string.test.sh))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| [`str_contains`](docs/11-string/str_contains.md) | `str_contains <string> <substring>` | Returns `0` if `string` contains `substring`. |
| [`str_starts_with`](docs/11-string/str_starts_with.md) | `str_starts_with <string> <prefix>` | Returns `0` if `string` starts with `prefix`. |
| [`str_ends_with`](docs/11-string/str_ends_with.md) | `str_ends_with <string> <suffix>` | Returns `0` if `string` ends with `suffix`. |
| [`str_replace`](docs/11-string/str_replace.md) | `str_replace <string> <search> <replace>` | Replaces all occurrences of `search` with `replace` in `string`. |
| [`str_replace_first`](docs/11-string/str_replace_first.md) | `str_replace_first <string> <search> <replace>` | Replaces only the first occurrence of `search` with `replace`. |
| [`str_trim`](docs/11-string/str_trim.md) | `str_trim <string>` | Strips both leading and trailing whitespace from `string`. |
| [`str_ltrim`](docs/11-string/str_ltrim.md) | `str_ltrim <string>` | Strips leading whitespace from `string`. |
| [`str_rtrim`](docs/11-string/str_rtrim.md) | `str_rtrim <string>` | Strips trailing whitespace from `string`. |
| [`str_split`](docs/11-string/str_split.md) | `str_split <string> <delimiter>` | Splits `string` by `delimiter` and prints each element on a new line. |
| [`str_join`](docs/11-string/str_join.md) | `str_join <delimiter> <item1> [item2 ...]` | Joins multiple arguments into a single string separated by `delimiter`. |
| [`str_to_array`](docs/11-string/str_to_array.md) | `str_to_array <string> <delimiter> [array_name=STR_ARRAY]` | Splits `string` by `delimiter` and populates a Zsh array variable. |
| [`array_get_element`](docs/11-string/array_get_element.md) | `array_get_element <array_name> <index_or_keyword>` | Retrieves an element from a Zsh array by 1-based/negative index or `'first'` / `'last'`. |
| [`str_to_lower`](docs/11-string/str_to_lower.md) | `str_to_lower <string>` | Converts all characters in `string` to lowercase. |
| [`str_to_upper`](docs/11-string/str_to_upper.md) | `str_to_upper <string>` | Converts all characters in `string` to uppercase. |
| [`str_capitalize`](docs/11-string/str_capitalize.md) | `str_capitalize <string>` | Capitalizes the first character of `string` and lowercases the rest. |
| [`str_reverse`](docs/11-string/str_reverse.md) | `str_reverse <string>` | Reverses the character order of `string`. |
| [`str_length`](docs/11-string/str_length.md) | `str_length <string>` | Prints the character length of `string`. |
| [`str_substring`](docs/11-string/str_substring.md) | `str_substring <string> <start_idx> [length]` | Extracts a substring starting at 0-based `start_idx` for `length` characters. |
| [`str_pad_left`](docs/11-string/str_pad_left.md) | `str_pad_left <string> <total_width> [pad_char=" "]` | Left-pads `string` to `total_width` using `pad_char`. |
| [`str_pad_right`](docs/11-string/str_pad_right.md) | `str_pad_right <string> <total_width> [pad_char=" "]` | Right-pads `string` to `total_width` using `pad_char`. |
| [`str_escape`](docs/11-string/str_escape.md) | `str_escape <string>` | URL-encodes (percent-encodes) special characters in `string`. |
| [`str_unescape`](docs/11-string/str_unescape.md) | `str_unescape <string>` | Decodes a URL-encoded (percent-encoded) string. |
| [`str_slugify`](docs/11-string/str_slugify.md) | `str_slugify <string>` | Converts arbitrary text into a lowercase, hyphen-separated URL slug. |
| [`str_random`](docs/11-string/str_random.md) | `str_random [length=16]` | Generates a random alphanumeric string of the specified length. |
| [`str_uuid`](docs/11-string/str_uuid.md) | `str_uuid` | Generates a standard v4 UUID string. |

[↑ Back to Index](#index)

### 12. SSH & SCP Client ([`functions/12-ssh.sh`](functions/12-ssh.sh) | [Docs](docs/12-ssh.md) | [Example](examples/12_ssh_example.sh) | [Tests](tests/12-ssh.test.sh))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| [`ssh_is_reachable`](docs/12-ssh/ssh_is_reachable.md) | `ssh_is_reachable <host> [port=22] [timeout=2]` | Checks whether a remote host's SSH TCP port is reachable within `timeout` seconds. |
| [`ssh_exec`](docs/12-ssh/ssh_exec.md) | `ssh_exec <user> <host> <cmd> [key_path] [password] [port=22]` | Executes a command on a remote server via SSH using an identity key or password. |
| [`ssh_scp_up`](docs/12-ssh/ssh_scp_up.md) | `ssh_scp_up <local_path> <user> <host> <remote_path> [key] [pass] [port=22]` | Uploads a local file or directory to a remote server via SCP. |
| [`ssh_scp_down`](docs/12-ssh/ssh_scp_down.md) | `ssh_scp_down <user> <host> <remote_path> <local_path> [key] [pass] [port=22]` | Downloads a file or directory from a remote server via SCP. |
| [`ssh_tunnel_start`](docs/12-ssh/ssh_tunnel_start.md) | `ssh_tunnel_start <user> <host> <local_port> <remote_host> <remote_port> [key] [port=22]` | Opens a background local port-forwarding SSH tunnel and prints the tunnel PID. |

[↑ Back to Index](#index)

### 13. JSON Web Tokens (JWT) ([`functions/13-jwt.sh`](functions/13-jwt.sh) | [Docs](docs/13-jwt.md) | [Example](examples/13_jwt_example.sh) | [Tests](tests/13-jwt.test.sh))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| [`jwt_generate`](docs/13-jwt/jwt_generate.md) | `jwt_generate <payload_json> [secret]` | Generates an HS256-signed JWT from a JSON payload string using `secret` (or `JWT_SECRET`). |
| [`jwt_decode`](docs/13-jwt/jwt_decode.md) | `jwt_decode <token>` | Decodes and prints the payload JSON of a JWT without verifying its signature. |
| [`jwt_get_header`](docs/13-jwt/jwt_get_header.md) | `jwt_get_header <token>` | Decodes and prints the header JSON of a JWT. |
| [`jwt_get_payload`](docs/13-jwt/jwt_get_payload.md) | `jwt_get_payload <token>` | Decodes and prints the payload JSON of a JWT. |
| [`jwt_get_claim`](docs/13-jwt/jwt_get_claim.md) | `jwt_get_claim <token> <claim_name>` | Extracts the value of a single claim key (e.g., `sub`, `role`) from a JWT payload. |
| [`jwt_verify`](docs/13-jwt/jwt_verify.md) | `jwt_verify <token> [secret]` | Verifies the HMAC-SHA256 cryptographic signature of a JWT against `secret`. |
| [`jwt_expired`](docs/13-jwt/jwt_expired.md) | `jwt_expired <token>` | Returns `0` if the token's `exp` claim is in the past (expired), or `1` if still active. |
| [`jwt_valid`](docs/13-jwt/jwt_valid.md) | `jwt_valid <token> [secret]` | Returns `0` only if the JWT is well-formed, signature-verified, and not expired. |
| [`jwt_refresh`](docs/13-jwt/jwt_refresh.md) | `jwt_refresh <token> <extra_seconds> [secret]` | Verifies an existing token and issues a new JWT with an extended `exp` timestamp. |
| [`jwt_parse_claims`](docs/13-jwt/jwt_parse_claims.md) | `jwt_parse_claims <token>` | Prints all claims in the JWT payload as `key=value` lines. |
| [`jwt_get_audience`](docs/13-jwt/jwt_get_audience.md) | `jwt_get_audience <token>` | Extracts the `aud` (Audience) claim from a JWT. |
| [`jwt_get_issuer`](docs/13-jwt/jwt_get_issuer.md) | `jwt_get_issuer <token>` | Extracts the `iss` (Issuer) claim from a JWT. |
| [`jwt_has_claim`](docs/13-jwt/jwt_has_claim.md) | `jwt_has_claim <token> <claim_name>` | Returns `0` if the specified claim key exists and is non-null in the JWT payload. |

[↑ Back to Index](#index)

### 14. JSON Parsing & JQ ([`functions/14-jq.sh`](functions/14-jq.sh) | [Docs](docs/14-jq.md) | [Example](examples/14_jq_example.sh) | [Tests](tests/14-jq.test.sh))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| [`json_parse`](docs/14-jq/json_parse.md) | `json_parse <json_str>` | Parses and pretty-prints a JSON string using `jq`. |
| [`json_get_value`](docs/14-jq/json_get_value.md) | `json_get_value <json_str> <jq_path>` | Extracts a scalar or nested value at `jq_path` (e.g., `.user.name`) from a JSON string. |
| [`json_set_value`](docs/14-jq/json_set_value.md) | `json_set_value <json_str> <jq_path> <new_value>` | Sets or updates a key/path in a JSON string (auto-detecting numbers, booleans, objects, or strings). |
| [`json_delete_key`](docs/14-jq/json_delete_key.md) | `json_delete_key <json_str> <jq_path>` | Deletes a key or element at `jq_path` from a JSON string. |
| [`json_get_keys`](docs/14-jq/json_get_keys.md) | `json_get_keys <json_str> [jq_path="."]` | Lists all keys of a JSON object (one per line). |
| [`json_merge`](docs/14-jq/json_merge.md) | `json_merge <json_base> <json_override>` | Deep-merges two JSON objects (`json_override` values take precedence). |
| [`json_to_yaml`](docs/14-jq/json_to_yaml.md) | `json_to_yaml <json_str>` | Converts a JSON object into YAML-formatted output. |
| [`json_validate`](docs/14-jq/json_validate.md) | `json_validate <json_str>` | Returns `0` if `json_str` is valid JSON, or `1` otherwise. |
| [`json_beautify`](docs/14-jq/json_beautify.md) | `json_beautify <json_str>` | Formats a JSON string with 2-space indentation. |
| [`json_compact`](docs/14-jq/json_compact.md) | `json_compact <json_str>` | Minifies a JSON string onto a single line with whitespace removed. |
| [`json_escape`](docs/14-jq/json_escape.md) | `json_escape <raw_string>` | Escapes a raw string as a valid JSON string literal. |
| [`json_array_add`](docs/14-jq/json_array_add.md) | `json_array_add <json_str> <array_path> <item>` | Appends an element to a JSON array at `array_path`. |
| [`json_array_remove`](docs/14-jq/json_array_remove.md) | `json_array_remove <json_str> <array_path> <value_or_index>` | Removes an element by value or index from a JSON array at `array_path`. |
| [`json_extract_path`](docs/14-jq/json_extract_path.md) | `json_extract_path <json_str> <jq_path>` | Alias for `json_get_value`; extracts the value at `jq_path`. |

[↑ Back to Index](#index)

### 15. Dynamic Variables & Repo Registry ([`functions/15-variables.sh`](functions/15-variables.sh) | [Docs](docs/15-variables.md) | [Example](examples/15_variables_example.sh) | [Tests](tests/17-variables.test.sh))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| [`config_get_var`](docs/15-variables/config_get_var.md) | `config_get_var <var_name> [default_value]` | Reads the value of a global variable by name, returning `default_value` if unset or empty. |
| [`config_set_var`](docs/15-variables/config_set_var.md) | `config_set_var <var_name> <value>` | Dynamically sets a global variable (`typeset -g`) by name. |
| [`config_unset_var`](docs/15-variables/config_unset_var.md) | `config_unset_var <var_name>` | Unsets/removes a global variable by name. |
| [`config_get_repo_location`](docs/15-variables/config_get_repo_location.md) | `config_get_repo_location <repo_name>` | Looks up a repository's filesystem path from `REPO_LOCATIONS`. |
| [`config_set_repo_location`](docs/15-variables/config_set_repo_location.md) | `config_set_repo_location <repo_name> <path>` | Registers a repository name in `REPO_NAMES` and maps its path in `REPO_LOCATIONS`. |
| [`config_unset_repo_location`](docs/15-variables/config_unset_repo_location.md) | `config_unset_repo_location <repo_name>` | Removes a repository from both `REPO_LOCATIONS` and `REPO_NAMES`. |
| [`config_list_repos`](docs/15-variables/config_list_repos.md) | `config_list_repos` | Prints all registered repositories in `<repo_name>: <path>` format. |

[↑ Back to Index](#index)

### 16. Data Masking & Redaction ([`functions/16-mask.sh`](functions/16-mask.sh) | [Docs](docs/16-mask.md) | [Example](examples/16_mask_example.sh) | [Tests](tests/16-mask.test.sh))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| [`mask_string`](docs/16-mask/mask_string.md) | `mask_string <str> [visible_start=2] [visible_end=2] [mask_char="*"]` | Masks the middle portion of a string while keeping leading/trailing characters visible. |
| [`mask_token`](docs/16-mask/mask_token.md) | `mask_token <token> [visible_chars=4] [mask_char="*"]` | Masks an API token, Bearer secret, or Vault token, keeping ends visible. |
| [`mask_email`](docs/16-mask/mask_email.md) | `mask_email <email> [mask_char="*"]` | Masks the local part of an email address while preserving its first char and domain. |
| [`mask_phone`](docs/16-mask/mask_phone.md) | `mask_phone <phone> [visible_digits=4] [mask_char="*"]` | Masks all digits in a phone number except the last `visible_digits` digits. |
| [`mask_card`](docs/16-mask/mask_card.md) | `mask_card <card_number> [visible_digits=4] [mask_char="*"]` | Masks a card number, keeping only the last `visible_digits` digits visible. |
| [`mask_json_fields`](docs/16-mask/mask_json_fields.md) | `mask_json_fields <json_str> <fields_csv> [mask_value="***MASKED***"]` | Recursively masks specified sensitive keys in a JSON payload using `jq`. |
| [`mask_env_line`](docs/16-mask/mask_env_line.md) | `mask_env_line <line> [sensitive_keys_csv] [mask_value="***MASKED***"]` | Masks `KEY=VALUE` or `Header: Value` lines matching sensitive keywords. |

[↑ Back to Index](#index)

### 17. Mocking & Test Stubs ([`functions/17-mock.sh`](functions/17-mock.sh) | [Docs](docs/17-mock.md) | [Example](examples/17_mock_example.sh) | [Tests](tests/17-mock.test.sh))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| [`mock_string`](docs/17-mock/mock_string.md) | `mock_string [length=12] [prefix=""]` | Generates a random alphabetic dummy string, optionally prefixed. |
| [`mock_alphanumeric`](docs/17-mock/mock_alphanumeric.md) | `mock_alphanumeric [length=16]` | Generates a random `[A-Za-z0-9]` dummy string. |
| [`mock_password`](docs/17-mock/mock_password.md) | `mock_password [length=16] [include_special=1]` | Generates a strong random password with upper, lower, digit, and optional symbol chars. |
| [`mock_int`](docs/17-mock/mock_int.md) | `mock_int [min=1] [max=1000]` | Generates a random integer within `[min, max]` inclusive. |
| [`mock_bool`](docs/17-mock/mock_bool.md) | `mock_bool` | Generates a random `'true'` or `'false'` boolean string. |
| [`mock_uuid`](docs/17-mock/mock_uuid.md) | `mock_uuid` | Generates a random RFC 4122 v4 UUID. |
| [`mock_email`](docs/17-mock/mock_email.md) | `mock_email [domain="example.com"]` | Generates a random dummy email address. |
| [`mock_phone`](docs/17-mock/mock_phone.md) | `mock_phone` | Generates a random US-style dummy phone number (`+1-555-XXX-XXXX`). |
| [`mock_date`](docs/17-mock/mock_date.md) | `mock_date [format="%Y-%m-%d"]` | Prints a formatted UTC timestamp/date string. |
| [`mock_jwt`](docs/17-mock/mock_jwt.md) | `mock_jwt [sub="mock-user"] [role="admin"]` | Generates a dummy 3-segment base64url JWT token. |
| [`mock_vault_token`](docs/17-mock/mock_vault_token.md) | `mock_vault_token [prefix="hvs."] [length=24]` | Generates a dummy HashiCorp Vault token (`hvs.<random>`). |
| [`mock_array`](docs/17-mock/mock_array.md) | `mock_array [count=5] [array_name=MOCK_ARRAY] [item_type="string"]` | Populates a Zsh array variable with `count` dummy items of `item_type`. |
| [`mock_nested_array`](docs/17-mock/mock_nested_array.md) | `mock_nested_array [rows=3] [cols=3] [item_type="string"]` | Generates a compact JSON 2D nested array. |
| [`mock_json`](docs/17-mock/mock_json.md) | `mock_json [depth=1] [keys_count=3]` | Generates a dummy JSON object (with nested objects & arrays when `depth > 1`). |
| [`mock_json_user`](docs/17-mock/mock_json_user.md) | `mock_json_user` | Generates a realistic dummy user JSON payload with nested metadata and token. |
| [`mock_command`](docs/17-mock/mock_command.md) | `mock_command <cmd_name> [stdout_output=""] [exit_code=0]` | Mocks a command or Zsh function with static stdout, exit code, and call tracking. |
| [`mock_http_response`](docs/17-mock/mock_http_response.md) | `mock_http_response [body='{"ok":true}'] [status_code=200]` | Convenience helper that stubs `curl` for `06-http.sh` requests. |
| [`mock_get_call_count`](docs/17-mock/mock_get_call_count.md) | `mock_get_call_count <cmd_name>` | Prints how many times a mocked command was invoked. |
| [`mock_get_last_args`](docs/17-mock/mock_get_last_args.md) | `mock_get_last_args <cmd_name>` | Prints the argument string from the most recent invocation of a mocked command. |
| [`mock_was_called`](docs/17-mock/mock_was_called.md) | `mock_was_called <cmd_name> [expected_count]` | Returns `0` if a mocked command was called (at least once, or `expected_count` times). |
| [`mock_restore`](docs/17-mock/mock_restore.md) | `mock_restore <cmd_name>` | Removes a mock and restores any previously saved Zsh function definition. |
| [`mock_restore_all`](docs/17-mock/mock_restore_all.md) | `mock_restore_all` | Restores all currently mocked commands/functions and clears all mock state. |

[↑ Back to Index](#index)

### 18. Script Executory ([`functions/18-script-executory.sh`](functions/18-script-executory.sh) | [Docs](docs/18-script-executory.md) | [Example](examples/18_script_executory_example.sh) | [Tests](tests/18-script-executory.test.sh))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| [`validate_script_executable`](docs/18-script-executory/validate_script_executable.md) | `validate_script_executable <script_path>` | Resolves a script path, checks readability, and runs `zsh -n` syntax validation. |
| [`execute_script`](docs/18-script-executory/execute_script.md) | `execute_script <script_path> [args...]` | Executes a script in a Zsh subprocess with optional arguments and logs timing/status. |
| [`execute_script_in_current_shell`](docs/18-script-executory/execute_script_in_current_shell.md) | `execute_script_in_current_shell <script_path> [args...]` | Sources a script in the current shell so variables persist across sequential steps. |
| [`execute_scripts_sequence`](docs/18-script-executory/execute_scripts_sequence.md) | `execute_scripts_sequence [--continue-on-error] [--source] [--dry-run] <scripts...>` | Executes multiple scripts in order (fail-fast by default) and records `SCRIPT_EXEC_SUMMARY`. |
| [`execute_scripts_from_file`](docs/18-script-executory/execute_scripts_from_file.md) | `execute_scripts_from_file <manifest_file> [flags...]` | Reads ordered script paths from a manifest file and executes them sequentially. |
| [`execute_script_with_retry`](docs/18-script-executory/execute_script_with_retry.md) | `execute_script_with_retry <script_path> [max_retries=3] [delay_seconds=2] [args...]` | Retries a failing script up to `max_retries` times with a configurable delay. |

[↑ Back to Index](#index)

### 19. Secrets & Token Cache ([`functions/19-cache.sh`](functions/19-cache.sh) | [Docs](docs/19-cache.md) | [Example](examples/19_cache_example.sh) | [Tests](tests/19-cache.test.sh))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| [`cache_init`](docs/19-cache/cache_init.md) | `cache_init [dir]` | Initializes the secrets cache directory (`SECRETS_DIR`) with `0700` permissions. |
| [`cache_set`](docs/19-cache/cache_set.md) | `cache_set <key> <value> [ttl_seconds]` | Stores a secret/token in `.secrets.d` with optional TTL or auto-detected JWT `exp`. |
| [`cache_get`](docs/19-cache/cache_get.md) | `cache_get <key>` | Retrieves a valid cached secret; removes and fails if missing or expired. |
| [`cache_has`](docs/19-cache/cache_has.md) | `cache_has <key>` | Checks if a valid, non-expired cached secret exists for `<key>`. |
| [`cache_ttl`](docs/19-cache/cache_ttl.md) | `cache_ttl <key>` | Prints remaining TTL in seconds (`0` if persistent), or returns `1` if missing/expired. |
| [`cache_remove`](docs/19-cache/cache_remove.md) | `cache_remove <key>` | Removes a cached secret and prunes empty parent directories. |
| [`cache_clear`](docs/19-cache/cache_clear.md) | `cache_clear [prefix]` | Clears all cached secrets or all entries under a specific app/env prefix. |
| [`cache_prune`](docs/19-cache/cache_prune.md) | `cache_prune` | Removes all expired entries and empty subdirectories, printing the pruned count. |
| [`cache_list`](docs/19-cache/cache_list.md) | `cache_list [prefix]` | Lists cached secret keys and their expiry status without printing secret values. |
| [`cache_get_or_set`](docs/19-cache/cache_get_or_set.md) | `cache_get_or_set <key> <ttl_seconds> <command...>` | Returns cached secret or runs `<command...>`, caches its output, and returns it. |

[↑ Back to Index](#index)

### 99. Evidence Collector ([`functions/99-evidences.sh`](functions/99-evidences.sh) | [Docs](docs/99-evidences.md) | [Example](examples/99_evidences_example.sh) | [Tests](tests/99-evidences.test.sh))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| [`init_evidence`](docs/99-evidences/init_evidence.md) | `init_evidence` | Creates a new timestamped folder under `EVIDENCE_DIR` and initializes `metadata.json`. |
| [`collect_environment_evidence`](docs/99-evidences/collect_environment_evidence.md) | `collect_environment_evidence` | Captures OS, kernel, user, working directory, and environment snapshot into `environment.json`. |
| [`collect_script_evidence`](docs/99-evidences/collect_script_evidence.md) | `collect_script_evidence [args...]` | Records the executing script name, arguments, and PID into `script.json`. |
| [`collect_network_evidence`](docs/99-evidences/collect_network_evidence.md) | `collect_network_evidence` | Captures network interfaces and routing state into `network.txt`. |
| [`collect_file_evidence`](docs/99-evidences/collect_file_evidence.md) | `collect_file_evidence <file_path>` | Copies a target file into the evidence folder and records its size and SHA-256 hash. |
| [`collect_docker_evidence`](docs/99-evidences/collect_docker_evidence.md) | `collect_docker_evidence` | Captures running Docker container status (`docker ps`) into `docker.txt`. |
| [`collect_git_evidence`](docs/99-evidences/collect_git_evidence.md) | `collect_git_evidence` | Captures current Git branch, commit hash, and working tree status into `git.json`. |
| [`collect_custom_evidence`](docs/99-evidences/collect_custom_evidence.md) | `collect_custom_evidence <name> <content>` | Saves custom text/data into `<name>.txt` inside `CURRENT_EVIDENCE_DIR` and tracks it in metadata. |
| [`evidence_to_json`](docs/99-evidences/evidence_to_json.md) | `evidence_to_json` | Outputs the current evidence session's `metadata.json` content. |
| [`evidence_to_markdown`](docs/99-evidences/evidence_to_markdown.md) | `evidence_to_markdown` | Renders all collected evidence files from the current session into a Markdown summary. |
| [`generate_evidence_report`](docs/99-evidences/generate_evidence_report.md) | `generate_evidence_report` | Writes the compiled Markdown summary to `${CURRENT_EVIDENCE_DIR}/report.md` and prints the path. |
| [`evidence_archive`](docs/99-evidences/evidence_archive.md) | `evidence_archive [output_tar_gz]` | Compresses `CURRENT_EVIDENCE_DIR` into a `.tar.gz` archive. |
| [`evidence_compare`](docs/99-evidences/evidence_compare.md) | `evidence_compare <ev_dir_1> <ev_dir_2>` | Compares `metadata.json` file lists between two evidence session directories. |
| [`evidence_validate`](docs/99-evidences/evidence_validate.md) | `evidence_validate [ev_dir]` | Verifies that `metadata.json` exists, is valid JSON, and all recorded evidence files are present. |


[↑ Back to Index](#index)
