# RZSH Framework Glossary

Quick-reference catalog of every **environment/global variable** set by the `rzsh` framework and every **function** available across all modules.

> **Tip:** Set `export RZSH_DIR="/path/to/rzsh"` in your `~/.zshrc`, then add two lines at the top of any script to unlock every variable and function listed below:
> ```zsh
> source "${RZSH_DIR}/config/config.sh"
> init_config
> ```

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

### 01. Logging Utility ([`functions/01-logs.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/01-logs.sh) | [Docs](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/01-logs.md))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| `init_logging` | `init_logging` | Creates the log directory, initializes the timestamped log file, and rotates old logs (keeps last 5). |
| `log` | `log <level> <message>` | Core logger that writes formatted, color-coded messages to console and `CURRENT_LOG_FILE`. |
| `log_info` | `log_info <message>` | Logs an informational (`INFO`) message in green. |
| `log_warn` | `log_warn <message>` | Logs a warning (`WARN`) message in yellow. |
| `log_error` | `log_error <message>` | Logs an error (`ERROR`) message in red to `stderr` and the log file. |
| `log_debug` | `log_debug <message>` | Logs a debug (`DEBUG`) message in blue when `LOG_LEVEL=DEBUG`. |
| `log_steps` | `log_steps <message>` | Increments `LOG_STEPS_COUNT` and logs a numbered step (`Step N: <message>`). |
| `log_command` | `log_command <command_string>` | Executes a shell command, logs its output and exit code, and returns the exit status. |
| `log_section` | `log_section <title>` | Prints a prominent banner header in the terminal and log file to separate workflow stages. |

### 02. Error Handling ([`functions/02-errors.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/02-errors.sh) | [Docs](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/02-errors.md))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| `error_exit` | `error_exit <message> [exit_code=1]` | Logs a fatal error with stack trace, cleans up registered temporary files, and exits the script. |
| `register_temp_file` | `register_temp_file <file_path>` | Registers a temporary file or folder in `TEMP_FILES` for automatic removal on cleanup/exit. |
| `cleanup_temp_files` | `cleanup_temp_files` | Deletes all files/directories registered in `TEMP_FILES` and clears the list. |

### 03. Navigation & Paths ([`functions/03-navigation.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/03-navigation.sh) | [Docs](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/03-navigation.md))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| `current_directory` | `current_directory` | Prints the absolute path of the current working directory. |
| `get_current_directory` | `get_current_directory` | Alias for `current_directory`; prints the resolved current working directory. |
| `dir_up` | `dir_up [levels=1]` | Prints the path N parent directories up from the current directory. |
| `absolute_path` | `absolute_path [target_path="."]` | Resolves any relative path or symlink into a canonical absolute path. |
| `get_absolute_path` | `get_absolute_path [target_path="."]` | Alias for `absolute_path`; resolves a path to its canonical absolute form. |
| `to_project_root` | `to_project_root` | Changes the current working directory (`cd`) to `PROJECT_ROOT`. |
| `get_project_root` | `get_project_root` | Prints the `PROJECT_ROOT` path, or detects the enclosing Git repository root. |
| `is_inside_git_repo` | `is_inside_git_repo` | Returns `0` if the current working directory is inside a Git working tree. |
| `normalize_path` | `normalize_path <path>` | Normalizes path segments (`..`, `.`, duplicate slashes) without requiring the path to exist. |
| `ensure_directory_exists` | `ensure_directory_exists <dir_path>` | Creates a directory and any missing parent directories if it does not already exist. |
| `change_directory` | `change_directory <dir_path>` | Safely changes into a target directory, returning `1` if the directory is missing or invalid. |

### 04. Input & Format Validation ([`functions/04-validation.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/04-validation.sh) | [Docs](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/04-validation.md))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| `validate_required` | `validate_required <value> [error_msg]` | Checks that a value is non-empty; logs an error and returns `1` if empty. |
| `validate_in_list` | `validate_in_list <value> <list>` | Checks whether a value exists in a comma- or space-separated list of allowed values. |
| `validate_file_exists` | `validate_file_exists <file_path>` | Returns `0` if the path exists and is a regular file. |
| `validate_directory_exists` | `validate_directory_exists <dir_path>` | Returns `0` if the path exists and is a directory. |
| `validate_is_number` | `validate_is_number <value>` | Returns `0` if the value is a valid integer or decimal number (positive or negative). |
| `validate_email` | `validate_email <email>` | Validates that a string matches standard email address syntax. |
| `validate_url` | `validate_url <url>` | Validates that a string is a well-formed `http://` or `https://` URL. |
| `validate_command_exists` | `validate_command_exists <cmd_name>` | Returns `0` if a CLI binary or shell command is available in `PATH`. |
| `validate_date` | `validate_date <date_str>` | Validates that a string is a real calendar date in `YYYY-MM-DD` format. |
| `validate_jwt` | `validate_jwt <token>` | Validates that a string has a 3-part base64url JWT structure (`header.payload.signature`). |
| `validate_json` | `validate_json <json_string>` | Returns `0` if the input string is valid JSON (parsed via `jq`). |

### 05. Git Operations ([`functions/05-git.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/05-git.sh) | [Docs](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/05-git.md))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| `git_get_current_branch` | `git_get_current_branch` | Prints the current active Git branch name. |
| `git_is_clean` | `git_is_clean` | Returns `0` if the working tree has no modified, staged, or untracked files. |
| `git_get_root` | `git_get_root` | Prints the top-level root directory of the current Git repository. |
| `git_status_message` | `git_status_message` | Prints a human-readable summary of the repository status (`Clean` or count of changed files). |
| `git_commit` | `git_commit <message>` | Stages all tracked modifications (`git add -u`) and creates a commit with the given message. |
| `git_push` | `git_push [remote="origin"] [branch]` | Pushes the specified (or current) branch to the remote repository. |
| `git_pull` | `git_pull [remote="origin"] [branch]` | Pulls latest changes from the remote branch. |
| `git_safe_pull` | `git_safe_pull [remote="origin"] [branch]` | Verifies the working copy is clean before pulling with `--ff-only`. |
| `git_branch_exists` | `git_branch_exists <branch_name>` | Returns `0` if the branch exists locally or on `origin`. |
| `git_get_commit_hash` | `git_get_commit_hash [short=0]` | Prints the full (or short if `1`) SHA hash of `HEAD`. |
| `git_get_commit_message` | `git_get_commit_message [commit="HEAD"]` | Prints the commit message of the specified commit ref. |
| `git_compare_branches` | `git_compare_branches [options] <base> <target>` | Compares two branches (honoring `GIT_IGNORE_FOLDERS`) and generates a detailed Markdown diff report. |

### 06. HTTP Client Wrapper ([`functions/06-http.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/06-http.sh) | [Docs](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/06-http.md))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| `http_get` | `http_get <url> [headers]` | Performs an HTTP `GET` request and returns the response body with the HTTP status code on the last line. |
| `http_post` | `http_post <url> [data_or_json_file] [headers]` | Performs an HTTP `POST` request; accepts a `.json` file path, `@file.json`, or raw JSON string. |
| `http_put` | `http_put <url> [data_or_json_file] [headers]` | Performs an HTTP `PUT` request; accepts a `.json` file path, `@file.json`, or raw JSON string. |
| `http_patch` | `http_patch <url> [data_or_json_file] [headers]` | Performs an HTTP `PATCH` request; accepts a `.json` file path, `@file.json`, or raw JSON string. |
| `http_delete` | `http_delete <url> [headers]` | Performs an HTTP `DELETE` request and appends the HTTP status code on the final line. |
| `check_status_code` | `check_status_code <http_response>` | Extracts the 3-digit HTTP status code from the response returned by `http_*` functions. |
| `http_get_body` | `http_get_body <http_response>` | Strips the trailing HTTP status code line and prints only the response payload body. |
| `is_json_response` | `is_json_response <http_response>` | Returns `0` if the HTTP response body is valid JSON. |
| `extract_json_field` | `extract_json_field <http_response> <jq_field>` | Extracts a specific field (e.g., `.data.id`) from an HTTP response body using `jq`. |
| `download_file` | `download_file <url> <output_path>` | Downloads a remote URL directly to a local file path, following redirects. |
| `http_get_with_retry` | `http_get_with_retry <url> [retries=3] [delay=2] [headers]` | Retries an HTTP `GET` request until a `2xx` status code is returned or retries are exhausted. |

### 07. Interactive User Prompts ([`functions/07-user-actions.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/07-user-actions.sh) | [Docs](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/07-user-actions.md))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| `read_input` | `read_input <prompt> [default_value]` | Prompts the user for text input and returns the typed value (or `default_value` if blank). |
| `read_password` | `read_password [prompt="Password"]` | Prompts the user for sensitive input with terminal character echoing disabled. |
| `confirm` | `confirm <prompt> [default="N"]` | Asks a Yes/No question (`[y/N]` or `[Y/n]`) and returns `0` for Yes or `1` for No. |
| `select_option` | `select_option <prompt> <opt1> [opt2 ...]` | Displays a numbered interactive menu and prints the selected option value. |
| `wait_for_enter` | `wait_for_enter [message]` | Pauses script execution until the user presses the Enter key. |
| `read_with_validation` | `read_with_validation <prompt> <validator_fn> [err_msg]` | Repeatedly prompts the user until the input passes the specified validation function. |

### 08. Date & Time Utilities ([`functions/08-datetime.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/08-datetime.sh) | [Docs](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/08-datetime.md))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| `timestamp` | `timestamp` | Prints the current Unix epoch time in seconds. |
| `date_now` | `date_now [format]` | Prints the current local date/time formatted with `DATE_FORMAT` (or custom `strftime` format). |
| `parse_date` | `parse_date <date_str> [format]` | Converts a date/time string into Unix epoch seconds. |
| `date_add` | `date_add <date_str> <duration> [out_format]` | Adds a duration (e.g., `2d`, `5h`, `30m`, `10s`) to a date and prints the resulting timestamp. |
| `date_subtract` | `date_subtract <date_str> <duration> [out_format]` | Subtracts a duration (e.g., `1d`, `2h`) from a date and prints the resulting timestamp. |
| `date_diff` | `date_diff <date1> <date2>` | Calculates the absolute difference in seconds between two dates. |
| `date_format` | `date_format <date_str> <target_format>` | Reformats a date string into a new `strftime` format. |
| `timezone_convert` | `timezone_convert <date_str> <from_tz> <to_tz> [format]` | Converts a timestamp from one timezone (e.g., `UTC`) to another (e.g., `America/New_York`). |
| `is_valid_date` | `is_valid_date <date_str> [format]` | Returns `0` if the date string can be parsed as a valid calendar date. |
| `date_range` | `date_range <start_date> <end_date>` | Prints every `YYYY-MM-DD` date inclusively between `start_date` and `end_date`. |
| `format_duration` | `format_duration <seconds>` | Formats a duration in seconds into a human-readable string (e.g., `1d 2h 3m 4s`). |

### 09. File Operations ([`functions/09-file.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/09-file.sh) | [Docs](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/09-file.md))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| `file_exists` | `file_exists <file_path>` | Returns `0` if the path exists and is a regular file. |
| `file_read` | `file_read <file_path>` | Outputs the contents of a file to `stdout`. |
| `file_write` | `file_write <file_path> <content>` | Writes content to a file (creating parent directories if needed). |
| `file_append` | `file_append <file_path> <content>` | Appends content to the end of a file. |
| `file_copy` | `file_copy <src> <dest> [interactive=0]` | Copies a file to a destination path (with optional overwrite confirmation). |
| `file_move` | `file_move <src> <dest> [interactive=0]` | Moves or renames a file (with optional overwrite confirmation). |
| `file_delete` | `file_delete <file_path> [interactive=0]` | Deletes a file (with optional confirmation prompt). |
| `file_get_size` | `file_get_size <file_path>` | Prints the file size in bytes. |
| `file_get_permissions` | `file_get_permissions <file_path>` | Prints the octal permission mode (e.g., `755` or `644`) of a file. |
| `file_set_permissions` | `file_set_permissions <file_path> <mode>` | Applies octal permissions (`chmod`) to a file. |
| `file_get_owner` | `file_get_owner <file_path>` | Prints the username of the file owner. |
| `file_get_group` | `file_get_group <file_path>` | Prints the group name of the file. |
| `file_backup` | `file_backup <file_path>` | Creates a timestamped `.bak` copy of a file and prints the backup path. |
| `file_restore` | `file_restore <backup_path> [target_path]` | Restores a file from its `.bak` backup file. |
| `file_backup_and_restore` | `file_backup_and_restore <action> <file_path>` | Convenience wrapper to either `backup` or `restore` a file. |
| `file_hash` | `file_hash <file_path> [algo="sha256"]` | Computes the cryptographic checksum (`sha256`, `md5`, `sha1`) of a file. |
| `file_head` | `file_head <file_path> [lines=10]` | Prints the first N lines of a file. |
| `file_tail` | `file_tail <file_path> [lines=10]` | Prints the last N lines of a file. |
| `file_grep` | `file_grep <file_path> <pattern>` | Searches a file for lines matching a regex pattern. |

### 10. Directory Management ([`functions/10-directory.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/10-directory.sh) | [Docs](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/10-directory.md))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| `dir_exists` | `dir_exists <dir_path>` | Returns `0` if the path exists and is a directory. |
| `dir_create` | `dir_create <dir_path> [mode]` | Recursively creates a directory (`mkdir -p`) and optionally sets permissions. |
| `dir_delete` | `dir_delete <dir_path> [interactive=0]` | Recursively deletes a directory (with safety checks against deleting `/`). |
| `dir_copy` | `dir_copy <src_dir> <dest_dir>` | Recursively copies a directory tree to a destination. |
| `dir_move` | `dir_move <src_dir> <dest_dir>` | Moves or renames a directory. |
| `dir_list` | `dir_list <dir_path> [glob_pattern="*"]` | Lists files/entries inside a directory matching the glob pattern. |
| `dir_size` | `dir_size <dir_path>` | Prints the human-readable total disk usage of a directory. |
| `dir_is_empty` | `dir_is_empty <dir_path>` | Returns `0` if the directory contains no files or subdirectories (including hidden ones). |
| `dir_clean` | `dir_clean <dir_path> [days_old=0]` | Removes all contents inside a directory (or files older than `days_old`) without deleting the folder itself. |
| `dir_tree` | `dir_tree <dir_path> [max_depth=3]` | Prints an indented visual tree structure of a directory. |
| `dir_sync` | `dir_sync <src_dir> <dest_dir>` | Synchronizes contents from source to destination directory using `rsync` or `cp -a`. |
| `dir_watch` | `dir_watch <dir_path> <callback_cmd> [interval=2] [max_loops=0]` | Polls a directory for file changes and triggers a callback command when modifications occur. |

### 11. String Manipulation ([`functions/11-string.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/11-string.sh) | [Docs](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/11-string.md))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| `str_contains` | `str_contains <string> <substring>` | Returns `0` if `string` contains `substring`. |
| `str_starts_with` | `str_starts_with <string> <prefix>` | Returns `0` if `string` starts with `prefix`. |
| `str_ends_with` | `str_ends_with <string> <suffix>` | Returns `0` if `string` ends with `suffix`. |
| `str_replace` | `str_replace <string> <search> <replace>` | Replaces all occurrences of `search` with `replace` in `string`. |
| `str_replace_first` | `str_replace_first <string> <search> <replace>` | Replaces only the first occurrence of `search` with `replace`. |
| `str_trim` | `str_trim <string>` | Strips both leading and trailing whitespace from `string`. |
| `str_ltrim` | `str_ltrim <string>` | Strips leading whitespace from `string`. |
| `str_rtrim` | `str_rtrim <string>` | Strips trailing whitespace from `string`. |
| `str_split` | `str_split <string> <delimiter>` | Splits `string` by `delimiter` and prints each element on a new line. |
| `str_join` | `str_join <delimiter> <item1> [item2 ...]` | Joins multiple arguments into a single string separated by `delimiter`. |
| `str_to_lower` | `str_to_lower <string>` | Converts all characters in `string` to lowercase. |
| `str_to_upper` | `str_to_upper <string>` | Converts all characters in `string` to uppercase. |
| `str_capitalize` | `str_capitalize <string>` | Capitalizes the first character of `string` and lowercases the rest. |
| `str_reverse` | `str_reverse <string>` | Reverses the character order of `string`. |
| `str_length` | `str_length <string>` | Prints the character length of `string`. |
| `str_substring` | `str_substring <string> <start_idx> [length]` | Extracts a substring starting at 0-based `start_idx` for `length` characters. |
| `str_pad_left` | `str_pad_left <string> <total_width> [pad_char=" "]` | Left-pads `string` to `total_width` using `pad_char`. |
| `str_pad_right` | `str_pad_right <string> <total_width> [pad_char=" "]` | Right-pads `string` to `total_width` using `pad_char`. |
| `str_escape` | `str_escape <string>` | URL-encodes (percent-encodes) special characters in `string`. |
| `str_unescape` | `str_unescape <string>` | Decodes a URL-encoded (percent-encoded) string. |
| `str_slugify` | `str_slugify <string>` | Converts arbitrary text into a lowercase, hyphen-separated URL slug. |
| `str_random` | `str_random [length=16]` | Generates a random alphanumeric string of the specified length. |
| `str_uuid` | `str_uuid` | Generates a standard v4 UUID string. |

### 12. SSH & SCP Client ([`functions/12-ssh.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/12-ssh.sh) | [Docs](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/12-ssh.md))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| `ssh_is_reachable` | `ssh_is_reachable <host> [port=22] [timeout=2]` | Checks whether a remote host's SSH TCP port is reachable within `timeout` seconds. |
| `ssh_exec` | `ssh_exec <user> <host> <cmd> [key_path] [password] [port=22]` | Executes a command on a remote server via SSH using an identity key or password. |
| `ssh_scp_up` | `ssh_scp_up <local_path> <user> <host> <remote_path> [key] [pass] [port=22]` | Uploads a local file or directory to a remote server via SCP. |
| `ssh_scp_down` | `ssh_scp_down <user> <host> <remote_path> <local_path> [key] [pass] [port=22]` | Downloads a file or directory from a remote server via SCP. |
| `ssh_tunnel_start` | `ssh_tunnel_start <user> <host> <local_port> <remote_host> <remote_port> [key] [port=22]` | Opens a background local port-forwarding SSH tunnel and prints the tunnel PID. |

### 13. JSON Web Tokens (JWT) ([`functions/13-jwt.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/13-jwt.sh) | [Docs](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/13-jwt.md))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| `jwt_generate` | `jwt_generate <payload_json> [secret]` | Generates an HS256-signed JWT from a JSON payload string using `secret` (or `JWT_SECRET`). |
| `jwt_decode` | `jwt_decode <token>` | Decodes and prints the payload JSON of a JWT without verifying its signature. |
| `jwt_get_header` | `jwt_get_header <token>` | Decodes and prints the header JSON of a JWT. |
| `jwt_get_payload` | `jwt_get_payload <token>` | Decodes and prints the payload JSON of a JWT. |
| `jwt_get_claim` | `jwt_get_claim <token> <claim_name>` | Extracts the value of a single claim key (e.g., `sub`, `role`) from a JWT payload. |
| `jwt_verify` | `jwt_verify <token> [secret]` | Verifies the HMAC-SHA256 cryptographic signature of a JWT against `secret`. |
| `jwt_expired` | `jwt_expired <token>` | Returns `0` if the token's `exp` claim is in the past (expired), or `1` if still active. |
| `jwt_valid` | `jwt_valid <token> [secret]` | Returns `0` only if the JWT is well-formed, signature-verified, and not expired. |
| `jwt_refresh` | `jwt_refresh <token> <extra_seconds> [secret]` | Verifies an existing token and issues a new JWT with an extended `exp` timestamp. |
| `jwt_parse_claims` | `jwt_parse_claims <token>` | Prints all claims in the JWT payload as `key=value` lines. |
| `jwt_get_audience` | `jwt_get_audience <token>` | Extracts the `aud` (Audience) claim from a JWT. |
| `jwt_get_issuer` | `jwt_get_issuer <token>` | Extracts the `iss` (Issuer) claim from a JWT. |
| `jwt_has_claim` | `jwt_has_claim <token> <claim_name>` | Returns `0` if the specified claim key exists and is non-null in the JWT payload. |

### 14. JSON Parsing & JQ ([`functions/14-jq.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/14-jq.sh) | [Docs](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/14-jq.md))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| `json_parse` | `json_parse <json_str>` | Parses and pretty-prints a JSON string using `jq`. |
| `json_get_value` | `json_get_value <json_str> <jq_path>` | Extracts a scalar or nested value at `jq_path` (e.g., `.user.name`) from a JSON string. |
| `json_set_value` | `json_set_value <json_str> <jq_path> <new_value>` | Sets or updates a key/path in a JSON string (auto-detecting numbers, booleans, objects, or strings). |
| `json_delete_key` | `json_delete_key <json_str> <jq_path>` | Deletes a key or element at `jq_path` from a JSON string. |
| `json_get_keys` | `json_get_keys <json_str> [jq_path="."]` | Lists all keys of a JSON object (one per line). |
| `json_merge` | `json_merge <json_base> <json_override>` | Deep-merges two JSON objects (`json_override` values take precedence). |
| `json_to_yaml` | `json_to_yaml <json_str>` | Converts a JSON object into YAML-formatted output. |
| `json_validate` | `json_validate <json_str>` | Returns `0` if `json_str` is valid JSON, or `1` otherwise. |
| `json_beautify` | `json_beautify <json_str>` | Formats a JSON string with 2-space indentation. |
| `json_compact` | `json_compact <json_str>` | Minifies a JSON string onto a single line with whitespace removed. |
| `json_escape` | `json_escape <raw_string>` | Escapes a raw string as a valid JSON string literal. |
| `json_array_add` | `json_array_add <json_str> <array_path> <item>` | Appends an element to a JSON array at `array_path`. |
| `json_array_remove` | `json_array_remove <json_str> <array_path> <value_or_index>` | Removes an element by value or index from a JSON array at `array_path`. |
| `json_extract_path` | `json_extract_path <json_str> <jq_path>` | Alias for `json_get_value`; extracts the value at `jq_path`. |

### 15. Dynamic Variables & Repo Registry ([`functions/15-variables.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/15-variables.sh) | [Docs](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/15-variables.md))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| `config_get_var` | `config_get_var <var_name> [default_value]` | Reads the value of a global variable by name, returning `default_value` if unset or empty. |
| `config_set_var` | `config_set_var <var_name> <value>` | Dynamically sets a global variable (`typeset -g`) by name. |
| `config_unset_var` | `config_unset_var <var_name>` | Unsets/removes a global variable by name. |
| `config_get_repo_location` | `config_get_repo_location <repo_name>` | Looks up a repository's filesystem path from `REPO_LOCATIONS`. |
| `config_set_repo_location` | `config_set_repo_location <repo_name> <path>` | Registers a repository name in `REPO_NAMES` and maps its path in `REPO_LOCATIONS`. |
| `config_unset_repo_location` | `config_unset_repo_location <repo_name>` | Removes a repository from both `REPO_LOCATIONS` and `REPO_NAMES`. |
| `config_list_repos` | `config_list_repos` | Prints all registered repositories in `<repo_name>: <path>` format. |

### 99. Evidence Collector ([`functions/99-evidences.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/99-evidences.sh) | [Docs](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/99-evidences.md))

| Function | Signature | Short Description |
| :--- | :--- | :--- |
| `init_evidence` | `init_evidence` | Creates a new timestamped folder under `EVIDENCE_DIR` and initializes `metadata.json`. |
| `collect_environment_evidence` | `collect_environment_evidence` | Captures OS, kernel, user, working directory, and environment snapshot into `environment.json`. |
| `collect_script_evidence` | `collect_script_evidence [args...]` | Records the executing script name, arguments, and PID into `script.json`. |
| `collect_network_evidence` | `collect_network_evidence` | Captures network interfaces and routing state into `network.txt`. |
| `collect_file_evidence` | `collect_file_evidence <file_path>` | Copies a target file into the evidence folder and records its size and SHA-256 hash. |
| `collect_docker_evidence` | `collect_docker_evidence` | Captures running Docker container status (`docker ps`) into `docker.txt`. |
| `collect_git_evidence` | `collect_git_evidence` | Captures current Git branch, commit hash, and working tree status into `git.json`. |
| `collect_custom_evidence` | `collect_custom_evidence <name> <content>` | Saves custom text/data into `<name>.txt` inside `CURRENT_EVIDENCE_DIR` and tracks it in metadata. |
| `evidence_to_json` | `evidence_to_json` | Outputs the current evidence session's `metadata.json` content. |
| `evidence_to_markdown` | `evidence_to_markdown` | Renders all collected evidence files from the current session into a Markdown summary. |
| `generate_evidence_report` | `generate_evidence_report` | Writes the compiled Markdown summary to `${CURRENT_EVIDENCE_DIR}/report.md` and prints the path. |
| `evidence_archive` | `evidence_archive [output_tar_gz]` | Compresses `CURRENT_EVIDENCE_DIR` into a `.tar.gz` archive. |
| `evidence_compare` | `evidence_compare <ev_dir_1> <ev_dir_2>` | Compares `metadata.json` file lists between two evidence session directories. |
| `evidence_validate` | `evidence_validate [ev_dir]` | Verifies that `metadata.json` exists, is valid JSON, and all recorded evidence files are present. |

