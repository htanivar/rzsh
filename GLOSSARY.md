# RZSH Framework Glossary

Quick-reference catalog of every **environment/global variable** set by the `rzsh` framework and every **function** available across all modules.

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
  - [00. Global Configuration](#00-global-configuration-configconfigsh--docs)
  - [01. Logging Utility](#01-logging-utility-functions01-logssh--docs)
  - [02. Error Handling](#02-error-handling-functions02-errorssh--docs)
  - [03. Navigation & Paths](#03-navigation--paths-functions03-navigationsh--docs)
  - [04. Input & Format Validation](#04-input--format-validation-functions04-validationsh--docs)
  - [05. Git Operations](#05-git-operations-functions05-gitsh--docs)
  - [06. HTTP Client Wrapper](#06-http-client-wrapper-functions06-httpsh--docs)
  - [07. Interactive User Prompts](#07-interactive-user-prompts-functions07-user-actionssh--docs)
  - [08. Date & Time Utilities](#08-date--time-utilities-functions08-datetimesh--docs)
  - [09. File Operations](#09-file-operations-functions09-filesh--docs)
  - [10. Directory Management](#10-directory-management-functions10-directorysh--docs)
  - [11. String Manipulation](#11-string-manipulation-functions11-stringsh--docs)
  - [12. SSH & SCP Client](#12-ssh--scp-client-functions12-sshsh--docs)
  - [13. JSON Web Tokens (JWT)](#13-json-web-tokens-jwt-functions13-jwtsh--docs)
  - [14. JSON Parsing & JQ](#14-json-parsing--jq-functions14-jqsh--docs)
  - [15. Dynamic Variables & Repo Registry](#15-dynamic-variables--repo-registry-functions15-variablessh--docs)
  - [99. Evidence Collector](#99-evidence-collector-functions99-evidencessh--docs)

---

## 1. Variables Set by the Framework

The table below lists all variable keys initialized or managed by the framework (values are omitted for security and clarity).

### Core Configuration Variables ([`config/config.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/config/config.sh))

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
| `RAVI_DIR` | String (Path) | Yes | Optional custom workspace directory variable for user scripts. |
| `GIT_IGNORE_FOLDERS` | String (CSV) | Yes | Comma-separated list of folder names excluded during Git branch comparisons. |
| `REPO_NAMES` | Array (`typeset -g -a`) | Global | List of registered repository identifiers managed by [`15-variables.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/15-variables.sh). |
| `REPO_LOCATIONS` | Associative Array (`typeset -g -A`) | Global | Key-value map of repository names to their local filesystem paths. |

### Module Runtime State Variables

| Variable Key | Module | Type | Description |
| :--- | :--- | :--- | :--- |
| `CURRENT_LOG_FILE` | [`functions/01-logs.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/01-logs.sh) | String (Path) | Full file path of the active log file created by `init_logging`. |
| `LOG_STEPS_COUNT` | [`functions/01-logs.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/01-logs.sh) | Integer | Sequential counter incremented each time `log_steps` is called. |
| `TEMP_FILES` | [`functions/02-errors.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/02-errors.sh) | Array (`typeset -g -a`) | List of temporary files/directories registered via `register_temp_file` for automatic cleanup. |
| `CURRENT_EVIDENCE_DIR` | [`functions/99-evidences.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/99-evidences.sh) | String (Path) | Path to the active timestamped evidence session directory created by `init_evidence`. |

---

## 2. Functions Available in the Framework

### 00. Global Configuration ([`config/config.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/config/config.sh) | [Docs](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/00-config.md))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| `init_config` | `init_config` | Initializes and exports all global framework variables with safe defaults and loads all modules. |

[↑ Back to Index](#index)

### 01. Logging Utility ([`functions/01-logs.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/01-logs.sh) | [Docs](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/01-logs.md))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| [`init_logging`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/01-logs.sh#L26) | `init_logging` | Creates the log directory, initializes the timestamped log file, and rotates old logs (keeps last 5). |
| [`log`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/01-logs.sh#L64) | `log <level> <message>` | Core logger that writes formatted, color-coded messages to console and `CURRENT_LOG_FILE`. |
| [`log_info`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/01-logs.sh#L119) | `log_info <message>` | Logs an informational (`INFO`) message in green. |
| [`log_warn`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/01-logs.sh#L143) | `log_warn <message>` | Logs a warning (`WARN`) message in yellow. |
| [`log_error`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/01-logs.sh#L131) | `log_error <message>` | Logs an error (`ERROR`) message in red to `stderr` and the log file. |
| [`log_debug`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/01-logs.sh#L155) | `log_debug <message>` | Logs a debug (`DEBUG`) message in blue when `LOG_LEVEL=DEBUG`. |
| [`log_steps`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/01-logs.sh#L167) | `log_steps <message>` | Increments `LOG_STEPS_COUNT` and logs a numbered step (`Step N: <message>`). |
| [`log_command`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/01-logs.sh#L181) | `log_command <command_string>` | Executes a shell command, logs its output and exit code, and returns the exit status. |
| [`log_section`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/01-logs.sh#L206) | `log_section <title>` | Prints a prominent banner header in the terminal and log file to separate workflow stages. |

[↑ Back to Index](#index)

### 02. Error Handling ([`functions/02-errors.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/02-errors.sh) | [Docs](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/02-errors.md))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| [`error_exit`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/02-errors.sh#L26) | `error_exit <message> [exit_code=1]` | Logs a fatal error with stack trace, cleans up registered temporary files, and exits the script. |
| [`register_temp_file`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/02-errors.sh#L61) | `register_temp_file <file_path>` | Registers a temporary file or folder in `TEMP_FILES` for automatic removal on cleanup/exit. |
| [`cleanup_temp_files`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/02-errors.sh#L79) | `cleanup_temp_files` | Deletes all files/directories registered in `TEMP_FILES` and clears the list. |

[↑ Back to Index](#index)

### 03. Navigation & Paths ([`functions/03-navigation.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/03-navigation.sh) | [Docs](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/03-navigation.md))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| [`current_directory`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/03-navigation.sh#L23) | `current_directory` | Prints the absolute path of the current working directory. |
| [`get_current_directory`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/03-navigation.sh#L61) | `get_current_directory` | Alias for `current_directory`; prints the resolved current working directory. |
| [`dir_up`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/03-navigation.sh#L36) | `dir_up [levels=1]` | Prints the path N parent directories up from the current directory. |
| [`absolute_path`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/03-navigation.sh#L55) | `absolute_path [target_path="."]` | Resolves any relative path or symlink into a canonical absolute path. |
| [`get_absolute_path`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/03-navigation.sh#L65) | `get_absolute_path [target_path="."]` | Alias for `absolute_path`; resolves a path to its canonical absolute form. |
| [`to_project_root`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/03-navigation.sh#L78) | `to_project_root` | Changes the current working directory (`cd`) to `PROJECT_ROOT`. |
| [`get_project_root`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/03-navigation.sh#L94) | `get_project_root` | Prints the `PROJECT_ROOT` path, or detects the enclosing Git repository root. |
| [`is_inside_git_repo`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/03-navigation.sh#L108) | `is_inside_git_repo` | Returns `0` if the current working directory is inside a Git working tree. |
| [`normalize_path`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/03-navigation.sh#L124) | `normalize_path <path>` | Normalizes path segments (`..`, `.`, duplicate slashes) without requiring the path to exist. |
| [`ensure_directory_exists`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/03-navigation.sh#L137) | `ensure_directory_exists <dir_path>` | Creates a directory and any missing parent directories if it does not already exist. |
| [`change_directory`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/03-navigation.sh#L153) | `change_directory <dir_path>` | Safely changes into a target directory, returning `1` if the directory is missing or invalid. |

[↑ Back to Index](#index)

### 04. Input & Format Validation ([`functions/04-validation.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/04-validation.sh) | [Docs](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/04-validation.md))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| [`validate_required`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/04-validation.sh#L26) | `validate_required <value> [error_msg]` | Checks that a value is non-empty; logs an error and returns `1` if empty. |
| [`validate_in_list`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/04-validation.sh#L49) | `validate_in_list <value> <list>` | Checks whether a value exists in a comma- or space-separated list of allowed values. |
| [`validate_file_exists`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/04-validation.sh#L69) | `validate_file_exists <file_path>` | Returns `0` if the path exists and is a regular file. |
| [`validate_directory_exists`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/04-validation.sh#L85) | `validate_directory_exists <dir_path>` | Returns `0` if the path exists and is a directory. |
| [`validate_is_number`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/04-validation.sh#L101) | `validate_is_number <value>` | Returns `0` if the value is a valid integer or decimal number (positive or negative). |
| [`validate_email`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/04-validation.sh#L117) | `validate_email <email>` | Validates that a string matches standard email address syntax. |
| [`validate_url`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/04-validation.sh#L133) | `validate_url <url>` | Validates that a string is a well-formed `http://` or `https://` URL. |
| [`validate_command_exists`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/04-validation.sh#L149) | `validate_command_exists <cmd_name>` | Returns `0` if a CLI binary or shell command is available in `PATH`. |
| [`validate_date`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/04-validation.sh#L165) | `validate_date <date_str>` | Validates that a string is a real calendar date in `YYYY-MM-DD` format. |
| [`validate_jwt`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/04-validation.sh#L190) | `validate_jwt <token>` | Validates that a string has a 3-part base64url JWT structure (`header.payload.signature`). |
| [`validate_json`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/04-validation.sh#L207) | `validate_json <json_string>` | Returns `0` if the input string is valid JSON (parsed via `jq`). |

[↑ Back to Index](#index)

### 05. Git Operations ([`functions/05-git.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/05-git.sh) | [Docs](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/05-git.md))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| [`git_get_current_branch`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/05-git.sh#L26) | `git_get_current_branch` | Prints the current active Git branch name. |
| [`git_is_clean`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/05-git.sh#L40) | `git_is_clean` | Returns `0` if the working tree has no modified, staged, or untracked files. |
| [`git_get_root`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/05-git.sh#L53) | `git_get_root` | Prints the top-level root directory of the current Git repository. |
| [`git_status_message`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/05-git.sh#L65) | `git_status_message` | Prints a human-readable summary of the repository status (`Clean` or count of changed files). |
| [`git_commit`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/05-git.sh#L77) | `git_commit <message>` | Stages all tracked modifications (`git add -u`) and creates a commit with the given message. |
| [`git_push`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/05-git.sh#L93) | `git_push [remote="origin"] [branch]` | Pushes the specified (or current) branch to the remote repository. |
| [`git_pull`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/05-git.sh#L110) | `git_pull [remote="origin"] [branch]` | Pulls latest changes from the remote branch. |
| [`git_safe_pull`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/05-git.sh#L127) | `git_safe_pull [remote="origin"] [branch]` | Verifies the working copy is clean before pulling with `--ff-only`. |
| [`git_branch_exists`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/05-git.sh#L154) | `git_branch_exists <branch_name>` | Returns `0` if the branch exists locally or on `origin`. |
| [`git_get_commit_hash`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/05-git.sh#L171) | `git_get_commit_hash [short=0]` | Prints the full (or short if `1`) SHA hash of `HEAD`. |
| [`git_get_commit_message`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/05-git.sh#L184) | `git_get_commit_message [commit="HEAD"]` | Prints the commit message of the specified commit ref. |
| [`git_compare_branches`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/05-git.sh#L201) | `git_compare_branches [options] <base> <target>` | Compares two branches (honoring `GIT_IGNORE_FOLDERS`) and generates a detailed Markdown diff report. |
| [`git_detect_default_branch`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/05-git.sh#L597) | `git_detect_default_branch` | Detects the repository's default branch (`origin/HEAD`, `develop`, `main`, or `master`). |
| [`git_resolve_ref`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/05-git.sh#L625) | `git_resolve_ref <branch>` | Resolves a branch name to its local ref or `origin/<branch>` remote ref. |
| [`git_list_branches`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/05-git.sh#L645) | `git_list_branches [pattern]` | Lists unique local and `origin` branch names, optionally filtered by a glob pattern (e.g., `release/*`). |
| [`git_get_missed_commits`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/05-git.sh#L669) | `git_get_missed_commits <target> <source>` | Outputs SHAs of commits in `<source>` not backported to `<target>` (patch-id aware via `git cherry`). |
| [`git_format_commit`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/05-git.sh#L697) | `git_format_commit [commit="HEAD"]` | Formats a commit as `<short_hash> \| <date> \| <author> \| <subject>`. |
| [`git_pick_branch`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/05-git.sh#L709) | `git_pick_branch <prompt> [pattern]` | Prompts the user to select a branch matching `[pattern]` (falling back to all branches). |
| [`git_report_missed_commits`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/05-git.sh#L734) | `git_report_missed_commits <target> <release> [output_file] [silent]` | Highlights release commits missing from `<target>` and optionally writes a Markdown report. |

[↑ Back to Index](#index)

### 06. HTTP Client Wrapper ([`functions/06-http.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/06-http.sh) | [Docs](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/06-http.md))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| [`http_get`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/06-http.sh#L27) | `http_get <url> [headers]` | Performs an HTTP `GET` request and returns the response body with the HTTP status code on the last line. |
| [`http_post`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/06-http.sh#L57) | `http_post <url> [data_or_json_file] [headers]` | Performs an HTTP `POST` request; accepts a `.json` file path, `@file.json`, or raw JSON string. |
| [`http_put`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/06-http.sh#L94) | `http_put <url> [data_or_json_file] [headers]` | Performs an HTTP `PUT` request; accepts a `.json` file path, `@file.json`, or raw JSON string. |
| [`http_patch`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/06-http.sh#L131) | `http_patch <url> [data_or_json_file] [headers]` | Performs an HTTP `PATCH` request; accepts a `.json` file path, `@file.json`, or raw JSON string. |
| [`http_delete`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/06-http.sh#L167) | `http_delete <url> [headers]` | Performs an HTTP `DELETE` request and appends the HTTP status code on the final line. |
| [`check_status_code`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/06-http.sh#L195) | `check_status_code <http_response>` | Extracts the 3-digit HTTP status code from the response returned by `http_*` functions. |
| [`http_get_body`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/06-http.sh#L209) | `http_get_body <http_response>` | Strips the trailing HTTP status code line and prints only the response payload body. |
| [`is_json_response`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/06-http.sh#L224) | `is_json_response <http_response>` | Returns `0` if the HTTP response body is valid JSON. |
| [`extract_json_field`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/06-http.sh#L241) | `extract_json_field <http_response> <jq_field>` | Extracts a specific field (e.g., `.data.id`) from an HTTP response body using `jq`. |
| [`download_file`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/06-http.sh#L260) | `download_file <url> <output_path>` | Downloads a remote URL directly to a local file path, following redirects. |
| [`http_get_with_retry`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/06-http.sh#L279) | `http_get_with_retry <url> [retries=3] [delay=2] [headers]` | Retries an HTTP `GET` request until a `2xx` status code is returned or retries are exhausted. |

[↑ Back to Index](#index)

### 07. Interactive User Prompts ([`functions/07-user-actions.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/07-user-actions.sh) | [Docs](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/07-user-actions.md))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| [`read_input`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/07-user-actions.sh#L24) | `read_input <prompt> [default_value]` | Prompts the user for text input and returns the typed value (or `default_value` if blank). |
| [`read_password`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/07-user-actions.sh#L53) | `read_password [prompt="Password"]` | Prompts the user for sensitive input with terminal character echoing disabled. |
| [`confirm`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/07-user-actions.sh#L74) | `confirm <prompt> [default="N"]` | Asks a Yes/No question (`[y/N]` or `[Y/n]`) and returns `0` for Yes or `1` for No. |
| [`select_option`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/07-user-actions.sh#L109) | `select_option <prompt> <opt1> [opt2 ...]` | Displays a numbered interactive menu and prints the selected option value. |
| [`wait_for_enter`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/07-user-actions.sh#L143) | `wait_for_enter [message]` | Pauses script execution until the user presses the Enter key. |
| [`read_with_validation`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/07-user-actions.sh#L159) | `read_with_validation <prompt> <validator_fn> [err_msg]` | Repeatedly prompts the user until the input passes the specified validation function. |

[↑ Back to Index](#index)

### 08. Date & Time Utilities ([`functions/08-datetime.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/08-datetime.sh) | [Docs](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/08-datetime.md))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| [`timestamp`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/08-datetime.sh#L26) | `timestamp` | Prints the current Unix epoch time in seconds. |
| [`date_now`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/08-datetime.sh#L43) | `date_now [format]` | Prints the current local date/time formatted with `DATE_FORMAT` (or custom `strftime` format). |
| [`parse_date`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/08-datetime.sh#L60) | `parse_date <date_str> [format]` | Converts a date/time string into Unix epoch seconds. |
| [`date_add`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/08-datetime.sh#L129) | `date_add <date_str> <duration> [out_format]` | Adds a duration (e.g., `2d`, `5h`, `30m`, `10s`) to a date and prints the resulting timestamp. |
| [`date_subtract`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/08-datetime.sh#L150) | `date_subtract <date_str> <duration> [out_format]` | Subtracts a duration (e.g., `1d`, `2h`) from a date and prints the resulting timestamp. |
| [`date_diff`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/08-datetime.sh#L171) | `date_diff <date1> <date2>` | Calculates the absolute difference in seconds between two dates. |
| [`date_format`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/08-datetime.sh#L190) | `date_format <date_str> <target_format>` | Reformats a date string into a new `strftime` format. |
| [`timezone_convert`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/08-datetime.sh#L208) | `timezone_convert <date_str> <from_tz> <to_tz> [format]` | Converts a timestamp from one timezone (e.g., `UTC`) to another (e.g., `America/New_York`). |
| [`is_valid_date`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/08-datetime.sh#L225) | `is_valid_date <date_str> [format]` | Returns `0` if the date string can be parsed as a valid calendar date. |
| [`date_range`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/08-datetime.sh#L239) | `date_range <start_date> <end_date>` | Prints every `YYYY-MM-DD` date inclusively between `start_date` and `end_date`. |
| [`format_duration`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/08-datetime.sh#L266) | `format_duration <seconds>` | Formats a duration in seconds into a human-readable string (e.g., `1d 2h 3m 4s`). |

[↑ Back to Index](#index)

### 09. File Operations ([`functions/09-file.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/09-file.sh) | [Docs](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/09-file.md))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| [`file_exists`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/09-file.sh#L28) | `file_exists <file_path>` | Returns `0` if the path exists and is a regular file. |
| [`file_read`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/09-file.sh#L45) | `file_read <file_path>` | Outputs the contents of a file to `stdout`. |
| [`file_write`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/09-file.sh#L62) | `file_write <file_path> <content>` | Writes content to a file (creating parent directories if needed). |
| [`file_append`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/09-file.sh#L77) | `file_append <file_path> <content>` | Appends content to the end of a file. |
| [`file_copy`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/09-file.sh#L92) | `file_copy <src> <dest> [interactive=0]` | Copies a file to a destination path (with optional overwrite confirmation). |
| [`file_move`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/09-file.sh#L107) | `file_move <src> <dest> [interactive=0]` | Moves or renames a file (with optional overwrite confirmation). |
| [`file_delete`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/09-file.sh#L122) | `file_delete <file_path> [interactive=0]` | Deletes a file (with optional confirmation prompt). |
| [`file_get_size`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/09-file.sh#L154) | `file_get_size <file_path>` | Prints the file size in bytes. |
| [`file_get_permissions`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/09-file.sh#L176) | `file_get_permissions <file_path>` | Prints the octal permission mode (e.g., `755` or `644`) of a file. |
| [`file_set_permissions`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/09-file.sh#L193) | `file_set_permissions <file_path> <mode>` | Applies octal permissions (`chmod`) to a file. |
| [`file_get_owner`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/09-file.sh#L208) | `file_get_owner <file_path>` | Prints the username of the file owner. |
| [`file_get_group`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/09-file.sh#L225) | `file_get_group <file_path>` | Prints the group name of the file. |
| [`file_backup`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/09-file.sh#L242) | `file_backup <file_path>` | Creates a timestamped `.bak` copy of a file and prints the backup path. |
| [`file_restore`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/09-file.sh#L262) | `file_restore <backup_path> [target_path]` | Restores a file from its `.bak` backup file. |
| [`file_backup_and_restore`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/09-file.sh#L286) | `file_backup_and_restore <action> <file_path>` | Convenience wrapper to either `backup` or `restore` a file. |
| [`file_hash`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/09-file.sh#L315) | `file_hash <file_path> [algo="sha256"]` | Computes the cryptographic checksum (`sha256`, `md5`, `sha1`) of a file. |
| [`file_head`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/09-file.sh#L358) | `file_head <file_path> [lines=10]` | Prints the first N lines of a file. |
| [`file_tail`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/09-file.sh#L340) | `file_tail <file_path> [lines=10]` | Prints the last N lines of a file. |
| [`file_grep`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/09-file.sh#L376) | `file_grep <file_path> <pattern>` | Searches a file for lines matching a regex pattern. |

[↑ Back to Index](#index)

### 10. Directory Management ([`functions/10-directory.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/10-directory.sh) | [Docs](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/10-directory.md))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| [`dir_exists`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/10-directory.sh#L28) | `dir_exists <dir_path>` | Returns `0` if the path exists and is a directory. |
| [`dir_create`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/10-directory.sh#L44) | `dir_create <dir_path> [mode]` | Recursively creates a directory (`mkdir -p`) and optionally sets permissions. |
| [`dir_delete`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/10-directory.sh#L58) | `dir_delete <dir_path> [interactive=0]` | Recursively deletes a directory (with safety checks against deleting `/`). |
| [`dir_copy`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/10-directory.sh#L90) | `dir_copy <src_dir> <dest_dir>` | Recursively copies a directory tree to a destination. |
| [`dir_move`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/10-directory.sh#L105) | `dir_move <src_dir> <dest_dir>` | Moves or renames a directory. |
| [`dir_list`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/10-directory.sh#L120) | `dir_list <dir_path> [glob_pattern="*"]` | Lists files/entries inside a directory matching the glob pattern. |
| [`dir_size`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/10-directory.sh#L146) | `dir_size <dir_path>` | Prints the human-readable total disk usage of a directory. |
| [`dir_is_empty`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/10-directory.sh#L176) | `dir_is_empty <dir_path>` | Returns `0` if the directory contains no files or subdirectories (including hidden ones). |
| [`dir_clean`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/10-directory.sh#L202) | `dir_clean <dir_path> [days_old=0]` | Removes all contents inside a directory (or files older than `days_old`) without deleting the folder itself. |
| [`dir_tree`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/10-directory.sh#L220) | `dir_tree <dir_path> [max_depth=3]` | Prints an indented visual tree structure of a directory. |
| [`dir_sync`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/10-directory.sh#L267) | `dir_sync <src_dir> <dest_dir>` | Synchronizes contents from source to destination directory using `rsync` or `cp -a`. |
| [`dir_watch`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/10-directory.sh#L296) | `dir_watch <dir_path> <callback_cmd> [interval=2] [max_loops=0]` | Polls a directory for file changes and triggers a callback command when modifications occur. |

[↑ Back to Index](#index)

### 11. String Manipulation ([`functions/11-string.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/11-string.sh) | [Docs](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/11-string.md))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| [`str_contains`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/11-string.sh#L25) | `str_contains <string> <substring>` | Returns `0` if `string` contains `substring`. |
| [`str_starts_with`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/11-string.sh#L45) | `str_starts_with <string> <prefix>` | Returns `0` if `string` starts with `prefix`. |
| [`str_ends_with`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/11-string.sh#L65) | `str_ends_with <string> <suffix>` | Returns `0` if `string` ends with `suffix`. |
| [`str_replace`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/11-string.sh#L85) | `str_replace <string> <search> <replace>` | Replaces all occurrences of `search` with `replace` in `string`. |
| [`str_replace_first`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/11-string.sh#L103) | `str_replace_first <string> <search> <replace>` | Replaces only the first occurrence of `search` with `replace`. |
| [`str_trim`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/11-string.sh#L119) | `str_trim <string>` | Strips both leading and trailing whitespace from `string`. |
| [`str_ltrim`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/11-string.sh#L136) | `str_ltrim <string>` | Strips leading whitespace from `string`. |
| [`str_rtrim`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/11-string.sh#L151) | `str_rtrim <string>` | Strips trailing whitespace from `string`. |
| [`str_split`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/11-string.sh#L166) | `str_split <string> <delimiter>` | Splits `string` by `delimiter` and prints each element on a new line. |
| [`str_join`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/11-string.sh#L189) | `str_join <delimiter> <item1> [item2 ...]` | Joins multiple arguments into a single string separated by `delimiter`. |
| [`str_to_lower`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/11-string.sh#L206) | `str_to_lower <string>` | Converts all characters in `string` to lowercase. |
| [`str_to_upper`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/11-string.sh#L219) | `str_to_upper <string>` | Converts all characters in `string` to uppercase. |
| [`str_capitalize`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/11-string.sh#L232) | `str_capitalize <string>` | Capitalizes the first character of `string` and lowercases the rest. |
| [`str_reverse`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/11-string.sh#L245) | `str_reverse <string>` | Reverses the character order of `string`. |
| [`str_length`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/11-string.sh#L263) | `str_length <string>` | Prints the character length of `string`. |
| [`str_substring`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/11-string.sh#L277) | `str_substring <string> <start_idx> [length]` | Extracts a substring starting at 0-based `start_idx` for `length` characters. |
| [`str_pad_left`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/11-string.sh#L294) | `str_pad_left <string> <total_width> [pad_char=" "]` | Left-pads `string` to `total_width` using `pad_char`. |
| [`str_pad_right`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/11-string.sh#L321) | `str_pad_right <string> <total_width> [pad_char=" "]` | Right-pads `string` to `total_width` using `pad_char`. |
| [`str_escape`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/11-string.sh#L346) | `str_escape <string>` | URL-encodes (percent-encodes) special characters in `string`. |
| [`str_unescape`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/11-string.sh#L359) | `str_unescape <string>` | Decodes a URL-encoded (percent-encoded) string. |
| [`str_slugify`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/11-string.sh#L372) | `str_slugify <string>` | Converts arbitrary text into a lowercase, hyphen-separated URL slug. |
| [`str_random`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/11-string.sh#L392) | `str_random [length=16]` | Generates a random alphanumeric string of the specified length. |
| [`str_uuid`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/11-string.sh#L418) | `str_uuid` | Generates a standard v4 UUID string. |

[↑ Back to Index](#index)

### 12. SSH & SCP Client ([`functions/12-ssh.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/12-ssh.sh) | [Docs](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/12-ssh.md))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| [`ssh_is_reachable`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/12-ssh.sh#L26) | `ssh_is_reachable <host> [port=22] [timeout=2]` | Checks whether a remote host's SSH TCP port is reachable within `timeout` seconds. |
| [`ssh_exec`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/12-ssh.sh#L91) | `ssh_exec <user> <host> <cmd> [key_path] [password] [port=22]` | Executes a command on a remote server via SSH using an identity key or password. |
| [`ssh_scp_up`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/12-ssh.sh#L145) | `ssh_scp_up <local_path> <user> <host> <remote_path> [key] [pass] [port=22]` | Uploads a local file or directory to a remote server via SCP. |
| [`ssh_scp_down`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/12-ssh.sh#L197) | `ssh_scp_down <user> <host> <remote_path> <local_path> [key] [pass] [port=22]` | Downloads a file or directory from a remote server via SCP. |
| [`ssh_tunnel_start`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/12-ssh.sh#L251) | `ssh_tunnel_start <user> <host> <local_port> <remote_host> <remote_port> [key] [port=22]` | Opens a background local port-forwarding SSH tunnel and prints the tunnel PID. |

[↑ Back to Index](#index)

### 13. JSON Web Tokens (JWT) ([`functions/13-jwt.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/13-jwt.sh) | [Docs](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/13-jwt.md))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| [`jwt_generate`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/13-jwt.sh#L61) | `jwt_generate <payload_json> [secret]` | Generates an HS256-signed JWT from a JSON payload string using `secret` (or `JWT_SECRET`). |
| [`jwt_decode`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/13-jwt.sh#L88) | `jwt_decode <token>` | Decodes and prints the payload JSON of a JWT without verifying its signature. |
| [`jwt_get_header`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/13-jwt.sh#L112) | `jwt_get_header <token>` | Decodes and prints the header JSON of a JWT. |
| [`jwt_get_payload`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/13-jwt.sh#L130) | `jwt_get_payload <token>` | Decodes and prints the payload JSON of a JWT. |
| [`jwt_get_claim`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/13-jwt.sh#L150) | `jwt_get_claim <token> <claim_name>` | Extracts the value of a single claim key (e.g., `sub`, `role`) from a JWT payload. |
| [`jwt_verify`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/13-jwt.sh#L173) | `jwt_verify <token> [secret]` | Verifies the HMAC-SHA256 cryptographic signature of a JWT against `secret`. |
| [`jwt_expired`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/13-jwt.sh#L206) | `jwt_expired <token>` | Returns `0` if the token's `exp` claim is in the past (expired), or `1` if still active. |
| [`jwt_valid`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/13-jwt.sh#L233) | `jwt_valid <token> [secret]` | Returns `0` only if the JWT is well-formed, signature-verified, and not expired. |
| [`jwt_refresh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/13-jwt.sh#L249) | `jwt_refresh <token> <extra_seconds> [secret]` | Verifies an existing token and issues a new JWT with an extended `exp` timestamp. |
| [`jwt_parse_claims`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/13-jwt.sh#L281) | `jwt_parse_claims <token>` | Prints all claims in the JWT payload as `key=value` lines. |
| [`jwt_get_audience`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/13-jwt.sh#L294) | `jwt_get_audience <token>` | Extracts the `aud` (Audience) claim from a JWT. |
| [`jwt_get_issuer`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/13-jwt.sh#L307) | `jwt_get_issuer <token>` | Extracts the `iss` (Issuer) claim from a JWT. |
| [`jwt_has_claim`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/13-jwt.sh#L322) | `jwt_has_claim <token> <claim_name>` | Returns `0` if the specified claim key exists and is non-null in the JWT payload. |

[↑ Back to Index](#index)

### 14. JSON Parsing & JQ ([`functions/14-jq.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/14-jq.sh) | [Docs](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/14-jq.md))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| [`json_parse`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/14-jq.sh#L22) | `json_parse <json_str>` | Parses and pretty-prints a JSON string using `jq`. |
| [`json_get_value`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/14-jq.sh#L40) | `json_get_value <json_str> <jq_path>` | Extracts a scalar or nested value at `jq_path` (e.g., `.user.name`) from a JSON string. |
| [`json_set_value`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/14-jq.sh#L60) | `json_set_value <json_str> <jq_path> <new_value>` | Sets or updates a key/path in a JSON string (auto-detecting numbers, booleans, objects, or strings). |
| [`json_delete_key`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/14-jq.sh#L86) | `json_delete_key <json_str> <jq_path>` | Deletes a key or element at `jq_path` from a JSON string. |
| [`json_get_keys`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/14-jq.sh#L104) | `json_get_keys <json_str> [jq_path="."]` | Lists all keys of a JSON object (one per line). |
| [`json_merge`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/14-jq.sh#L122) | `json_merge <json_base> <json_override>` | Deep-merges two JSON objects (`json_override` values take precedence). |
| [`json_to_yaml`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/14-jq.sh#L139) | `json_to_yaml <json_str>` | Converts a JSON object into YAML-formatted output. |
| [`json_validate`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/14-jq.sh#L165) | `json_validate <json_str>` | Returns `0` if `json_str` is valid JSON, or `1` otherwise. |
| [`json_beautify`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/14-jq.sh#L181) | `json_beautify <json_str>` | Formats a JSON string with 2-space indentation. |
| [`json_compact`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/14-jq.sh#L272) | `json_compact <json_str>` | Minifies a JSON string onto a single line with whitespace removed. |
| [`json_escape`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/14-jq.sh#L197) | `json_escape <raw_string>` | Escapes a raw string as a valid JSON string literal. |
| [`json_array_add`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/14-jq.sh#L215) | `json_array_add <json_str> <array_path> <item>` | Appends an element to a JSON array at `array_path`. |
| [`json_array_remove`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/14-jq.sh#L241) | `json_array_remove <json_str> <array_path> <value_or_index>` | Removes an element by value or index from a JSON array at `array_path`. |
| [`json_extract_path`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/14-jq.sh#L260) | `json_extract_path <json_str> <jq_path>` | Alias for `json_get_value`; extracts the value at `jq_path`. |

[↑ Back to Index](#index)

### 15. Dynamic Variables & Repo Registry ([`functions/15-variables.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/15-variables.sh) | [Docs](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/15-variables.md))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| [`config_get_var`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/15-variables.sh#L32) | `config_get_var <var_name> [default_value]` | Reads the value of a global variable by name, returning `default_value` if unset or empty. |
| [`config_set_var`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/15-variables.sh#L51) | `config_set_var <var_name> <value>` | Dynamically sets a global variable (`typeset -g`) by name. |
| [`config_unset_var`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/15-variables.sh#L69) | `config_unset_var <var_name>` | Unsets/removes a global variable by name. |
| [`config_get_repo_location`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/15-variables.sh#L87) | `config_get_repo_location <repo_name>` | Looks up a repository's filesystem path from `REPO_LOCATIONS`. |
| [`config_set_repo_location`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/15-variables.sh#L105) | `config_set_repo_location <repo_name> <path>` | Registers a repository name in `REPO_NAMES` and maps its path in `REPO_LOCATIONS`. |
| [`config_unset_repo_location`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/15-variables.sh#L127) | `config_unset_repo_location <repo_name>` | Removes a repository from both `REPO_LOCATIONS` and `REPO_NAMES`. |
| [`config_list_repos`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/15-variables.sh#L144) | `config_list_repos` | Prints all registered repositories in `<repo_name>: <path>` format. |

[↑ Back to Index](#index)

### 99. Evidence Collector ([`functions/99-evidences.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/99-evidences.sh) | [Docs](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/99-evidences.md))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| [`init_evidence`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/99-evidences.sh#L25) | `init_evidence` | Creates a new timestamped folder under `EVIDENCE_DIR` and initializes `metadata.json`. |
| [`collect_environment_evidence`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/99-evidences.sh#L64) | `collect_environment_evidence` | Captures OS, kernel, user, working directory, and environment snapshot into `environment.json`. |
| [`collect_script_evidence`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/99-evidences.sh#L92) | `collect_script_evidence [args...]` | Records the executing script name, arguments, and PID into `script.json`. |
| [`collect_network_evidence`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/99-evidences.sh#L120) | `collect_network_evidence` | Captures network interfaces and routing state into `network.txt`. |
| [`collect_file_evidence`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/99-evidences.sh#L154) | `collect_file_evidence <file_path>` | Copies a target file into the evidence folder and records its size and SHA-256 hash. |
| [`collect_docker_evidence`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/99-evidences.sh#L197) | `collect_docker_evidence` | Captures running Docker container status (`docker ps`) into `docker.txt`. |
| [`collect_git_evidence`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/99-evidences.sh#L228) | `collect_git_evidence` | Captures current Git branch, commit hash, and working tree status into `git.json`. |
| [`collect_custom_evidence`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/99-evidences.sh#L263) | `collect_custom_evidence <name> <content>` | Saves custom text/data into `<name>.txt` inside `CURRENT_EVIDENCE_DIR` and tracks it in metadata. |
| [`evidence_to_json`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/99-evidences.sh#L287) | `evidence_to_json` | Outputs the current evidence session's `metadata.json` content. |
| [`evidence_to_markdown`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/99-evidences.sh#L322) | `evidence_to_markdown` | Renders all collected evidence files from the current session into a Markdown summary. |
| [`generate_evidence_report`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/99-evidences.sh#L374) | `generate_evidence_report` | Writes the compiled Markdown summary to `${CURRENT_EVIDENCE_DIR}/report.md` and prints the path. |
| [`evidence_archive`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/99-evidences.sh#L387) | `evidence_archive [output_tar_gz]` | Compresses `CURRENT_EVIDENCE_DIR` into a `.tar.gz` archive. |
| [`evidence_compare`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/99-evidences.sh#L413) | `evidence_compare <ev_dir_1> <ev_dir_2>` | Compares `metadata.json` file lists between two evidence session directories. |
| [`evidence_validate`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/99-evidences.sh#L429) | `evidence_validate [ev_dir]` | Verifies that `metadata.json` exists, is valid JSON, and all recorded evidence files are present. |


[↑ Back to Index](#index)
