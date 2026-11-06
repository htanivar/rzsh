# Zsh Control Statements Guide (Copy-Paste Reference for Beginners)

- **Guide File:** [`docs/98-control-statements.md`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/98-control-statements.md)
- **Description:** Copy-pasteable control statement templates (`if`, `if-else`, `if-elif-else`, `case/switch`, AND/OR conditions, file/number/string checks, and one-liners) designed for novice users. Copy any block below and change only the highlighted values to fit your needs.

---

## Table of Contents
1. [Quick Setup (Include at the Top of Your Script)](#1-quick-setup-include-at-the-top-of-your-script)
2. [Condition Cheat Sheet (What Can I Check?)](#2-condition-cheat-sheet-what-can-i-check)
3. [Basic `if` Statements](#3-basic-if-statements)
   - [3.1 Simple `if` (Run Only When True)](#31-simple-if-run-only-when-true)
   - [3.2 `if - else` (Two-Way Branch)](#32-if---else-two-way-branch)
   - [3.3 `if - elif - else` Ladder (Multiple Choices)](#33-if---elif---else-ladder-multiple-choices)
   - [3.4 Nested `if` (An `if` Inside Another `if`)](#34-nested-if-an-if-inside-another-if)
4. [Ready-to-Copy Condition Examples](#4-ready-to-copy-condition-examples)
   - [4.1 String Comparisons (Equal, Not Equal, Empty, Contains, Starts With)](#41-string-comparisons-equal-not-equal-empty-contains-starts-with)
   - [4.2 Number Comparisons (Equal, Greater Than, Less Than)](#42-number-comparisons-equal-greater-than-less-than)
   - [4.3 File & Folder Checks (Exists, Readable, Non-Empty)](#43-file--folder-checks-exists-readable-non-empty)
   - [4.4 Combining Multiple Conditions (`AND`, `OR`, `NOT`)](#44-combining-multiple-conditions-and-or-not)
5. [`case` Statements (Switch / Multi-Way Branch)](#5-case-statements-switch--multi-way-branch)
   - [5.1 Basic Switch (`case ... in`)](#51-basic-switch-case--in)
   - [5.2 Switch with Multiple Matching Values (`|`)](#52-switch-with-multiple-matching-values-)
   - [5.3 Switch with Wildcard Patterns (`*.json`, `prod-*`)](#53-switch-with-wildcard-patterns-json-prod-)
6. [Short One-Line Control Statements (`&&` and `||`)](#6-short-one-line-control-statements--and-)
7. [Control Statements with `rzsh` Framework Functions](#7-control-statements-with-rzsh-framework-functions)
   - [7.1 Interactive Yes/No Confirmation (`confirm`)](#71-interactive-yesno-confirmation-confirm)
   - [7.2 Input Validation (`validate_*`)](#72-input-validation-validate_)
   - [7.3 Checking HTTP Status Codes (`check_status_code`)](#73-checking-http-status-codes-check_status_code)

---

## 1. Quick Setup (Include at the Top of Your Script)

Paste these lines at the top of your `.sh` script so all helper functions (`log_info`, `log_warn`, `log_error`, `validate_*`, `confirm`) are ready to use:

```zsh
#!/usr/bin/env zsh
source "${RZSH_DIR}/config/config.sh"
init_config
init_logging
```

> [!IMPORTANT]
> **Golden Rule of Shell `if` Statements:** Always keep a **space** inside the brackets `[[` and `]]`, and around `==` or `-eq`.
> - Correct: `if [[ "${name}" == "admin" ]]; then`
> - Wrong: `if [["${name}"=="admin"]]; then`

---

## 2. Condition Cheat Sheet (What Can I Check?)

### String Checks
| Condition | Meaning |
| :--- | :--- |
| `[[ "${a}" == "${b}" ]]` | Text `${a}` equals `${b}` |
| `[[ "${a}" != "${b}" ]]` | Text `${a}` does **not** equal `${b}` |
| `[[ -z "${a}" ]]` | Text `${a}` is **empty** (zero length) |
| `[[ -n "${a}" ]]` | Text `${a}` is **not empty** |
| `[[ "${a}" == *"word"* ]]` | Text `${a}` **contains** `"word"` |
| `[[ "${a}" == "prefix"* ]]` | Text `${a}` **starts with** `"prefix"` |
| `[[ "${a}" == *".json" ]]` | Text `${a}` **ends with** `".json"` |

### Number Checks
| Condition | Meaning |
| :--- | :--- |
| `[[ ${num} -eq 10 ]]` | Number **equals** 10 (`==`) |
| `[[ ${num} -ne 10 ]]` | Number **does not equal** 10 (`!=`) |
| `[[ ${num} -gt 10 ]]` | Number is **greater than** 10 (`>`) |
| `[[ ${num} -ge 10 ]]` | Number is **greater than or equal to** 10 (`>=`) |
| `[[ ${num} -lt 10 ]]` | Number is **less than** 10 (`<`) |
| `[[ ${num} -le 10 ]]` | Number is **less than or equal to** 10 (`<=`) |

### File & Folder Checks
| Condition | Meaning |
| :--- | :--- |
| `[[ -f "${file_path}" ]]` | File exists (and is a regular file) |
| `[[ ! -f "${file_path}" ]]` | File does **not** exist |
| `[[ -d "${dir_path}" ]]` | Folder (directory) exists |
| `[[ ! -d "${dir_path}" ]]` | Folder does **not** exist |
| `[[ -s "${file_path}" ]]` | File exists and is **not empty** (size > 0) |
| `[[ -r "${file_path}" ]]` | File exists and is **readable** |
| `[[ -w "${file_path}" ]]` | File exists and is **writable** |
| `[[ -x "${file_path}" ]]` | File exists and is **executable** |

---

## 3. Basic `if` Statements

### 3.1 Simple `if` (Run Only When True)
**What to change:** Change `environment="production"` or the value inside `"production"`.

```zsh
environment="production"

if [[ "${environment}" == "production" ]]; then
  log_info "Running in PRODUCTION mode."
fi
```

---

### 3.2 `if - else` (Two-Way Branch)
Runs the first block when true, or the `else` block when false.
**What to change:** Change `is_ready="yes"` and the commands inside `then` / `else`.

```zsh
is_ready="yes"

if [[ "${is_ready}" == "yes" ]]; then
  log_info "System is ready. Starting job..."
else
  log_warn "System is not ready yet. Skipping job."
fi
```

---

### 3.3 `if - elif - else` Ladder (Multiple Choices)
Checks conditions from top to bottom and runs the **first** one that matches. If none match, the `else` block runs.
**What to change:** Change `"dev"`, `"staging"`, `"prod"` to match your options.

```zsh
env_name="staging"

if [[ "${env_name}" == "dev" ]]; then
  log_info "Deploying to Development server..."
elif [[ "${env_name}" == "staging" ]]; then
  log_info "Deploying to Staging server..."
elif [[ "${env_name}" == "prod" ]]; then
  log_info "Deploying to Production server..."
else
  log_error "Unknown environment: ${env_name}"
fi
```

---

### 3.4 Nested `if` (An `if` Inside Another `if`)
Useful when you want to check a second condition only after the first condition passes.

```zsh
user_role="admin"
is_active="true"

if [[ "${user_role}" == "admin" ]]; then
  if [[ "${is_active}" == "true" ]]; then
    log_info "Active administrator granted full access."
  else
    log_warn "Admin account is currently inactive."
  fi
else
  log_info "Standard user access granted."
fi
```

---

## 4. Ready-to-Copy Condition Examples

### 4.1 String Comparisons (Equal, Not Equal, Empty, Contains, Starts With)

```zsh
username="alice_admin"

# 1. Check if variable is empty
if [[ -z "${username}" ]]; then
  log_error "Username cannot be empty!"
fi

# 2. Check if variable is NOT empty
if [[ -n "${username}" ]]; then
  log_info "Username is set to: ${username}"
fi

# 3. Check if string contains a word (wildcard *)
if [[ "${username}" == *"admin"* ]]; then
  log_info "User has admin in their username."
fi

# 4. Check if string starts with a prefix
if [[ "${username}" == "alice"* ]]; then
  log_info "Username starts with alice."
fi

# 5. Check if string does NOT equal a value
if [[ "${username}" != "guest" ]]; then
  log_info "User is not a guest."
fi
```

---

### 4.2 Number Comparisons (Equal, Greater Than, Less Than)

```zsh
disk_usage=85

if [[ ${disk_usage} -ge 90 ]]; then
  log_error "CRITICAL: Disk usage is ${disk_usage}% (90% or higher)!"
elif [[ ${disk_usage} -ge 75 ]]; then
  log_warn "WARNING: Disk usage is ${disk_usage}% (between 75% and 89%)."
else
  log_info "OK: Disk usage is healthy at ${disk_usage}%."
fi
```

> [!TIP]
> You can also use familiar math symbols (`>`, `<`, `>=`, `<=`, `==`) inside double parentheses `(( ... ))`:
> ```zsh
> if (( disk_usage >= 90 )); then
>   log_error "Disk usage is too high!"
> fi
> ```

---

### 4.3 File & Folder Checks (Exists, Readable, Non-Empty)

```zsh
config_file="./config/settings.json"
backup_dir="./backups"

# Check if a file exists
if [[ -f "${config_file}" ]]; then
  log_info "Found config file: ${config_file}"
else
  log_warn "Config file ${config_file} does not exist."
fi

# Check if a folder does NOT exist, and create it
if [[ ! -d "${backup_dir}" ]]; then
  log_info "Creating missing folder: ${backup_dir}"
  mkdir -p "${backup_dir}"
fi

# Check if a file exists AND has content (not 0 bytes)
if [[ -s "${config_file}" ]]; then
  log_info "Config file has content."
fi
```

---

### 4.4 Combining Multiple Conditions (`AND`, `OR`, `NOT`)

- Use `&&` when **both** conditions must be true (**AND**).
- Use `||` when **either** condition can be true (**OR**).
- Use `!` to flip a condition (**NOT**).

```zsh
env_name="prod"
approved="yes"

# AND (&&): Both conditions must be true
if [[ "${env_name}" == "prod" && "${approved}" == "yes" ]]; then
  log_info "Production deployment is approved and ready."
fi

# OR (||): At least one condition must be true
if [[ "${env_name}" == "dev" || "${env_name}" == "staging" ]]; then
  log_info "Non-production environment detected (${env_name})."
fi

# NOT (!): True when condition is false
if [[ ! "${env_name}" == "prod" ]]; then
  log_info "Safe mode: We are NOT in production."
fi
```

---

## 5. `case` Statements (Switch / Multi-Way Branch)

When you are checking a single variable against many possible values, a `case` statement (known as `switch` in other languages) is much cleaner and easier to read than a long `if-elif-else` chain.

> [!NOTE]
> - Each option ends with a closing parenthesis `)`.
> - Each block ends with double semicolons `;;`.
> - `*)` at the bottom is the `default` fallback when nothing else matches.

### 5.1 Basic Switch (`case ... in`)
**What to change:** Change `action="start"` and the case labels (`"start"`, `"stop"`, `"restart"`).

```zsh
action="start"

case "${action}" in
  "start")
    log_info "Starting the service..."
    ;;
  "stop")
    log_info "Stopping the service..."
    ;;
  "restart")
    log_info "Restarting the service..."
    ;;
  "status")
    log_info "Checking service status..."
    ;;
  *)
    log_error "Unknown action: '${action}'. Use start, stop, restart, or status."
    ;;
esac
```

---

### 5.2 Switch with Multiple Matching Values (`|`)
Use the pipe symbol `|` to group multiple values (like uppercase/lowercase or aliases) into the same block.

```zsh
user_answer="yes"

case "${user_answer}" in
  y|Y|yes|YES|true)
    log_info "You agreed! Proceeding..."
    ;;
  n|N|no|NO|false)
    log_warn "You declined. Stopping."
    ;;
  *)
    log_error "Invalid response: ${user_answer} (please enter yes or no)"
    ;;
esac
```

---

### 5.3 Switch with Wildcard Patterns (`*.json`, `prod-*`)
Use `*` as a wildcard to match file extensions, prefixes, or patterns.

```zsh
file_name="report_2026.json"

case "${file_name}" in
  *.json)
    log_info "${file_name} is a JSON file."
    ;;
  *.yaml|*.yml)
    log_info "${file_name} is a YAML file."
    ;;
  *.log|*.txt)
    log_info "${file_name} is a plain text/log file."
    ;;
  backup_*)
    log_info "${file_name} is a backup archive."
    ;;
  *)
    log_warn "Unrecognized file type: ${file_name}"
    ;;
esac
```

---

## 6. Short One-Line Control Statements (`&&` and `||`)

For very simple checks, you don't even need a full `if ... fi` block:

```zsh
# Run the second command ONLY IF the first check succeeds (&&)
[[ -f "./config.json" ]] && log_info "config.json found!"

# Run the second command ONLY IF the first check fails (||)
[[ -d "./logs" ]] || mkdir -p "./logs"

# Stop the script immediately with an error message if a required variable is missing
validate_required "${API_KEY}" || error_exit "API_KEY is required to run this script."
```

---

## 7. Control Statements with `rzsh` Framework Functions

All `rzsh` validation and prompt functions work directly inside `if` statements (without needing `[[ ]]` brackets!):

### 7.1 Interactive Yes/No Confirmation (`confirm`)
From [`docs/07-user-actions.md`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/07-user-actions.md):

```zsh
if confirm "Are you sure you want to delete old log files?" "n"; then
  log_info "Confirmed! Deleting old logs..."
else
  log_warn "Action cancelled by user."
fi
```

---

### 7.2 Input Validation (`validate_*`)
From [`docs/04-validation.md`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/04-validation.md):

```zsh
email="user@example.com"
url="https://github.com"
port="8080"

# Check if email is valid
if validate_email "${email}"; then
  log_info "Email '${email}' is valid."
else
  log_error "Invalid email format: ${email}"
fi

# Check if URL is valid
if validate_url "${url}"; then
  log_info "URL '${url}' is valid."
fi

# Check if a value is in an allowed comma-separated list
if validate_in_list "${port}" "80,443,8080,8443"; then
  log_info "Port ${port} is allowed."
fi

# Check if a command is installed on the computer
if validate_command_exists "jq"; then
  log_info "jq is installed and ready."
else
  log_error "jq is not installed!"
fi
```

---

### 7.3 Checking HTTP Status Codes (`check_status_code`)
From [`docs/06-http.md`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/06-http.md):

```zsh
response=$(http_get "https://httpbin.org/get")
http_code=$(check_status_code "${response}")

case "${http_code}" in
  200|201|204)
    log_info "Request succeeded (HTTP ${http_code})"
    ;;
  400|401|403|404)
    log_warn "Client error received (HTTP ${http_code})"
    ;;
  500|502|503|504)
    log_error "Server error received (HTTP ${http_code})"
    ;;
  *)
    log_warn "Unexpected HTTP status code: ${http_code}"
    ;;
esac
```
